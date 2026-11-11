import 'package:pantas/features/quiz/domain/picker/practice_index.dart';
import 'package:pantas/features/quiz/domain/picker/practice_selection.dart';

enum PracticeUnitMode { questions, minutes }

/// The starting estimate was explicitly approved in D-166.
const initialPracticeResponseMs = 50000;

class PracticeSummary {
  const PracticeSummary({
    required this.totalQuestions,
    required this.perUnit,
    required this.unitCount,
    required this.shortfallCount,
    this.estimatedMinutes,
    this.countsByUnit = const {},
    this.availableByUnit = const {},
  });

  static const empty = PracticeSummary(
    totalQuestions: 0,
    perUnit: 0,
    unitCount: 0,
    shortfallCount: 0,
  );

  final int totalQuestions;
  final int perUnit;
  final int unitCount;
  final int shortfallCount;
  final int? estimatedMinutes;
  final Map<String, int> countsByUnit;
  final Map<String, int> availableByUnit;

  bool get isEmpty => unitCount == 0;

  String get headline {
    final questions =
        '$totalQuestions question${totalQuestions == 1 ? '' : 's'}';
    final minutes = estimatedMinutes;
    return minutes == null ? questions : '$questions · about $minutes min';
  }

  // Only the retired picker consumes these lines, until Task 9 removes it.
  String get detail {
    if (isEmpty) return 'Pick a topic or a lesson above.';
    final base = unitCount == 1
        ? '$perUnit from 1 selection'
        : '$perUnit from each of $unitCount selections';
    return shortfallCount == 0 ? base : '$base, $shortfallCount had fewer';
  }
}

abstract final class BuildPracticeSummary {
  static int effectiveResponseMs(int? measured) =>
      measured == null || measured <= 0 ? initialPracticeResponseMs : measured;

  /// Matches the real capped question count. Ties use the lower wheel value.
  static int? closestValue({
    required List<PracticeUnit> units,
    required PracticeIndex index,
    required int totalQuestions,
    required Iterable<int> values,
    required PracticeUnitMode mode,
    int? averageResponseMs,
  }) {
    if (units.isEmpty) return null;
    int? best;
    int? distance;
    for (final value in values) {
      final candidate = call(
        units: units,
        index: index,
        wheelValue: value,
        mode: mode,
        averageResponseMs: averageResponseMs,
      );
      if (candidate.totalQuestions < units.length) continue;
      final nextDistance = (candidate.totalQuestions - totalQuestions).abs();
      if (distance == null ||
          nextDistance < distance ||
          (nextDistance == distance && (best == null || value < best))) {
        best = value;
        distance = nextDistance;
      }
    }
    return best;
  }

  static PracticeSummary call({
    required List<PracticeUnit> units,
    required PracticeIndex index,
    required int wheelValue,
    required PracticeUnitMode mode,
    int? averageResponseMs,
    Map<String, int> adjustments = const {},
  }) {
    if (units.isEmpty) return PracticeSummary.empty;
    final pace = effectiveResponseMs(averageResponseMs);
    final budget = mode == PracticeUnitMode.questions
        ? wheelValue * units.length
        : (wheelValue * 60000) ~/ pace;
    final perUnit = budget ~/ units.length;
    final remainder = budget % units.length;
    final available = <String, int>{};
    for (final topic in index.allTopics) {
      available[PracticeUnit(topicId: topic.id).key] = topic.questionCount;
      for (final lesson in topic.lessons) {
        available[PracticeUnit(topicId: topic.id, lessonId: lesson.id).key] =
            lesson.questionCount;
      }
    }
    final counts = <String, int>{};
    final selectedAvailable = <String, int>{};
    var shortfall = 0;
    for (final (i, unit) in units.indexed) {
      final capacity = available[unit.key] ?? 0;
      final asked = adjustments[unit.key] ??
          (mode == PracticeUnitMode.minutes && budget < units.length
              ? 0
              : perUnit + (i < remainder ? 1 : 0));
      if (capacity < asked) shortfall++;
      counts[unit.key] = asked.clamp(0, capacity);
      selectedAvailable[unit.key] = capacity;
    }
    final total = counts.values.fold<int>(0, (n, count) => n + count);
    if (mode == PracticeUnitMode.minutes && adjustments.isNotEmpty) {
      final base = call(
        units: units,
        index: index,
        wheelValue: wheelValue,
        mode: mode,
        averageResponseMs: averageResponseMs,
      );
      // Saved splits may outlive a pool or measured-pace change.
      if (total != base.totalQuestions) return base;
    }

    return PracticeSummary(
      totalQuestions: total,
      perUnit: mode == PracticeUnitMode.questions ? wheelValue : perUnit,
      unitCount: units.length,
      shortfallCount: shortfall,
      estimatedMinutes: mode == PracticeUnitMode.minutes
          ? wheelValue
          : (total * pace / 60000).round(),
      countsByUnit: Map.unmodifiable(counts),
      availableByUnit: Map.unmodifiable(selectedAvailable),
    );
  }

  static Map<String, int>? adjust(
    PracticeSummary summary,
    Set<String> groupKeys,
    int delta, {
    required bool preserveTotal,
  }) {
    assert(delta == 1 || delta == -1, 'A step changes one question.');
    final counts = Map<String, int>.of(summary.countsByUnit);
    String? destination({required bool inGroup, required int direction}) {
      final eligible = counts.keys
          .where(
            (key) =>
                groupKeys.contains(key) == inGroup &&
                (direction > 0
                    ? counts[key]! < summary.availableByUnit[key]!
                    : counts[key]! > 1),
          )
          .toList();
      if (eligible.isEmpty) return null;
      eligible.sort(
        (a, b) => direction > 0
            ? counts[a]!.compareTo(counts[b]!)
            : counts[b]!.compareTo(counts[a]!),
      );
      return eligible.first;
    }

    final own = destination(inGroup: true, direction: delta);
    if (own == null) return null;
    final other =
        preserveTotal ? destination(inGroup: false, direction: -delta) : null;
    if (preserveTotal && other == null) return null;
    counts[own] = counts[own]! + delta;
    if (other != null) counts[other] = counts[other]! - delta;
    return Map.unmodifiable(counts);
  }
}
