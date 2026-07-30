import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/progress/application/performance_provider.dart';
import 'package:pantas/features/progress/application/table_order_prefs.dart';
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

/// Home's weakest-first ranking, which is the performance table read at
/// topic level.
///
/// It counts nothing itself. Two rankings of the same data is how the app
/// tells a student a topic is weak on Home and strong on Progress. **The
/// sample floor stays a Home concern**: the table prints what it measures
/// at any sample size, because a student who opens a table chose to look.
final topicAccuracyProvider = FutureProvider<List<TopicAccuracy>>((ref) async {
  final table = await ref.watch(
    performanceProvider(
      const PerformanceQuery(level: TableLevel.topic),
    ).future,
  );

  final results = [
    for (final row in table.rows)
      TopicAccuracy(
        topicId: row.id,
        topicName: row.title,
        correct: row.correct,
        answered: row.answered,
      ),
  ];

  // ignore: cascade_invocations
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
