import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/lesson_progress_repository.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';

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
          ..where(
            (subject) =>
                subject.examId.equals(examId) & subject.isActive.equals(true),
          ))
        .get();
    final subjectIds = subjects.map((subject) => subject.id).toSet();
    final topics = await (_contentDb.select(_contentDb.contentTopics)
          ..where((topic) => topic.isActive.equals(true)))
        .get();
    final examTopics = topics
        .where((topic) => subjectIds.contains(topic.subjectId))
        .map((topic) => topic.id)
        .toSet();
    if (examTopics.isEmpty) return null;

    final covered = <String>{};
    final read =
        await LessonProgressRepository(_db, _contentDb).readLessonIds();
    final lessons = await (_contentDb.select(_contentDb.contentLessons)
          ..where((l) => l.id.isIn(read)))
        .get();
    for (final lesson in lessons) {
      if (examTopics.contains(lesson.topicId)) covered.add(lesson.topicId);
    }
    return MetricCalculations.coverage(examTopics, covered);
  }
}
