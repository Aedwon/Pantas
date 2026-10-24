import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
import 'package:pantas/features/home/application/web_study_seam.dart';

class PerformanceViewData {
  const PerformanceViewData({
    required this.subjects,
    required this.topics,
    required this.lessons,
    required this.subjectCounts,
    required this.lessonLevelAvailable,
    this.parentSubjectIds = const {},
  });
  final List<PerformanceRow> subjects;
  final List<PerformanceRow> topics;
  final List<PerformanceRow> lessons;
  final Map<String, int> subjectCounts;
  final bool lessonLevelAvailable;
  final Map<String, String> parentSubjectIds;
}

/// Everything the performance screen reads on native: the three table levels
/// from the one performance query (every finished session counts, whatever its
/// origin), plus each topic's and lesson's parent subject from the authored
/// content. Counts are of what the screen shows, so a subject's topic count
/// is its topics with at least one answer.
final performanceViewProvider =
    FutureProvider<PerformanceViewData>((ref) async {
  if (kIsWebStudy) return ref.watch(webPerformanceViewProvider.future);
  final subjects = await ref.watch(
    performanceProvider(const PerformanceQuery(level: TableLevel.subject))
        .future,
  );
  final topics = await ref.watch(
    performanceProvider(const PerformanceQuery(level: TableLevel.topic)).future,
  );
  final lessons = await ref.watch(
    performanceProvider(const PerformanceQuery(level: TableLevel.lesson))
        .future,
  );
  final subjectIds = [for (final row in subjects.rows) row.id];
  final contentDb = ref.watch(contentDatabaseProvider);
  final topicRows = await (contentDb.select(contentDb.contentTopics)
        ..where((t) => t.subjectId.isIn(subjectIds)))
      .get();
  final subjectOfTopic = {for (final t in topicRows) t.id: t.subjectId};
  final lessonRows = await (contentDb.select(contentDb.contentLessons)
        ..where((l) => l.topicId.isIn(subjectOfTopic.keys)))
      .get();
  final parents = <String, String>{
    ...subjectOfTopic,
    for (final l in lessonRows)
      if (subjectOfTopic[l.topicId] != null) l.id: subjectOfTopic[l.topicId]!,
  };
  final counts = <String, int>{};
  for (final row in topics.rows.where((r) => r.answered > 0)) {
    final subject = parents[row.id];
    if (subject != null) counts[subject] = (counts[subject] ?? 0) + 1;
  }
  return PerformanceViewData(
    subjects: subjects.rows,
    topics: topics.rows,
    lessons: lessons.lessonLevelAvailable ? lessons.rows : const [],
    subjectCounts: counts,
    lessonLevelAvailable: lessons.lessonLevelAvailable,
    parentSubjectIds: parents,
  );
});
