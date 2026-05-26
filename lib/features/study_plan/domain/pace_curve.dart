enum PaceStatus {
  behind,
  onPace,
  ahead,
}

class PaceCurve {
  const PaceCurve({
    required this.planStart,
    required this.examDate,
    required this.startMastery,
    this.targetMastery = 0.75,
    this.tolerance = 0.05,
  });

  final DateTime planStart;
  final DateTime examDate;
  final double startMastery;
  final double targetMastery;
  final double tolerance;

  double expectedMastery({required DateTime on}) {
    final normalizedStart = _dateOnly(planStart);
    final normalizedExam = _dateOnly(examDate);
    final normalizedDay = _dateOnly(on);
    if (!targetMastery.isFinite || targetMastery <= startMastery) {
      return targetMastery.clamp(0, 1).toDouble();
    }
    if (!normalizedDay.isAfter(normalizedStart)) {
      return startMastery.clamp(0, 1).toDouble();
    }
    if (!normalizedDay.isBefore(normalizedExam)) {
      return targetMastery.clamp(0, 1).toDouble();
    }

    final totalDays = normalizedExam.difference(normalizedStart).inDays;
    if (totalDays <= 0) return targetMastery.clamp(0, 1).toDouble();
    final elapsedDays = normalizedDay.difference(normalizedStart).inDays;
    final progress = elapsedDays / totalDays;
    return (startMastery + (targetMastery - startMastery) * progress)
        .clamp(0, 1)
        .toDouble();
  }

  PaceStatus status({
    required double actualMastery,
    required DateTime on,
  }) {
    if (startMastery >= targetMastery && actualMastery >= targetMastery) {
      return PaceStatus.ahead;
    }
    final expected = expectedMastery(on: on);
    if (actualMastery < expected - tolerance) return PaceStatus.behind;
    if (actualMastery > expected + tolerance) return PaceStatus.ahead;
    return PaceStatus.onPace;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
