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
  /// Every current exam uses 18 while under-18 sign-up is closed.
  factory AgePolicy.forExam(String? examId) =>
      AgePolicy(minimumAge: _minimumAgeByExam[examId] ?? _defaultMinimumAge);

  static const adultAge = 18;

  /// The version of the line the age step shows above the age number. It
  /// is stored with the age group and sent with the guardian request.
  static const ageCheckNoticeVersion = '2026-11-12';

  /// Whether a student under 18 can start an account, which needs a guardian.
  /// Closed since Nov 25 (option C): the minimum is 18, so 17 and below get
  /// the blocked page and no guardian step. The one number below controls it.
  /// Reopen only when guardian-first sign-up for 13 to 17 ships.
  static bool get minorSignupOpen => _defaultMinimumAge < adultAge;

  static const _defaultMinimumAge = 18;
  static const _minimumAgeByExam = <String, int>{
    'exam_cse_pro': 18,
    'exam_cse_sub': 18,
  };

  final int minimumAge;

  AgeOutcome evaluateAge(int age) {
    if (age < minimumAge) return AgeOutcome.underMinimum;
    if (age < adultAge) return AgeOutcome.minor;
    return AgeOutcome.adult;
  }
}
