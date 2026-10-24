import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/data/repos/practice_preferences_repository.dart';
import 'package:pantas/features/quiz/domain/picker/practice_index.dart';

/// Everything the picker lists: subjects in order, their topics in order, and
/// each topic's lessons with their read state.
final practiceIndexProvider =
    FutureProvider.family<PracticeIndex, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final scopedTopics = await ref.watch(scopedTopicsProvider(examId).future);
  final scopedSubjects = await ref.watch(scopedSubjectsProvider(examId).future);

  final topicsBySubjectMap = <SubjectId, List<Topic>>{};
  for (final t in scopedTopics) {
    topicsBySubjectMap.putIfAbsent(t.subjectId, () => []).add(t);
  }

  final readIds =
      await ref.watch(lessonProgressRepositoryProvider).readLessonIds();

  final subjects = <PracticeSubjectEntry>[];
  for (final subject in scopedSubjects) {
    final topicEntries = <PracticeTopicEntry>[];
    final topics = topicsBySubjectMap[subject.id] ?? const [];
    for (final topic in topics) {
      final questions = await content.questionsByTopic(topic.id);
      final taggedCounts = <LessonId, int>{};
      for (final question in questions) {
        final lessonId = question.lessonId;
        if (lessonId == null) continue;
        taggedCounts[lessonId] = (taggedCounts[lessonId] ?? 0) + 1;
      }

      topicEntries.add(
        PracticeTopicEntry(
          id: topic.id,
          name: topic.name,
          questionCount: questions.length,
          lessons: [
            for (final lesson in await content.lessonsByTopic(topic.id))
              PracticeLessonEntry(
                id: lesson.id,
                title: lesson.title,
                isRead: readIds.contains(lesson.id),
                questionCount: taggedCounts[lesson.id] ?? 0,
              ),
          ],
        ),
      );
    }
    if (topicEntries.isNotEmpty) {
      subjects.add(
        PracticeSubjectEntry(
          id: subject.id,
          name: subject.name,
          topics: topicEntries,
        ),
      );
    }
  }
  return PracticeIndex(subjects);
});

/// The student's measured pace. The picker uses D-166's approved starting
/// estimate until a positive measurement exists.
final practicePaceProvider =
    FutureProvider.family<int?, ExamId>((ref, examId) async {
  ref.watch(quizSessionPanelRevisionProvider);
  return ref
      .watch(attemptsRepositoryProvider)
      .averageResponseMs(examId: examId);
});

final practicePreferencesRepositoryProvider =
    Provider<PracticePreferencesRepository>(
  (ref) => PracticePreferencesRepository(ref.watch(appDatabaseProvider)),
);
final savedPracticePicksProvider =
    FutureProvider.autoDispose.family<SavedPracticePicks, ExamId>(
  (ref, examId) =>
      ref.watch(practicePreferencesRepositoryProvider).read(examId),
);
