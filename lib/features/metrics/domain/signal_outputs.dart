class DayHourBucket {
  const DayHourBucket({
    required this.hour,
    required this.correct,
    required this.total,
  });

  final int hour;
  final int correct;
  final int total;

  double get accuracy => total == 0 ? 0 : correct / total;
}

class DayHourHistogram {
  const DayHourHistogram({required this.buckets});

  final List<DayHourBucket> buckets;
}

class DurationDistribution {
  const DurationDistribution({
    required this.averageMinutes,
    required this.sessionCount,
  });

  final double averageMinutes;
  final int sessionCount;
}

class StreakPattern {
  const StreakPattern({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.weekdayCounts,
  });

  final int currentStreakDays;
  final int longestStreakDays;
  final Map<int, int> weekdayCounts;
}

class LatencyDistribution {
  const LatencyDistribution({
    required this.averageMs,
    required this.correctAverageMs,
    required this.incorrectAverageMs,
    required this.sampleCount,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.correctLogMean = 0,
    this.incorrectLogMean = 0,
    this.correctLogVariance = 0,
    this.incorrectLogVariance = 0,
  });

  final double averageMs;
  final double correctAverageMs;
  final double incorrectAverageMs;

  /// How many answers the averages are drawn from.
  ///
  /// A caller that turns this into a claim about a student needs to know
  /// whether there is a distribution here or a single number wearing one.
  final int sampleCount;
  final int correctCount;
  final int incorrectCount;
  final double correctLogMean;
  final double incorrectLogMean;
  final double correctLogVariance;
  final double incorrectLogVariance;
}

class PacingProfile {
  const PacingProfile({
    required this.averageSpareSeconds,
    required this.sectionTimeSeconds,
  });

  final double averageSpareSeconds;
  final Map<String, int> sectionTimeSeconds;
}

class StaminaDelta {
  const StaminaDelta({
    required this.firstHalfAccuracy,
    required this.secondHalfAccuracy,
    this.firstHalfCorrect = 0,
    this.firstHalfTotal = 0,
    this.secondHalfCorrect = 0,
    this.secondHalfTotal = 0,
  });

  final double firstHalfAccuracy;
  final double secondHalfAccuracy;

  double get delta => secondHalfAccuracy - firstHalfAccuracy;
  final int firstHalfCorrect;
  final int firstHalfTotal;
  final int secondHalfCorrect;
  final int secondHalfTotal;
}

class FlagRevisitRatio {
  const FlagRevisitRatio({
    required this.flaggedCount,
    required this.revisitedCount,
  });

  final int flaggedCount;
  final int revisitedCount;

  double get ratio => flaggedCount == 0 ? 0 : revisitedCount / flaggedCount;
}

class SubjectAccuracySpeed {
  const SubjectAccuracySpeed({required this.subjects});

  final Map<String, SubjectAccuracySpeedRow> subjects;
}

class SubjectAccuracySpeedRow {
  const SubjectAccuracySpeedRow({
    required this.correct,
    required this.total,
    required this.averageMs,
  });

  final int correct;
  final int total;
  final double averageMs;

  double get accuracy => total == 0 ? 0 : correct / total;
}

class PressureDelta {
  const PressureDelta({
    required this.practiceAccuracy,
    required this.mockAccuracy,
    this.practiceCorrect = 0,
    this.practiceTotal = 0,
    this.mockCorrect = 0,
    this.mockTotal = 0,
  });

  final double practiceAccuracy;
  final double mockAccuracy;

  double get delta => mockAccuracy - practiceAccuracy;
  final int practiceCorrect;
  final int practiceTotal;
  final int mockCorrect;
  final int mockTotal;
}

class CalibrationCurve {
  const CalibrationCurve({required this.points});

  final List<CalibrationPoint> points;
}

class CalibrationPoint {
  const CalibrationPoint({
    required this.difficulty,
    required this.averageMs,
    required this.accuracy,
  });

  final double difficulty;
  final double averageMs;
  final double accuracy;
}

class WorkflowRatio {
  const WorkflowRatio({
    required this.readThenQuizCount,
    required this.quizFirstCount,
    this.readLessonCount = 0,
    this.practicedTopicCount = 0,
  });

  final int readThenQuizCount;
  final int quizFirstCount;
  final int readLessonCount;
  final int practicedTopicCount;

  double get ratio {
    final total = readThenQuizCount + quizFirstCount;
    return total == 0 ? 0 : readThenQuizCount / total;
  }
}

class RetentionCurve {
  const RetentionCurve({
    required this.averageStability,
    required this.lapseRate,
    this.lapseCount = 0,
    this.reviewCount = 0,
  });

  final double averageStability;
  final double lapseRate;
  final int lapseCount;
  final int reviewCount;
}

class CoveragePct {
  const CoveragePct({
    required this.coveredTopics,
    required this.totalTopics,
  });

  final int coveredTopics;
  final int totalTopics;

  double get percent => totalTopics == 0 ? 0 : coveredTopics / totalTopics;
}
