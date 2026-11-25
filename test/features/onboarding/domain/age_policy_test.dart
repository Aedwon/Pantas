import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/onboarding/domain/age_policy.dart';

void main() {
  const policy = AgePolicy();

  test('the minimum is 18 and the adult age is 18', () {
    expect(policy.minimumAge, 18);
    expect(AgePolicy.adultAge, 18);
  });

  test('under-18 sign-up is closed while the minimum is 18', () {
    expect(AgePolicy.minorSignupOpen, isFalse);
  });

  test('17 and below is under the minimum, so no guardian step', () {
    for (final age in [5, 11, 12, 13, 14, 17]) {
      expect(policy.evaluateAge(age), AgeOutcome.underMinimum, reason: '$age');
    }
  });

  test('18 and older is an adult', () {
    for (final age in [18, 19, 40, 100]) {
      expect(policy.evaluateAge(age), AgeOutcome.adult, reason: '$age');
    }
  });

  test('the minimum age is per exam and both CSE exams use 18', () {
    expect(AgePolicy.forExam('exam_cse_pro').minimumAge, 18);
    expect(AgePolicy.forExam('exam_cse_sub').minimumAge, 18);
    expect(AgePolicy.forExam(null).minimumAge, 18);
    expect(AgePolicy.forExam('exam_unknown').minimumAge, 18);
  });

  test('a lower minimum keeps the minor branch for the day it reopens', () {
    const lower = AgePolicy(minimumAge: 13);
    expect(lower.evaluateAge(13), AgeOutcome.minor);
    expect(lower.evaluateAge(12), AgeOutcome.underMinimum);
  });
}
