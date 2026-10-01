import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/metrics/domain/signal_outputs.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';

void main() {
  test('pooled z-test: 60/100 vs 40/100 gives z=sqrt(8)', () {
    // Pooled p=0.5, SE=sqrt(0.25*(1/100+1/100)).
    final result = TendencyStatistics.twoProportion(60, 100, 40, 100);
    expect(result.statistic, closeTo(math.sqrt(8), 1e-12));
    expect(result.pValue, closeTo(0.004677734981, 1e-7));
    expect(
      TendencyStatistics.twoProportion(40, 100, 60, 100).pValue,
      closeTo(result.pValue, 1e-12),
    );
    expect(TendencyStatistics.twoProportion(50, 100, 50, 100).pValue, 1);
  });

  test('Welch uses unequal variances and Satterthwaite degrees of freedom', () {
    // Means 10,12; variances 4,9; n=10,20. SE=sqrt(.85),
    // df=.85^2/(.4^2/9+.45^2/19)=25.408226221079683.
    final result = TendencyStatistics.welch(
      meanA: 10,
      varianceA: 4,
      countA: 10,
      meanB: 12,
      varianceB: 9,
      countB: 20,
    );
    expect(result!.statistic, closeTo(-2 / math.sqrt(0.85), 1e-12));
    expect(result.degreesOfFreedom, closeTo(25.408226221079683, 1e-9));
    expect(result.pValue, closeTo(0.03961077803595725, 1e-9));
  });

  test('Student t CDF uses textbook critical values and symmetry', () {
    // df=1 is Cauchy: F(1)=.75. df=10 t(.975)=2.228138851965.
    expect(TendencyStatistics.studentTCdf(1, 1), closeTo(0.75, 1e-12));
    expect(TendencyStatistics.studentTCdf(-1, 1), closeTo(0.25, 1e-12));
    expect(TendencyStatistics.studentTCdf(0, 10), 0.5);
    expect(
      TendencyStatistics.studentTCdf(2.228138851965, 10),
      closeTo(0.975, 1e-11),
    );
    expect(
      TendencyStatistics.studentTCdf(1.95996398454, 1000000),
      closeTo(0.975, 2e-7),
    );
  });

  test('exact binomial: n=10, k=9 is 2*(1+10)/1024', () {
    expect(TendencyStatistics.binomial(9, 10), closeTo(22 / 1024, 1e-14));
    expect(TendencyStatistics.binomial(1, 10), closeTo(22 / 1024, 1e-14));
    expect(TendencyStatistics.binomial(10, 10), closeTo(2 / 1024, 1e-14));
    expect(TendencyStatistics.binomial(5, 10), 1);
    expect(TendencyStatistics.binomial(500, 1000), 1);
    expect(TendencyStatistics.binomial(0, 10000), 0);
  });

  test('Wilson: 50/100 gives .4038315304 to .5961684696', () {
    // z=1.95996398454, center=.5, half-width=.096168469634.
    final interval = TendencyStatistics.wilson(50, 100);
    expect(interval.lower, closeTo(0.403831530366, 1e-11));
    expect(interval.upper, closeTo(0.596168469634, 1e-11));
    expect(interval.halfWidth, closeTo(0.096168469634, 1e-11));
    // Zero/all successes stay in [0,1], upper/lower = z^2/(n+z^2).
    expect(TendencyStatistics.wilson(0, 10).lower, closeTo(0, 1e-14));
    expect(
      TendencyStatistics.wilson(0, 10).upper,
      closeTo(0.277532799863, 1e-11),
    );
    expect(TendencyStatistics.wilson(10, 10).upper, closeTo(1, 1e-14));
  });

  test('pressure and stamina need five successes and failures on each side',
      () {
    for (final counts in [
      (4, 10, 5, 10),
      (5, 9, 5, 10),
      (5, 10, 4, 10),
      (5, 10, 5, 9),
    ]) {
      expect(
        TendencyEvidence.proportions(
          counts.$1,
          counts.$2,
          counts.$3,
          counts.$4,
        ),
        TendencyConfidence.early,
      );
    }
    expect(
      TendencyEvidence.proportions(5, 10, 5, 10),
      TendencyConfidence.forming,
    );
    expect(
      TendencyEvidence.proportions(60, 100, 40, 100),
      TendencyConfidence.clear,
    );
    // z=1.95161 => p>.05; z=1.97990 => p<.05.
    expect(
      TendencyEvidence.proportions(5069, 10000, 4931, 10000),
      TendencyConfidence.forming,
    );
    expect(
      TendencyEvidence.proportions(5070, 10000, 4930, 10000),
      TendencyConfidence.clear,
    );
  });

  test('speed needs 30 per side and compares log times', () {
    LatencyDistribution speed(int correct, int wrong, double wrongMean) =>
        LatencyDistribution(
          averageMs: 1,
          correctAverageMs: 1,
          incorrectAverageMs: 1,
          sampleCount: correct + wrong,
          correctCount: correct,
          incorrectCount: wrong,
          correctLogMean: 1,
          incorrectLogMean: wrongMean,
          correctLogVariance: 1,
          incorrectLogVariance: 1,
        );
    expect(TendencyEvidence.speed(speed(29, 30, 4)), TendencyConfidence.early);
    expect(TendencyEvidence.speed(speed(30, 29, 4)), TendencyConfidence.early);
    expect(
      TendencyEvidence.speed(speed(30, 30, 1)),
      TendencyConfidence.forming,
    );
    expect(TendencyEvidence.speed(speed(30, 30, 2)), TendencyConfidence.clear);
    // df=58, t=.5*sqrt(15)=1.936 is below the .975 critical value.
    expect(
      TendencyEvidence.speed(speed(30, 30, 1.5)),
      TendencyConfidence.forming,
    );
    expect(
      TendencyEvidence.speed(speed(30, 30, 1.6)),
      TendencyConfidence.clear,
    );
  });

  for (final (varianceA, varianceB) in [
    (0.0, 0.0),
    (0.0, 1.0),
    (1.0, 0.0),
    (1e-200, 1e-200),
  ]) {
    test('undefined Welch is unavailable: $varianceA, $varianceB', () {
      // Exact review case: 30 times at 1s versus 30 at 2s. The tiny
      // positive variances also make the df calculation nonfinite.
      final result = TendencyStatistics.welch(
        meanA: math.log(1000),
        varianceA: varianceA,
        countA: 30,
        meanB: math.log(2000),
        varianceB: varianceB,
        countB: 30,
      );
      expect(result, isNull);
      expect(
        TendencyEvidence.speed(
          LatencyDistribution(
            averageMs: 1500,
            correctAverageMs: 1000,
            incorrectAverageMs: 2000,
            sampleCount: 60,
            correctCount: 30,
            incorrectCount: 30,
            correctLogMean: math.log(1000),
            incorrectLogMean: math.log(2000),
            correctLogVariance: varianceA,
            incorrectLogVariance: varianceB,
          ),
        ),
        TendencyConfidence.forming,
      );
    });
  }

  test('study validity boundary is 10 lessons, including a zero category', () {
    expect(
      TendencyEvidence.study(
        const WorkflowRatio(readThenQuizCount: 9, quizFirstCount: 0),
      ),
      TendencyConfidence.early,
    );
    expect(
      TendencyEvidence.study(
        const WorkflowRatio(readThenQuizCount: 5, quizFirstCount: 5),
      ),
      TendencyConfidence.forming,
    );
    expect(
      TendencyEvidence.study(
        const WorkflowRatio(readThenQuizCount: 9, quizFirstCount: 1),
      ),
      TendencyConfidence.clear,
    );
    expect(
      TendencyEvidence.study(
        const WorkflowRatio(readThenQuizCount: 0, quizFirstCount: 10),
      ),
      TendencyConfidence.clear,
    );
  });

  test('memory needs 10 reviews and Wilson half-width at most five points', () {
    RetentionCurve memory(int lapses, int reviews) => RetentionCurve(
          averageStability: 9,
          lapseRate: lapses / reviews,
          lapseCount: lapses,
          reviewCount: reviews,
        );
    expect(TendencyEvidence.memory(memory(0, 9)), TendencyConfidence.early);
    expect(TendencyEvidence.memory(memory(0, 10)), TendencyConfidence.forming);
    // With zero lapses, half-width=z^2/(2*(n+z^2)): crosses at n=35.
    expect(TendencyEvidence.memory(memory(0, 34)), TendencyConfidence.forming);
    expect(TendencyEvidence.memory(memory(0, 35)), TendencyConfidence.clear);
    expect(
      TendencyEvidence.memory(memory(190, 380)),
      TendencyConfidence.forming,
    );
    expect(TendencyEvidence.memory(memory(191, 382)), TendencyConfidence.clear);
  });
}
