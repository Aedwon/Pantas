import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/age_group.dart';

void main() {
  test('parse reads the four stored values and calls anything else unknown',
      () {
    expect(AgeGroup.parse(null), AgeGroup.unset);
    expect(AgeGroup.parse('adult'), AgeGroup.adult);
    expect(AgeGroup.parse('minor'), AgeGroup.minor);
    expect(AgeGroup.parse('child'), AgeGroup.child);
    expect(AgeGroup.parse('teen'), AgeGroup.unrecognized);
    expect(AgeGroup.parse(''), AgeGroup.unrecognized);
    expect(AgeGroup.parse('ADULT'), AgeGroup.unrecognized);
  });

  test('only unset and adult are unrestricted', () {
    expect(AgeGroup.unset.isRestricted, isFalse);
    expect(AgeGroup.adult.isRestricted, isFalse);
    expect(AgeGroup.minor.isRestricted, isTrue);
    expect(AgeGroup.child.isRestricted, isTrue);
    expect(AgeGroup.unrecognized.isRestricted, isTrue);
  });

  test('a child skips the teen guardian flow; unknown does not', () {
    expect(AgeGroup.minor.entersTeenGuardianFlow, isTrue);
    expect(AgeGroup.unrecognized.entersTeenGuardianFlow, isTrue);
    expect(AgeGroup.child.entersTeenGuardianFlow, isFalse);
    expect(AgeGroup.adult.entersTeenGuardianFlow, isFalse);
    expect(AgeGroup.unset.entersTeenGuardianFlow, isFalse);
  });

  test(
      'purchase attestation follows restriction, and only a minor can '
      'say they are 18', () {
    for (final group in AgeGroup.values) {
      expect(group.needsPurchaseAttestation, group.isRestricted);
    }
    expect(AgeGroup.minor.canSelfSwitchToAdult, isTrue);
    expect(AgeGroup.child.canSelfSwitchToAdult, isFalse);
    expect(AgeGroup.unrecognized.canSelfSwitchToAdult, isFalse);
    expect(AgeGroup.child.isChild, isTrue);
  });
}
