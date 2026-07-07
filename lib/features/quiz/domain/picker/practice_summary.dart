import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_index.dart';
import 'package:cse_cet_reviewer/features/quiz/domain/picker/practice_selection.dart';

enum PracticeUnitMode { questions, minutes }

/// What the footer says, updating on every tick and every scroll.
class PracticeSummary {
  const PracticeSummary({
    required this.totalQuestions,
    required this.perUnit,
    required this.unitCount,
    required this.shortfallCount,
    this.estimatedMinutes,
  });

  static const empty = PracticeSummary(
    totalQuestions: 0,
    perUnit: 0,
    unitCount: 0,
    shortfallCount: 0,
  );

  final int totalQuestions;

  /// Questions asked of each selection. Per selection, never a total: a total
  /// cannot be split at all when five is asked across six topics.
  final int perUnit;

  final int unitCount;

  /// How many pools held fewer than was asked of them.
  final int shortfallCount;

  /// Null until the student's pace has been measured. Never a figure derived
  /// from anything but their own finished attempts.
  final int? estimatedMinutes;

  bool get isEmpty => unitCount == 0;

  String get headline {
    final questions =
        '$totalQuestions question${totalQuestions == 1 ? '' : 's'}';
    final minutes = estimatedMinutes;
    if (minutes == null) return questions;
    return '$questions · about $minutes min';
  }

  String get detail {
    if (isEmpty) return 'Pick a topic or a lesson above.';
    final base = unitCount == 1
        ? '$perUnit from 1 selection'
        : '$perUnit from each of $unitCount selections';
    if (shortfallCount == 0) return base;
    return '$base, $shortfallCount had fewer';
  }
}

abstract final class BuildPracticeSummary {
  static PracticeSummary call({
    required List<PracticeUnit> units,
    required PracticeIndex index,
    required int wheelValue,
    required PracticeUnitMode mode,
    int? averageResponseMs,
  }) {
    if (units.isEmpty) return PracticeSummary.empty;

    final perUnit = switch (mode) {
      PracticeUnitMode.questions => wheelValue,
      // Minutes mode is unreachable while the pace is null, so this branch
      // only runs with a measured average. Returning zero rather than
      // guessing keeps the footer honest if it is ever reached anyway.
      PracticeUnitMode.minutes =>
        averageResponseMs == null || averageResponseMs == 0
            ? 0
            : (wheelValue * 60000 / averageResponseMs).floor(),
    };

    final pools = _poolSizes(index);
    var total = 0;
    var shortfall = 0;
    for (final unit in units) {
      final available = pools[_key(unit)] ?? 0;
      if (available < perUnit) shortfall++;
      total += available < perUnit ? available : perUnit;
    }

    return PracticeSummary(
      totalQuestions: total,
      perUnit: perUnit,
      unitCount: units.length,
      shortfallCount: shortfall,
      estimatedMinutes: averageResponseMs == null || total == 0
          ? null
          : (total * averageResponseMs / 60000).round(),
    );
  }

  static String _key(PracticeUnit unit) => unit.lessonId == null
      ? 'topic:${unit.topicId}'
      : 'lesson:${unit.lessonId}';

  static Map<String, int> _poolSizes(PracticeIndex index) {
    final sizes = <String, int>{};
    for (final topic in index.allTopics) {
      sizes['topic:${topic.id}'] = topic.questionCount;
      for (final lesson in topic.lessons) {
        sizes['lesson:${lesson.id}'] = lesson.questionCount;
      }
    }
    return sizes;
  }
}
