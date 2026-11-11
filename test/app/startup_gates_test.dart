import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/startup_gates.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';

void main() {
  late Completer<bool> ageGate;
  late Completer<ActiveExamFocus> focus;
  late Completer<bool> onboarding;
  var reads = 0;

  ProviderContainer build({Future<GuardianGate>? guardian}) {
    reads = 0;
    final container = ProviderContainer(
      overrides: [
        guardianGateProvider.overrideWith(
          (ref) => guardian ?? Future.value(GuardianGate.notRequired),
        ),
        passedAgeGateProvider.overrideWith((ref) {
          reads++;
          return ageGate.future;
        }),
        activeExamFocusProvider.overrideWith((ref) {
          reads++;
          return focus.future;
        }),
        onboardingCompleteProvider.overrideWith((ref) {
          reads++;
          return onboarding.future;
        }),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    ageGate = Completer<bool>();
    focus = Completer<ActiveExamFocus>();
    onboarding = Completer<bool>();
  });

  test('a start at Home waits too, so onboarding never slides over it',
      () async {
    final container = build();
    var settled = false;
    final waiting =
        settleGatesBeforeFirstPage(container).then((_) => settled = true);
    await Future<void>.delayed(Duration.zero);
    expect(reads, 3, reason: 'Home does not skip the reads');
    expect(settled, isFalse);

    ageGate.complete(true);
    focus.complete(const ActiveExamFocus.needsSelection());
    onboarding.complete(false);
    await waiting;
    expect(settled, isTrue);
  });

  test('a start waits until all three gates have a value', () async {
    final container = build();
    var settled = false;
    final waiting =
        settleGatesBeforeFirstPage(container).then((_) => settled = true);

    ageGate.complete(true);
    await Future<void>.delayed(Duration.zero);
    focus.complete(const ActiveExamFocus.needsSelection());
    await Future<void>.delayed(Duration.zero);
    expect(settled, isFalse, reason: 'onboarding is still loading');

    onboarding.complete(false);
    await waiting;
    expect(settled, isTrue);
    expect(container.read(passedAgeGateProvider).value, isTrue);
    expect(container.read(onboardingCompleteProvider).value, isFalse);
  });

  test('startup waits for persisted guardian closure restoration', () async {
    final guardian = Completer<GuardianGate>();
    final container = build(guardian: guardian.future);
    ageGate.complete(true);
    focus.complete(const ActiveExamFocus.needsSelection());
    onboarding.complete(true);
    var settled = false;
    final waiting =
        settleGatesBeforeFirstPage(container).then((_) => settled = true);
    await Future<void>.delayed(Duration.zero);
    expect(settled, isFalse);
    guardian.complete(GuardianGate.withdrawn);
    await waiting;
    expect(settled, isTrue);
  });

  test('a gate that fails to read does not block the start', () async {
    final container = build();
    ageGate.completeError(StateError('storage'));
    focus.completeError(StateError('catalog'));
    onboarding.complete(true);
    await settleGatesBeforeFirstPage(container);
  });

  test('a gate that never answers does not block the start', () async {
    final container = build();
    ageGate.complete(true);
    focus.complete(const ActiveExamFocus.needsSelection());
    final stopwatch = Stopwatch()..start();
    await settleGatesBeforeFirstPage(
      container,
      timeout: const Duration(milliseconds: 50),
    );
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
  });
}
