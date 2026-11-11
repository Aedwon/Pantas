import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/paywall/application/custom_track_tier.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Exam exam(String id) => Exam(
        id: id,
        code: id,
        name: id,
        shortName: id,
        language: 'en',
        isActive: true,
        subjects: const [],
      );

  for (final product in ['pantas_pro_monthly', 'pantas_cs_monthly']) {
    test('active exam switch applies coverage for $product', () async {
      final db = ContentDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final choice = StateProvider<String>((_) => 'exam_upcat');
      final container = ProviderContainer(
        overrides: [
          contentDatabaseProvider.overrideWithValue(db),
          devProOverrideProvider.overrideWithValue(null),
          entitlementProvider.overrideWith(
            (_) => Stream.value(
              Entitlement(
                plan: EntitlementPlan.monthly,
                productId: product,
                expiresAt: DateTime.utc(2030),
              ),
            ),
          ),
          activeExamFocusProvider.overrideWith(
            (ref) async => ActiveExamFocus.selected(exam(ref.watch(choice))),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.listen(proForActiveExamProvider, (_, __) {});
      expect(await container.read(proForActiveExamProvider.future), isTrue);
      container.read(choice.notifier).state = 'exam_cse_pro';
      expect(
        await container.read(proForActiveExamProvider.future),
        product == 'pantas_cs_monthly',
      );
      expect(
        (await container.read(entitlementProvider.future)).proIsActive,
        isTrue,
      );
    });
  }

  group('a custom exam is covered by plan tier alone', () {
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

    Future<bool> proFor({
      required Entitlement entitlement,
      required PriceTier tier,
    }) async {
      final db = ContentDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          contentDatabaseProvider.overrideWithValue(db),
          devProOverrideProvider.overrideWithValue(null),
          entitlementProvider.overrideWith((_) => Stream.value(entitlement)),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(custom),
          ),
          activeCustomTrackTierProvider
              .overrideWith((ref) async => CustomTrackTier(tier: tier)),
        ],
      );
      addTearDown(container.dispose);
      container.listen(proForActiveExamProvider, (_, __) {});
      return container.read(proForActiveExamProvider.future);
    }

    Entitlement plan(String product) => Entitlement(
          plan: EntitlementPlan.monthly,
          productId: product,
          expiresAt: DateTime.utc(2030),
        );

    test('a Student plan covers a Student-level custom exam', () async {
      expect(
        await proFor(
          entitlement: plan('pantas_pro_monthly'),
          tier: PriceTier.student,
        ),
        isTrue,
      );
    });

    test('a Student plan does not cover a Civil Service-level one', () async {
      expect(
        await proFor(
          entitlement: plan('pantas_pro_monthly'),
          tier: PriceTier.civilService,
        ),
        isFalse,
      );
    });

    test('a Civil Service plan covers a Student-level one', () async {
      expect(
        await proFor(
          entitlement: plan('pantas_cs_monthly'),
          tier: PriceTier.student,
        ),
        isTrue,
      );
    });

    test('Free covers nothing', () async {
      expect(
        await proFor(
          entitlement: const Entitlement.free(),
          tier: PriceTier.student,
        ),
        isFalse,
      );
    });

    Future<ProviderContainer> containerFor({
      required Future<CustomTrackTier?> Function() tier,
    }) async {
      final db = ContentDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          contentDatabaseProvider.overrideWithValue(db),
          devProOverrideProvider.overrideWithValue(null),
          entitlementProvider.overrideWith(
            (_) => Stream.value(plan('pantas_cs_monthly')),
          ),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(custom),
          ),
          activeCustomTrackTierProvider.overrideWith((ref) => tier()),
        ],
      );
      addTearDown(container.dispose);
      container.listen(proForActiveExamProvider, (_, __) {});
      return container;
    }

    test('a tier still loading is loading, never Free and never Pro', () async {
      final container = await containerFor(
        tier: () => Completer<CustomTrackTier?>().future,
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(proForActiveExamProvider).isLoading, isTrue);
      expect(container.read(proForActiveExamProvider).hasValue, isFalse);
    });

    test('a tier that failed is an error, never Free and never Pro', () async {
      final container = await containerFor(
        tier: () async => throw StateError('offline'),
      );
      await expectLater(
        container.read(proForActiveExamProvider.future),
        throwsA(isA<StateError>()),
      );
      expect(container.read(proForActiveExamProvider).hasValue, isFalse);
    });

    test('no tier for a custom exam is an error, never Free', () async {
      final container = await containerFor(tier: () async => null);
      await expectLater(
        container.read(proForActiveExamProvider.future),
        throwsA(isA<StateError>()),
      );
    });
  });

  test('debug Pro override still covers every active exam', () async {
    final container = ProviderContainer(
      overrides: [
        devProOverrideProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);
    expect(await container.read(proForActiveExamProvider.future), isTrue);
  });
}
