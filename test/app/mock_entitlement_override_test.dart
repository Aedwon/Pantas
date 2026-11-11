import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/bootstrap.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/mock_exam/application/mock_availability_provider.dart';
import 'package:pantas/features/paywall/paywall.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final product in ['pantas_pro_monthly', 'pantas_cs_monthly']) {
    test('mock cooldown follows the active exam for $product', () async {
      final db = ContentDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final choice = StateProvider<String>((_) => 'exam_upcat');
      final container = ProviderContainer(
        overrides: [
          ...mockEntitlementOverrides,
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
          activeExamFocusProvider.overrideWith((ref) async {
            final id = ref.watch(choice);
            return ActiveExamFocus.selected(
              Exam(
                id: id,
                code: id,
                name: id,
                shortName: id,
                language: 'en',
                isActive: true,
                subjects: const [],
              ),
            );
          }),
        ],
      );
      addTearDown(container.dispose);
      container.listen(mockEntitlementProvider, (_, __) {});
      await container.read(proForActiveExamProvider.future);
      expect(container.read(mockEntitlementProvider).proIsActive, isTrue);
      container.read(choice.notifier).state = 'exam_cse_pro';
      await container.read(proForActiveExamProvider.future);
      expect(
        container.read(mockEntitlementProvider).proIsActive,
        product == 'pantas_cs_monthly',
      );
      expect(
        (await container.read(entitlementProvider.future)).proIsActive,
        isTrue,
      );
    });
  }

  test('no entitlement reads as Free', () {
    final container = ProviderContainer(
      overrides: [
        ...mockEntitlementOverrides,
        entitlementProvider.overrideWith((ref) => const Stream.empty()),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(mockEntitlementProvider).proIsActive, isFalse);
  });
}
