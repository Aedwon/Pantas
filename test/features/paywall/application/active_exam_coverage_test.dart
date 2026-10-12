import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/dev/dev_pro_switch.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

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
