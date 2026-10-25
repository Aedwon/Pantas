import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';

final customTrackRepositoryProvider = Provider<CustomTrackRepository>(
  (ref) => CustomTrackRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(contentDatabaseProvider),
  ),
);

/// What the student has hidden.
final trackScopeProvider = FutureProvider.family<Set<TopicId>, ExamId>(
  (ref, examId) =>
      ref.watch(customTrackRepositoryProvider).excludedTopicIds(examId),
);

final lessonScopeProvider = FutureProvider.family<Set<LessonId>, ExamId>(
  (ref, examId) =>
      ref.watch(customTrackRepositoryProvider).excludedLessonIds(examId),
);

/// What is in this student's exam.
///
/// The single answer for both kinds of track. Every feature that used to ask
/// `topicsByExam` asks this instead, which is also what makes narrowing
/// available to a listed exam rather than only to a custom one.
final scopedTopicsProvider =
    FutureProvider.family<List<Topic>, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final excluded = await ref.watch(trackScopeProvider(examId).future);
  final exam = (await content.listExams())
      .where((candidate) => candidate.id == examId)
      .firstOrNull;

  final topics = exam != null && exam.isCustom
      ? await corpusTopics(content)
      : await content.topicsByExam(examId);

  return [
    for (final topic in topics)
      if (!excluded.contains(topic.id)) topic,
  ];
});

/// The scoped topics of [examId] and the excluded topic ids, read directly
/// rather than through the cached providers above. Launch preparation and the
/// study plan read scope this way so a freshness check sees the same topics
/// the plan was built from.
Future<({List<Topic> topics, Set<TopicId> excluded})> readScopedTopics(
  ContentRepository content,
  CustomTrackRepository customTracks,
  ExamId examId,
) async {
  final excluded = await customTracks.excludedTopicIds(examId);
  final exams = await content.listExams();
  final exam = exams.where((candidate) => candidate.id == examId).firstOrNull;
  final sourceTopics = exam != null && exam.isCustom
      ? await corpusTopics(content)
      : await content.topicsByExam(examId);
  return (
    topics: [
      for (final topic in sourceTopics)
        if (!excluded.contains(topic.id)) topic,
    ],
    excluded: excluded,
  );
}

/// The subjects those topics belong to, in order, and only the ones that
/// still hold a topic.
final scopedSubjectsProvider =
    FutureProvider.family<List<Subject>, ExamId>((ref, examId) async {
  final content = ref.watch(contentRepositoryProvider);
  final topics = await ref.watch(scopedTopicsProvider(examId).future);
  final keptSubjectIds = {for (final topic in topics) topic.subjectId};

  final subjects = <Subject>[];
  final seenNames = <String>{};
  for (final exam in await content.listExams()) {
    for (final subject in exam.subjects) {
      if (!keptSubjectIds.contains(subject.id)) continue;
      // A shared subject carries the same name under several exams, and a
      // student should see it once.
      if (!seenNames.add(subject.name)) continue;
      subjects.add(subject);
    }
  }
  return subjects;
});

/// Every topic in the corpus, once.
///
/// A custom track owns no subjects, so it draws on what every listed exam
/// carries. Shared subjects appear under several exams with different topic
/// ids, so they are collapsed by name and the id holding the most questions
/// wins. That is a real loss where two exams' "Algebra" differ; the proper fix
/// is a corpus-level topic identity, which is a content change.
Future<List<Topic>> corpusTopics(ContentRepository content) async {
  final candidates = <({String key, Topic topic})>[];

  for (final exam in await content.listExams()) {
    if (exam.isCustom) continue;
    for (final topic in await content.topicsByExam(exam.id)) {
      final subjectName = exam.subjects
          .where((s) => s.id == topic.subjectId)
          .map((s) => s.name)
          .firstOrNull;
      candidates.add(
        (
          key: '${subjectName ?? topic.subjectId}\u0000${topic.name}',
          topic: topic,
        ),
      );
    }
  }

  final questionCounts = await content.activeQuestionCountsByTopics(
    [for (final candidate in candidates) candidate.topic.id],
  );
  final byName = <String, Topic>{};
  for (final candidate in candidates) {
    final topic = candidate.topic;
    final held = byName[candidate.key];
    if (held == null ||
        (questionCounts[topic.id] ?? 0) > (questionCounts[held.id] ?? 0)) {
      byName[candidate.key] = topic;
    }
  }

  return byName.values.toList();
}
