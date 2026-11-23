import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/onboarding/application/exam_picker_availability.dart';

const _pshs = ExamCatalogEntry(
  id: 'exam_pshs_nce',
  name: 'PSHS-NCE',
  shortName: 'PSHS-NCE',
  priceTier: 'test',
  group: 'High school',
  comingSoon: true,
  publishedSittings: [],
  hasContent: false,
);

const _cse = ExamCatalogEntry(
  id: 'exam_cse_pro',
  name: 'CSE',
  shortName: 'CSE',
  priceTier: 'test',
  group: 'Civil service',
  comingSoon: false,
  publishedSittings: [],
  hasContent: true,
);

void main() {
  test('children cannot select a non-PSHS exam', () {
    const policy = ExamPickerPolicy(ageGroup: AgeGroup.child, isWeb: true);
    expect(policy.availability(_cse), ExamPickerAvailability.ageRestricted);
    expect(policy.availability(_cse).reason, 'For ages 13 and up');
    expect(policy.allowsCustomExams, isFalse);
  });

  test('PSHS remains coming soon by default', () {
    const policy = ExamPickerPolicy(ageGroup: AgeGroup.child, isWeb: true);
    expect(policy.availability(_pshs), ExamPickerAvailability.comingSoon);
  });

  test('the flag admits children without catalog content in the web picker',
      () {
    const policy = ExamPickerPolicy(
      ageGroup: AgeGroup.child,
      isWeb: true,
      pshsForChildren: true,
    );
    expect(
      policy.availability(_pshs, cseOnly: true),
      ExamPickerAvailability.selectable,
    );
  });

  for (final group in [AgeGroup.unset, AgeGroup.adult, AgeGroup.minor]) {
    test('the flag preserves exam availability for ${group.name}', () {
      final policy = ExamPickerPolicy(
        ageGroup: group,
        isWeb: true,
        pshsForChildren: true,
      );
      expect(policy.availability(_pshs), ExamPickerAvailability.comingSoon);
      expect(policy.availability(_cse), ExamPickerAvailability.selectable);
    });
  }

  test('Android hides PSHS even with the flag on', () {
    const policy = ExamPickerPolicy(
      ageGroup: AgeGroup.child,
      platform: TargetPlatform.android,
      pshsForChildren: true,
    );
    expect(policy.availability(_pshs), ExamPickerAvailability.hidden);
  });

  test('web on Android still lists PSHS', () {
    const policy = ExamPickerPolicy(
      ageGroup: AgeGroup.child,
      isWeb: true,
      platform: TargetPlatform.android,
      pshsForChildren: true,
    );
    expect(policy.availability(_pshs), ExamPickerAvailability.selectable);
  });

  group('the child question (board 3A)', () {
    const open = ExamCatalogEntry(
      id: 'exam_pshs_nce',
      name: 'PSHS-NCE',
      shortName: 'PSHS-NCE',
      priceTier: 'test',
      group: 'High school',
      comingSoon: false,
      publishedSittings: [],
      hasContent: true,
    );

    for (final group in [AgeGroup.adult, AgeGroup.minor]) {
      test('${group.name} is asked when PSHS-NCE can be picked', () {
        final policy = ExamPickerPolicy(ageGroup: group, isWeb: true);
        expect(policy.asksChildQuestion(open), isTrue);
      });
      test('${group.name} is asked while coming soon only with the flag', () {
        expect(
          ExamPickerPolicy(ageGroup: group, isWeb: true)
              .asksChildQuestion(_pshs),
          isFalse,
        );
        expect(
          ExamPickerPolicy(ageGroup: group, isWeb: true, pshsForChildren: true)
              .asksChildQuestion(_pshs),
          isTrue,
        );
      });
    }

    for (final group in [
      AgeGroup.child,
      AgeGroup.unset,
      AgeGroup.unrecognized,
    ]) {
      test('${group.name} is never asked', () {
        final policy = ExamPickerPolicy(
          ageGroup: group,
          isWeb: true,
          pshsForChildren: true,
        );
        expect(policy.asksChildQuestion(open), isFalse);
        expect(policy.asksChildQuestion(_pshs), isFalse);
      });
    }

    test('another exam does not ask', () {
      const policy = ExamPickerPolicy(ageGroup: AgeGroup.adult, isWeb: true);
      expect(policy.asksChildQuestion(_cse), isFalse);
    });

    test('Android does not ask, because PSHS-NCE is hidden', () {
      const policy = ExamPickerPolicy(
        ageGroup: AgeGroup.adult,
        platform: TargetPlatform.android,
        pshsForChildren: true,
      );
      expect(policy.asksChildQuestion(open), isFalse);
    });
  });
}
