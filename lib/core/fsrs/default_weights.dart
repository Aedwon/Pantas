// FSRS-6 default 21-parameter weight vector and algorithm constants.
// Source: open-spaced-repetition/fsrs4anki, FSRS-6 release.
// w[0..3]   initial stability for Again, Hard, Good, Easy
// w[4]      initial difficulty anchor
// w[5]      initial-difficulty slope
// w[6]      difficulty step per rating delta
// w[7]      mean-reversion weight on difficulty
// w[8..10]  success-stability factors
// w[11..14] failure (lapse) stability factors
// w[15]     hard-rating penalty multiplier
// w[16]     easy-rating bonus multiplier
// w[17..19] short-term (same-day) stability factors
// w[20]     decay exponent (DECAY = -w[20])
//
// Targets retention 0.9 at t == stability.

import 'dart:math' as math;

const List<double> kFsrsDefaultWeights = [
  0.212, // w0
  1.2931, // w1
  2.3065, // w2
  8.2956, // w3
  6.4133, // w4
  0.8334, // w5
  3.0194, // w6
  0.001, // w7
  1.8722, // w8
  0.1666, // w9
  0.796, // w10
  1.4835, // w11
  0.0614, // w12
  0.2629, // w13
  1.6483, // w14
  0.6014, // w15
  1.8729, // w16
  0.5425, // w17
  0.0912, // w18
  0.0658, // w19
  0.1542, // w20
];

/// Retrievability decay exponent derived from w[20].
double fsrsDecay(double w20) => -w20;

/// Retrievability factor derived from w[20], ensuring R(S) == 0.9.
double fsrsFactor(double w20) =>
    math.pow(0.9, 1.0 / fsrsDecay(w20)).toDouble() - 1.0;

/// Default target retention: optimal interval is the t where R(t, S) == this.
const double kFsrsTargetRetention = 0.9;

/// Parameter bounds.
const double kFsrsMinDecay = 0.1;
const double kFsrsMaxDecay = 0.8;
const double kFsrsMaxInitialStability = 100;

/// Difficulty bounds.
// ignore: prefer_int_literals
const double kFsrsMinDifficulty = 1.0;
// ignore: prefer_int_literals
const double kFsrsMaxDifficulty = 10.0;

/// Stability bounds (days).
const double kFsrsMinStability = 0.1;
// ignore: prefer_int_literals
const double kFsrsMaxStability = 36500.0;
