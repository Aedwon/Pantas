import 'dart:math' as math;

import 'package:pantas/features/metrics/domain/signal_outputs.dart';

enum TendencyConfidence { early, forming, clear }

/// Validity conditions from the approved tendency-confidence spec, Part 2.
/// Five successes and failures per side support the normal approximation;
/// 30 log times per side support the mean comparison. The exact binomial and
/// Wilson calculations use the spec's 10-observation validity floor.
/// These are test validity rules, not session-based unlock targets.
class TendencyValidity {
  const TendencyValidity._();

  static const minSuccessesAndFailures = 5;
  static const minTimesPerSide = 30;
  static const minLessons = 10;
  static const minReviews = 10;
  static const alpha = 0.05;

  /// Lead judgment recorded in the spec: precision within five points.
  static const maxLapseHalfWidth = 0.05;
}

class StatisticalTestResult {
  const StatisticalTestResult(
    this.statistic,
    this.pValue, {
    this.degreesOfFreedom,
  });

  final double statistic;
  final double pValue;
  final double? degreesOfFreedom;
}

/// Two-sided tests. No effect-size threshold is imposed.
class TendencyStatistics {
  const TendencyStatistics._();

  static const _z95 = 1.959963984540054;

  static StatisticalTestResult twoProportion(
    int correctA,
    int totalA,
    int correctB,
    int totalB,
  ) {
    _validateCounts(correctA, totalA);
    _validateCounts(correctB, totalB);
    final pooled = (correctA + correctB) / (totalA + totalB);
    final se = math.sqrt(pooled * (1 - pooled) * (1 / totalA + 1 / totalB));
    if (se == 0) return const StatisticalTestResult(0, 1);
    final z = (correctA / totalA - correctB / totalB) / se;
    return StatisticalTestResult(z, _normalTwoSided(z));
  }

  /// Welch-Satterthwaite df and Student t, not a normal approximation.
  /// Formula: https://www.itl.nist.gov/div898/handbook/eda/section3/eda353.htm
  static StatisticalTestResult? welch({
    required double meanA,
    required double varianceA,
    required int countA,
    required double meanB,
    required double varianceB,
    required int countB,
  }) {
    if (countA < 2 ||
        countB < 2 ||
        !meanA.isFinite ||
        !meanB.isFinite ||
        !varianceA.isFinite ||
        !varianceB.isFinite ||
        varianceA < 0 ||
        varianceB < 0) {
      throw ArgumentError(
        'Welch requires finite moments and two samples per side',
      );
    }
    // A constant group cannot support the approved log-time comparison.
    if (varianceA == 0 || varianceB == 0) return null;
    final a = varianceA / countA;
    final b = varianceB / countB;
    final difference = meanA - meanB;
    final t = difference / math.sqrt(a + b);
    final df =
        (a + b) * (a + b) / (a * a / (countA - 1) + b * b / (countB - 1));
    if (!df.isFinite) return null;
    // Direct tail evaluation avoids subtracting a CDF close to one.
    final p = _regularizedBeta(df / (df + t * t), df / 2, 0.5);
    return StatisticalTestResult(t, p, degreesOfFreedom: df);
  }

  static double studentTCdf(double t, double degreesOfFreedom) {
    if (degreesOfFreedom <= 0 || !degreesOfFreedom.isFinite || t.isNaN) {
      throw ArgumentError(
        'Student t requires finite positive degrees of freedom',
      );
    }
    if (t == 0) return 0.5;
    final tail = _regularizedBeta(
          degreesOfFreedom / (degreesOfFreedom + t * t),
          degreesOfFreedom / 2,
          0.5,
        ) /
        2;
    return t < 0 ? tail : 1 - tail;
  }

  /// Exact two-sided binomial against one half. Symmetry makes this twice
  /// the smaller inclusive tail, capped at one. Sum in log space so a large
  /// sample does not underflow before reaching its observed tail.
  static double binomial(int successes, int total) {
    _validateCounts(successes, total);
    final k = math.min(successes, total - successes);
    if (k == total ~/ 2) return 1;
    var logProbability = -total * math.ln2;
    var logSum = logProbability;
    for (var i = 1; i <= k; i++) {
      logProbability += math.log((total - i + 1) / i);
      final largest = math.max(logSum, logProbability);
      logSum = largest +
          math.log(
            math.exp(logSum - largest) + math.exp(logProbability - largest),
          );
    }
    return math.min(1, 2 * math.exp(logSum));
  }

  /// 95% Wilson score interval.
  /// Formula: https://www.itl.nist.gov/div898/handbook/prc/section2/prc241.htm
  static ({double lower, double upper, double halfWidth}) wilson(
    int successes,
    int total,
  ) {
    _validateCounts(successes, total);
    final p = successes / total;
    const zSquared = _z95 * _z95;
    final denominator = 1 + zSquared / total;
    final center = (p + zSquared / (2 * total)) / denominator;
    final halfWidth = _z95 *
        math.sqrt(
          p * (1 - p) / total + zSquared / (4 * total * total),
        ) /
        denominator;
    return (
      lower: math.max(0, center - halfWidth),
      upper: math.min(1, center + halfWidth),
      halfWidth: halfWidth,
    );
  }

  static void _validateCounts(int successes, int total) {
    if (total <= 0 || successes < 0 || successes > total) {
      throw ArgumentError(
        'Counts require a positive total and valid successes',
      );
    }
  }

  // Complementary error function approximation, maximum error about 1.2e-7
  // (Numerical Recipes). Computes the normal tail directly.
  static double _normalTwoSided(double z) {
    if (z == 0) return 1;
    final x = z.abs() / math.sqrt2;
    final t = 1 / (1 + 0.5 * x);
    const coefficients = [
      1.00002368,
      0.37409196,
      0.09678418,
      -0.18628806,
      0.27886807,
      -1.13520398,
      1.48851587,
      -0.82215223,
      0.17087277,
    ];
    var polynomial = coefficients.last;
    for (var i = coefficients.length - 2; i >= 0; i--) {
      polynomial = coefficients[i] + t * polynomial;
    }
    return (t * math.exp(-x * x - 1.26551223 + t * polynomial)).clamp(0.0, 1.0);
  }

  // Regularized incomplete beta, using symmetry and a modified Lentz
  // continued fraction (Numerical Recipes). Lanczos supplies log Gamma.
  static double _regularizedBeta(double x, double a, double b) {
    if (x <= 0) return 0;
    if (x >= 1) return 1;
    final scale = math.exp(
      _logGamma(a + b) -
          _logGamma(a) -
          _logGamma(b) +
          a * math.log(x) +
          b * math.log(1 - x),
    );
    final value = x < (a + 1) / (a + b + 2)
        ? scale * _betaFraction(x, a, b) / a
        : 1 - scale * _betaFraction(1 - x, b, a) / b;
    return value.clamp(0.0, 1.0);
  }

  static double _betaFraction(double x, double a, double b) {
    const tiny = 1e-300;
    double nonzero(double value) => value.abs() < tiny ? tiny : value;
    var c = 1.0;
    var d = 1 / nonzero(1 - (a + b) * x / (a + 1));
    var h = d;
    for (var m = 1; m <= 1000; m++) {
      final twice = 2 * m;
      final first = m * (b - m) * x / ((a + twice - 1) * (a + twice));
      d = 1 / nonzero(1 + first * d);
      c = nonzero(1 + first / c);
      h *= d * c;
      final second =
          -(a + m) * (a + b + m) * x / ((a + twice) * (a + twice + 1));
      d = 1 / nonzero(1 + second * d);
      c = nonzero(1 + second / c);
      final delta = d * c;
      h *= delta;
      if ((delta - 1).abs() < 3e-14) return h;
    }
    throw StateError('Incomplete beta did not converge');
  }

  static double _logGamma(double value) {
    const coefficients = [
      676.5203681218851,
      -1259.1392167224028,
      771.3234287776531,
      -176.6150291621406,
      12.507343278686905,
      -0.13857109526572012,
      9.984369578019572e-6,
      1.5056327351493116e-7,
    ];
    if (value < 0.5) {
      return math.log(math.pi) -
          math.log(math.sin(math.pi * value)) -
          _logGamma(1 - value);
    }
    final z = value - 1;
    var sum = 0.99999999999980993;
    for (var i = 0; i < coefficients.length; i++) {
      sum += coefficients[i] / (z + i + 1);
    }
    final t = z + 7.5;
    return 0.5 * math.log(2 * math.pi) +
        (z + 0.5) * math.log(t) -
        t +
        math.log(sum);
  }
}

class TendencyEvidence {
  const TendencyEvidence._();

  static TendencyConfidence _fromP(double p) => p < TendencyValidity.alpha
      ? TendencyConfidence.clear
      : TendencyConfidence.forming;

  static TendencyConfidence proportions(
    int correctA,
    int totalA,
    int correctB,
    int totalB,
  ) {
    const minimum = TendencyValidity.minSuccessesAndFailures;
    if (correctA < minimum ||
        totalA - correctA < minimum ||
        correctB < minimum ||
        totalB - correctB < minimum) {
      return TendencyConfidence.early;
    }
    return _fromP(
      TendencyStatistics.twoProportion(
        correctA,
        totalA,
        correctB,
        totalB,
      ).pValue,
    );
  }

  static TendencyConfidence pressure(PressureDelta value) => proportions(
        value.practiceCorrect,
        value.practiceTotal,
        value.mockCorrect,
        value.mockTotal,
      );

  static TendencyConfidence stamina(StaminaDelta value) => proportions(
        value.firstHalfCorrect,
        value.firstHalfTotal,
        value.secondHalfCorrect,
        value.secondHalfTotal,
      );

  static TendencyConfidence speed(LatencyDistribution value) {
    if (value.correctCount < TendencyValidity.minTimesPerSide ||
        value.incorrectCount < TendencyValidity.minTimesPerSide) {
      return TendencyConfidence.early;
    }
    final result = TendencyStatistics.welch(
      meanA: value.correctLogMean,
      varianceA: value.correctLogVariance,
      countA: value.correctCount,
      meanB: value.incorrectLogMean,
      varianceB: value.incorrectLogVariance,
      countB: value.incorrectCount,
    );
    return result == null ? TendencyConfidence.forming : _fromP(result.pValue);
  }

  static TendencyConfidence study(WorkflowRatio value) {
    final total = value.readThenQuizCount + value.quizFirstCount;
    if (total < TendencyValidity.minLessons) return TendencyConfidence.early;
    return _fromP(TendencyStatistics.binomial(value.readThenQuizCount, total));
  }

  static TendencyConfidence memory(RetentionCurve value) {
    if (value.reviewCount < TendencyValidity.minReviews) {
      return TendencyConfidence.early;
    }
    return TendencyStatistics.wilson(value.lapseCount, value.reviewCount)
                .halfWidth <=
            TendencyValidity.maxLapseHalfWidth
        ? TendencyConfidence.clear
        : TendencyConfidence.forming;
  }
}
