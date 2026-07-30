import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';

class CoverageBreadthSignal implements Signal<CoveragePct> {
  const CoverageBreadthSignal(this._db, this._contentDb);

  final AppDatabase _db;
  final ContentDatabase _contentDb;

  @override
  int get minDataPoints => 1;

  @override
  Set<MetricsWindow> get supportedWindows => {MetricsWindow.allTime};

  @override
  Future<CoveragePct?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final subjects = await (_contentDb.select(_contentDb.contentSubjects)
          ..where((subject) => subject.examId.equals(examId)))
        .get();
    final subjectIds = subjects.map((subject) => subject.id).toSet();
    final topics = await _contentDb.select(_contentDb.contentTopics).get();
    final examTopics = topics
        .where((topic) => subjectIds.contains(topic.subjectId))
        .map((topic) => topic.id)
        .toSet();
    if (examTopics.isEmpty) return null;

    final covered = <String>{};
    final progress = await _db.select(_db.lessonProgressLocal).get();
    for (final row in progress) {
      final lesson = await (_contentDb.select(_contentDb.contentLessons)
            ..where((lesson) => lesson.id.equals(row.lessonId)))
          .getSingleOrNull();
      if (lesson != null && examTopics.contains(lesson.topicId)) {
        covered.add(lesson.topicId);
      }
    }
    return CoveragePct(
      coveredTopics: covered.length,
      totalTopics: examTopics.length,
    );
  }
}
