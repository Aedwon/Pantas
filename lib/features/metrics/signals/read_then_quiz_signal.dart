import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/metrics/domain/metric_signal.dart';
import 'package:pantas/features/metrics/domain/metrics_window.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/signals/attempt_item_reader.dart';
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
    final firstAttemptByTopic = <String, DateTime>{};
    final attempts = await (_db.select(_db.attemptsLocal)
          ..where(
            (row) => row.examId.equals(examId) & row.completedAt.isNotNull(),
          ))
        .get();
    for (final attempt in attempts) {
      for (final item in _reader.read(attempt.itemsJson)) {
        final topicId = await _content.topicIdForQuestion(item.questionId);
        if (topicId == null) continue;
        final existing = firstAttemptByTopic[topicId];
        if (existing == null || attempt.startedAt.isBefore(existing)) {
          firstAttemptByTopic[topicId] = attempt.startedAt;
        }
      }
    }

    var readThenQuiz = 0;
    var quizFirst = 0;
    final progress = await _db.select(_db.lessonProgressLocal).get();
    for (final row in progress) {
      final lesson = await (_contentDb.select(_contentDb.contentLessons)
            ..where((lesson) => lesson.id.equals(row.lessonId)))
          .getSingleOrNull();
      if (lesson == null) continue;
      final firstAttempt = firstAttemptByTopic[lesson.topicId];
      if (firstAttempt == null) continue;
      if (row.readAt.isBefore(firstAttempt) || row.readAt == firstAttempt) {
        readThenQuiz += 1;
      } else {
        quizFirst += 1;
      }
    }
    if (readThenQuiz + quizFirst == 0) return null;
    return WorkflowRatio(
      readThenQuizCount: readThenQuiz,
      quizFirstCount: quizFirst,
    );
  }
}
