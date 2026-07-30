import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/quiz/domain/debrief/session_debrief.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

typedef DebriefParams = ({
  String attemptId,
  bool proIsActive,
  QuizSession? sessionOverride,
  Attempt? attemptOverride,
});

final sessionDebriefProvider =
    FutureProvider.family<SessionDebrief, DebriefParams>((ref, params) async {
  final attemptsRepo = ref.watch(attemptsRepositoryProvider);
  final contentRepo = ref.watch(contentRepositoryProvider);

  final attempt =
      params.attemptOverride ?? await attemptsRepo.byId(params.attemptId);

  if (attempt == null && params.sessionOverride == null) {
    throw StateError('Attempt not found: ${params.attemptId}');
  }

  final QuizSession session;
  if (params.sessionOverride != null) {
    session = params.sessionOverride!;
  } else {
    final questions = <Question>[];
    for (final item in attempt!.items) {
      final q = await contentRepo.questionById(item.questionId);
      if (q != null) questions.add(q);
    }

    session = QuizSession(
      sessionId: attempt.id,
      examId: attempt.examId,
      questions: questions,
      currentIndex: questions.length,
      outcomes: attempt.items
          .map(
            (item) => AnswerOutcome(
              questionId: item.questionId,
              questionVersion: item.questionVersion,
              chosenChoiceId: item.chosenChoiceId,
              correctChoiceId: item.correctChoiceId,
              responseMs: item.responseMs,
            ),
          )
          .toList(),
      startedAt: attempt.startedAt,
      origin: SessionOrigin.fromStorage(attempt.origin),
    );
  }

  final examId = attempt?.examId ?? session.examId;
  final topics = await contentRepo.topicsByExam(examId);
  final topicNames = <TopicId, String>{
    for (final t in topics) t.id: t.name,
  };

  final topicOf = <QuestionId, TopicId>{
    for (final q in session.questions) q.id: q.topicId,
  };

  final now = DateTime.now();
  final topicAverageMs = await attemptsRepo.averageResponseMsByTopic(
    examId: examId,
    topicOf: topicOf,
    now: now,
  );

  final priorCorrect = <QuestionId, DateTime?>{};
  for (final q in session.questions) {
    priorCorrect[q.id] = await attemptsRepo.lastCorrectAt(
      examId: examId,
      questionId: q.id,
      before: session.startedAt,
    );
  }

  final priorAttempted = await attemptsRepo.questionIdsAnsweredSince(
    examId: examId,
    since: DateTime.fromMillisecondsSinceEpoch(0),
  );

  return BuildSessionDebrief.call(
    session: session,
    topicNames: topicNames,
    topicAverageMs: topicAverageMs,
    topicAnswerCount: const {},
    priorCorrect: priorCorrect,
    priorAttemptedQuestionIds: priorAttempted,
    proIsActive: params.proIsActive,
    now: attempt?.completedAt ?? now,
  );
});
