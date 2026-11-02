import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/onboarding/domain/age_policy.dart';

void main() {
  const policy = AgePolicy();

  test('the minimum is 13 and the adult age is 18', () {
    expect(policy.minimumAge, 13);
    expect(AgePolicy.adultAge, 18);
  });

  test('a year that could mean under the minimum for both ages is blocked', () {
    // 2014 in 2026: the student is 12 or 11.
    expect(
      policy.evaluate(birthYear: 2014, currentYear: 2026),
      AgeOutcome.underMinimum,
    );
    expect(
      policy.evaluate(birthYear: 2026, currentYear: 2026),
      AgeOutcome.underMinimum,
    );
  });

  test('a year that could mean 12 or 13 is let through', () {
    // The old gate let 2013 pass in 2026; the new rule must not narrow it.
    expect(
      policy.evaluate(birthYear: 2013, currentYear: 2026),
      AgeOutcome.minor,
    );
  });

  test('a year that could mean 17 or 18 counts as a minor', () {
    expect(
      policy.evaluate(birthYear: 2008, currentYear: 2026),
      AgeOutcome.minor,
    );
    expect(
      policy.evaluate(birthYear: 2009, currentYear: 2026),
      AgeOutcome.minor,
    );
  });

  test('a year that can only mean 18 or older is an adult', () {
    expect(
      policy.evaluate(birthYear: 2007, currentYear: 2026),
      AgeOutcome.adult,
    );
    expect(
      policy.evaluate(birthYear: 1980, currentYear: 2026),
      AgeOutcome.adult,
    );
  });

  test('the boundary moves with the year', () {
    expect(
      policy.evaluate(birthYear: 2008, currentYear: 2027),
      AgeOutcome.adult,
    );
    expect(
      policy.evaluate(birthYear: 2009, currentYear: 2027),
      AgeOutcome.minor,
    );
  });

  test('the minimum age is per exam and defaults to 13', () {
    expect(AgePolicy.forExam('exam_cse_pro').minimumAge, 13);
    expect(AgePolicy.forExam('exam_cse_sub').minimumAge, 13);
    expect(AgePolicy.forExam(null).minimumAge, 13);
    expect(AgePolicy.forExam('exam_unknown').minimumAge, 13);
  });

  test('a lower minimum lets younger students through', () {
    const lower = AgePolicy(minimumAge: 11);
    expect(
      lower.evaluate(birthYear: 2014, currentYear: 2026),
      AgeOutcome.minor,
    );
    expect(
      lower.evaluate(birthYear: 2016, currentYear: 2026),
      AgeOutcome.underMinimum,
    );
  });
}
