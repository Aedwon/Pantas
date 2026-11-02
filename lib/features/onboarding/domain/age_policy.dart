/// What a birth year means for access to Pantas.
enum AgeOutcome {
  /// Even the older possible age is below the exam's minimum.
  underMinimum,

  /// Under 18, or possibly under 18. A parent or guardian must agree.
  minor,

  /// Certainly 18 or older.
  adult,
}

/// The birth-year rules, kept free of any screen so each can be tested.
///
/// Only a birth year is asked, so the real age is one of two values. The
/// student is treated as the older age when checking the minimum, and as the
/// younger age when checking for adulthood: a year that could mean 17 or 18
/// counts as a minor.
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

  AgeOutcome evaluate({required int birthYear, required int currentYear}) {
    final olderAge = currentYear - birthYear;
    final youngerAge = olderAge - 1;
    if (olderAge < minimumAge) return AgeOutcome.underMinimum;
    if (youngerAge < adultAge) return AgeOutcome.minor;
    return AgeOutcome.adult;
  }
}
