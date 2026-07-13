import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/attempt_item_reader.dart';
import 'package:cse_cet_reviewer/features/metrics/signals/signal_content_helpers.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

/// A topic's measured accuracy, or the fact that it is not yet measurable.
@immutable
class TopicAccuracy {
  const TopicAccuracy({
    required this.topicId,
    required this.topicName,
    required this.correct,
    required this.answered,
  });

  final TopicId topicId;
  final String topicName;
  final int correct;
  final int answered;

  /// The sample floor. Below this the row is still ranked and still
  /// tappable, and prints no figure at all.
  ///
  /// Three, because the assessment gives a contributing topic
  /// `max(1, min(3, 35 ~/ contributing))` questions: three while the bank
  /// is thin, one once all 18 topics are authored. Excluding under-measured
  /// topics from the ranking would therefore empty this panel on the day
  /// the content is finished.
  ///
  /// One constant. Moving it is a one-line change.
  static const int floor = 3;

  bool get isMeasured => answered >= floor;

  /// Null below the floor, so a caller cannot print a percentage off one
  /// question by forgetting to check.
  double? get accuracy => isMeasured ? correct / answered : null;

  @override
  bool operator ==(Object other) =>
      other is TopicAccuracy &&
      other.topicId == topicId &&
      other.topicName == topicName &&
      other.correct == correct &&
      other.answered == answered;

  @override
  int get hashCode => Object.hash(topicId, topicName, correct, answered);
}

final topicAccuracyProvider = FutureProvider<List<TopicAccuracy>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final focus = await ref.watch(activeExamFocusProvider.future);
  if (focus.needsSelection || focus.exam == null) {
    return const [];
  }
  final examId = focus.exam!.id;

  final subjectRows = await (db.select(db.subjects)
        ..where((s) => s.examId.equals(examId)))
      .get();
  final subjectIds = subjectRows.map((s) => s.id).toList();
  if (subjectIds.isEmpty) return const [];

  final topicRows = await (db.select(db.topics)
        ..where((t) => t.subjectId.isIn(subjectIds)))
      .get();
  if (topicRows.isEmpty) return const [];

  final topicMap = {for (final t in topicRows) t.id: t.name};

  final attemptRows = await (db.select(db.attemptsLocal)
        ..where((a) => a.examId.equals(examId) & a.completedAt.isNotNull()))
      .get();

  const reader = AttemptItemReader();
  final helpers = SignalContentHelpers(db);

  final topicCorrect = <String, int>{for (final id in topicMap.keys) id: 0};
  final topicAnswered = <String, int>{for (final id in topicMap.keys) id: 0};

  for (final attempt in attemptRows) {
    final items = reader.read(attempt.itemsJson);
    for (final item in items) {
      final topicId = await helpers.topicIdForQuestion(item.questionId);
      if (topicId != null && topicMap.containsKey(topicId)) {
        topicAnswered[topicId] = (topicAnswered[topicId] ?? 0) + 1;
        if (item.isCorrect) {
          topicCorrect[topicId] = (topicCorrect[topicId] ?? 0) + 1;
        }
      }
    }
  }

  final results = <TopicAccuracy>[
    for (final topic in topicRows)
      TopicAccuracy(
        topicId: topic.id,
        topicName: topic.name,
        correct: topicCorrect[topic.id] ?? 0,
        answered: topicAnswered[topic.id] ?? 0,
      ),
  ];

  results.sort((a, b) {
    final aZero = a.answered == 0;
    final bZero = b.answered == 0;
    if (aZero && bZero) return 0;
    if (aZero) return 1;
    if (bZero) return -1;

    final aRatio = a.correct / a.answered;
    final bRatio = b.correct / b.answered;
    final cmp = aRatio.compareTo(bRatio);
    if (cmp != 0) return cmp;
    return a.answered.compareTo(b.answered);
  });

  return results;
});
