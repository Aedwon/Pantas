/// What an age means for access to Pantas.
enum AgeOutcome {
  /// Below the exam's minimum age.
  underMinimum,

  /// Under 18. A parent or guardian must agree.
  minor,

  /// 18 or older.
  adult,
}

/// The age rules, kept free of any screen so each can be tested.
///
/// The student gives an exact age, so there is no ambiguous case: below the
/// minimum is blocked, under 18 is a minor, and 18 or older is an adult.
class AgePolicy {
  const AgePolicy({this.minimumAge = _defaultMinimumAge});

  /// The minimum age is set per exam, so a later exam (PSHS-NCE) can lower it.
  /// Every current exam uses 13.
  factory AgePolicy.forExam(String? examId) =>
      AgePolicy(minimumAge: _minimumAgeByExam[examId] ?? _defaultMinimumAge);

  static const adultAge = 18;
  static const _defaultMinimumAge = 13;
  static const _minimumAgeByExam = <String, int>{
    'exam_cse_pro': 13,
    'exam_cse_sub': 13,
  };

  final int minimumAge;

  AgeOutcome evaluateAge(int age) {
    if (age < minimumAge) return AgeOutcome.underMinimum;
    if (age < adultAge) return AgeOutcome.minor;
    return AgeOutcome.adult;
  }
}
