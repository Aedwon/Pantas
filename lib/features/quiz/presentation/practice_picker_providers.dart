import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Everything the picker lists: subjects in order, their topics in order, and
/// each topic's lessons with their read state.
final practiceIndexProvider =
    FutureProvider.family<PracticeIndex, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final exams = await content.listExams();
  final exam = exams.where((candidate) => candidate.id == examId).firstOrNull;
  if (exam == null) return PracticeIndex.empty;

  final readIds =
      await ref.watch(lessonProgressRepositoryProvider).readLessonIds();

  final subjects = <PracticeSubjectEntry>[];
  for (final subject in exam.subjects) {
    final topics = <PracticeTopicEntry>[];
    for (final topic in await content.topicsBySubject(subject.id)) {
      final questions = await content.questionsByTopic(topic.id);
      final taggedCounts = <LessonId, int>{};
      for (final question in questions) {
        final lessonId = question.lessonId;
        if (lessonId == null) continue;
        taggedCounts[lessonId] = (taggedCounts[lessonId] ?? 0) + 1;
      }

      topics.add(
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
    subjects.add(
      PracticeSubjectEntry(
        id: subject.id,
        name: subject.name,
        topics: topics,
      ),
    );
  }
  return PracticeIndex(subjects);
});
