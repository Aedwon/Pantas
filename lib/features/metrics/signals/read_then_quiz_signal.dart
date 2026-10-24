import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
import 'package:pantas/features/metrics/signals/metric_calculations.dart';
import 'package:pantas/features/metrics/signals/signal_content_helpers.dart';

class ReadThenQuizSignal implements Signal<WorkflowRatio> {
  ReadThenQuizSignal(this._db, this._contentDb)
      : _reader = const AttemptItemReader(),
        _content = SignalContentHelpers(_contentDb);

  final AppDatabase _db;
  final ContentDatabase _contentDb;
  final AttemptItemReader _reader;
  final SignalContentHelpers _content;

  @override
  int get minDataPoints => 14;

  @override
  Set<MetricsWindow> get supportedWindows => {MetricsWindow.prepWindow};

  @override
  Future<WorkflowRatio?> compute({
    required ResolvedMetricsWindow window,
    required String examId,
  }) async {
    if (!window.hasEnoughData) return null;
    final observedAttempts = <({String topicId, DateTime startedAt})>[];
    final attempts = await (_db.select(_db.attemptsLocal)
          ..where(
            (row) => row.examId.equals(examId) & row.completedAt.isNotNull(),
          ))
        .get();
    for (final attempt in attempts) {
      for (final item in _reader.read(attempt.itemsJson)) {
        final topicId = await _content.topicIdForQuestion(item.questionId);
        if (topicId == null) continue;
        observedAttempts.add((topicId: topicId, startedAt: attempt.startedAt));
      }
    }

    final reads = <({String topicId, DateTime readAt, bool inExam})>[];
    final progress = await _db.select(_db.lessonProgressLocal).get();
    for (final row in progress) {
      final lesson = await (_contentDb.select(_contentDb.contentLessons)
            ..where((lesson) => lesson.id.equals(row.lessonId)))
          .getSingleOrNull();
      if (lesson == null) continue;
      final topic = await _content.topic(lesson.topicId);
      final subject =
          topic == null ? null : await _content.subject(topic.subjectId);
      reads.add(
        (
          topicId: lesson.topicId,
          readAt: row.readAt,
          inExam: subject?.examId == examId
        ),
      );
    }
    return MetricCalculations.workflow(
      attempts: observedAttempts,
      lessons: reads,
      allowEmpty: window.minSessionCount == 0,
    );
  }
}
