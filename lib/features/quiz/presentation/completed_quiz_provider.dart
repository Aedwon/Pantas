import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/application/completed_quiz.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

typedef CompletedQuizRequest = ({
  Object boundary,
  String attemptId,
  QuizSession? session,
  Attempt? attempt,
  bool custom,
});

class CompletedQuizData {
  const CompletedQuizData({
    required this.attempt,
    required this.session,
    required this.subjectNames,
    required this.sourceLine,
  });
  final Attempt attempt;
  final QuizSession session;
  final Map<String, String> subjectNames;
  final String? sourceLine;
}

final completedQuizProvider = FutureProvider.autoDispose
    .family<CompletedQuizData, CompletedQuizRequest>((ref, request) async {
  final content = ref.watch(contentRepositoryProvider);
  final attempt = request.attempt ??
      await ref.watch(attemptsRepositoryProvider).byId(request.attemptId);
  if (attempt == null || attempt.id != request.attemptId) {
    throw StateError('Completed quiz is unavailable');
  }
  final session = await hydrateCompletedQuiz(
    attempt,
    content,
    original: request.session,
  );
  final topicNames = <String, String>{};
  final subjectNames = <String, String>{};
  for (final id in session.questions.map((q) => q.topicId).toSet()) {
    final topic = await content.topicById(id);
    if (topic == null) continue;
    topicNames[id] = topic.name;
    final subject = await content.subjectById(topic.subjectId);
    if (subject != null) subjectNames[id] = subject.name;
  }
  String? source;
  switch (session.origin) {
    case SessionOrigin.flagged:
      source = 'Flagged questions';
    case SessionOrigin.retake:
      source = 'Your past mistakes';
    case SessionOrigin.inline:
      final lesson = session.lessonId == null
          ? null
          : await content.lessonById(session.lessonId!);
      if (lesson != null) {
        source = '${lesson.title} · ${session.questions.length} questions';
      }
    case SessionOrigin.drill:
      final names = topicNames.values.toSet().join(', ');
      source = request.custom
          ? names.isEmpty
              ? 'Your quiz'
              : 'Your quiz · $names'
          : 'Quiz';
    case SessionOrigin.todayTopic:
    case SessionOrigin.todayInterleaved:
      // The legacy mixed plan is not a Reviews-only or New-questions batch.
      source = "Today's session";
    case SessionOrigin.assessment:
      source = 'Assessment';
    case SessionOrigin.mock:
      source = 'Mock exam';
  }
  return CompletedQuizData(
    attempt: attempt,
    session: session,
    subjectNames: subjectNames,
    sourceLine: source,
  );
});
