import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/web_study_seam.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';

class TopicLesson {
  const TopicLesson({
    required this.id,
    required this.title,
    required this.read,
    required this.today,
  });
  final String id;
  final String title;
  final bool read;

  /// True only for a lesson actually in today's stored plan.
  final bool today;
}

/// The address names a topic this exam does not have. Retrying cannot fix it,
/// so the page offers no Try Again.
class TopicNotFound implements Exception {
  const TopicNotFound(this.topicId);
  final String topicId;

  @override
  String toString() => 'TopicNotFound($topicId)';
}

/// DT_Topic: one topic's measured accuracy and its lessons.
class TopicDetail {
  TopicDetail({
    required this.topicId,
    required this.name,
    required this.subject,
    required this.correct,
    required this.answered,
    required List<TopicLesson> lessons,
  }) : lessons = List.unmodifiable(lessons);
  final String topicId;
  final String name;
  final String subject;
  final int correct;
  final int answered;
  final List<TopicLesson> lessons;

  int get lessonsRead => lessons.where((l) => l.read).length;
}

/// Today's planned lesson ids. A plan that cannot be read only removes the
/// "Today" tags; it never fails the topic page.
final todayLessonIdsProvider =
    FutureProvider.autoDispose.family<Set<String>, String>((ref, examId) async {
  try {
    if (ref.watch(studyUsesServerProvider)) {
      final today = await ref.watch(serverStudyRoadmapProvider(examId).future);
      return today.today.lessonIds.toSet();
    }
    final today = await ref.watch(roadmapTodayProvider(examId).future);
    return today.snapshot.plan.lessonIds.toSet();
  } on Object {
    return const {};
  }
});

final topicDetailProvider = FutureProvider.autoDispose
    .family<TopicDetail, String>((ref, topicId) async {
  if (kIsWebStudy) return ref.watch(webTopicDetailProvider(topicId).future);
  final table = await ref.watch(
    performanceProvider(const PerformanceQuery(level: TableLevel.topic)).future,
  );
  final row = table.rows.firstWhereOrNull((r) => r.id == topicId);
  if (row == null) throw TopicNotFound(topicId);
  final examId = (await ref.watch(activeExamFocusProvider.future)).exam?.id;
  if (examId == null) throw TopicNotFound(topicId);
  final groups = await ref.watch(contentRepositoryProvider).lessonMetaByTopics(
    [topicId],
    examId: examId,
  );
  final lessonRows = groups[topicId]!;
  if (lessonRows.isEmpty) throw TopicNotFound(topicId);
  final read =
      await ref.watch(lessonProgressRepositoryProvider).readLessonIds();
  final planned = await ref.watch(todayLessonIdsProvider(examId).future);
  return TopicDetail(
    topicId: topicId,
    name: row.title,
    subject: row.subtext ?? '',
    correct: row.correct,
    answered: row.answered,
    lessons: [
      for (final l in lessonRows)
        TopicLesson(
          id: l.id,
          title: l.title,
          read: read.contains(l.id),
          today: planned.contains(l.id),
        ),
    ],
  );
});
