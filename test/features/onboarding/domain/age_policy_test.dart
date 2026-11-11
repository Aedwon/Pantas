import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/onboarding/domain/age_policy.dart';

void main() {
  const policy = AgePolicy();

  test('the minimum is 13 and the adult age is 18', () {
    expect(policy.minimumAge, 13);
    expect(AgePolicy.adultAge, 18);
  });

  test('an age below the minimum is blocked', () {
    for (final age in [5, 11, 12]) {
      expect(policy.evaluateAge(age), AgeOutcome.underMinimum, reason: '$age');
    }
  });

  test('13 to 17 is a minor, with no ambiguous year', () {
    for (final age in [13, 14, 17]) {
      expect(policy.evaluateAge(age), AgeOutcome.minor, reason: '$age');
    }
  });

  test('18 and older is an adult', () {
    for (final age in [18, 19, 40, 100]) {
      expect(policy.evaluateAge(age), AgeOutcome.adult, reason: '$age');
    }
  });

  test('the minimum age is per exam and defaults to 13', () {
    expect(AgePolicy.forExam('exam_cse_pro').minimumAge, 13);
    expect(AgePolicy.forExam('exam_cse_sub').minimumAge, 13);
    expect(AgePolicy.forExam(null).minimumAge, 13);
    expect(AgePolicy.forExam('exam_unknown').minimumAge, 13);
  });

  test('a lower minimum lets younger students through', () {
    const lower = AgePolicy(minimumAge: 11);
    expect(lower.evaluateAge(11), AgeOutcome.minor);
    expect(lower.evaluateAge(10), AgeOutcome.underMinimum);
  });
}
