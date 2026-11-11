import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/track_scope.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/paywall/application/custom_track_tier.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

import '../../../helpers/custom_subject_tiers_fixture.dart';

void main() {
  const customId = 'exam_custom_00000000-0000-4000-8000-000000000000';
  const custom = Exam(
    id: customId,
    code: 'custom',
    name: 'PUP CET',
    shortName: 'PUP CET',
    language: 'en',
    isActive: true,
    subjects: [],
    isCustom: true,
  );

  ProviderContainer containerWith(List<Topic> topics) {
    final container = ProviderContainer(
      overrides: [
        studyUsesServerProvider.overrideWithValue(false),
        shippedCustomSubjectTiers(studentTopics: ['t1']),
        activeExamFocusProvider.overrideWith(
          (ref) async => const ActiveExamFocus.selected(custom),
        ),
        scopedTopicsProvider(customId).overrideWith((ref) async => topics),
      ],
    );
    addTearDown(container.dispose);
    container.listen(activeCustomTrackTierProvider, (_, __) {});
    return container;
  }

  test('an empty corpus gives no tier, never Student', () async {
    final container = containerWith(const []);

    await expectLater(
      container.read(activeCustomTrackTierProvider.future),
      throwsA(isA<StateError>()),
    );
  });

  test('a loaded corpus gives its tier', () async {
    final container = containerWith(const [
      Topic(id: 't1', subjectId: 's1', name: 'Algebra', ordering: 1),
    ]);

    final tier = await container.read(activeCustomTrackTierProvider.future);
    expect(tier?.tier, PriceTier.student);
  });
}
