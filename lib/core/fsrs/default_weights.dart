// FSRS-4.5 default 17-parameter weight vector and algorithm constants.
// Source: open-spaced-repetition/fsrs4anki, FSRS-4.5 release.
// w[0..3]   initial stability for Again, Hard, Good, Easy
// w[4]      initial difficulty anchor
// w[5]      initial-difficulty slope
// w[6]      difficulty step per rating delta
// w[7]      mean-reversion weight on difficulty
// w[8..10]  success-stability factors
// w[11..14] failure (lapse) stability factors
// w[15]     hard-rating penalty multiplier
// w[16]     easy-rating bonus multiplier
//
// Targets retention 0.9 at t == stability.

const List<double> kFsrsDefaultWeights = [
  0.4072, // w0
  1.1829, // w1
  3.1262, // w2
  15.4722, // w3
  7.2102, // w4
  0.5316, // w5
  1.0651, // w6
  0.0234, // w7
  1.6160, // w8
  0.1544, // w9
  1.0824, // w10
  1.9813, // w11
  0.0953, // w12
  0.2975, // w13
  2.2042, // w14
  0.2407, // w15
  2.9466, // w16
];

/// Retrievability decay exponent. With kFsrsFactor, R(stability) ~= 0.9.
const double kFsrsDecay = -0.5;

/// Retrievability multiplier. R(t, S) = (1 + factor * t / S) ^ decay.
const double kFsrsFactor = 19 / 81;

/// Default target retention: optimal interval is the t where R(t, S) == this.
const double kFsrsTargetRetention = 0.9;

/// Difficulty bounds.
// ignore: prefer_int_literals
const double kFsrsMinDifficulty = 1.0;
// ignore: prefer_int_literals
const double kFsrsMaxDifficulty = 10.0;

/// Stability bounds (days).
const double kFsrsMinStability = 0.1;
// ignore: prefer_int_literals
const double kFsrsMaxStability = 36500.0;
