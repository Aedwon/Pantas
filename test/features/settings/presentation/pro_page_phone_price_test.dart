import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/pump_app.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

Future<void> _pump(
  WidgetTester tester, {
  required String weekly,
  required String monthly,
  required String yearly,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  PaywallPackage pkg(PaywallSku sku, String text, double amount) =>
      PaywallPackage(
        sku: sku,
        productId: 'pantas_cs_${sku.name}',
        priceString: text,
        priceAmount: amount,
      );
  await tester.pumpAppWithProviders(
    const ProPage(),
    overrides: [
      revenueCatGatewayProvider.overrideWithValue(
        SettingsGateway(initial: const Entitlement.free()),
      ),
      proForActiveExamProvider.overrideWith((ref) async => false),
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(
          buildExam(id: 'exam_cse_pro', shortName: 'CSE Professional'),
        ),
      ),
      isAnonymousProvider.overrideWith((ref) async => false),
      activeProCatalogEntryProvider.overrideWith(
        (ref) async => const ExamCatalogEntry(
          id: 'exam_cse_pro',
          name: 'CSE Professional',
          shortName: 'CSE Professional',
          priceTier: 'Civil Service',
          group: 'Civil service',
          comingSoon: false,
          publishedSittings: [],
          hasContent: true,
        ),
      ),
      paywallOfferingProvider.overrideWith(
        (ref) async => PaywallOfferingResult(
          status: PaywallOfferingStatus.available,
          recognizedPackages: [
            pkg(PaywallSku.weekly, weekly, 49),
            pkg(PaywallSku.monthly, monthly, 149),
            pkg(PaywallSku.yearly, yearly, 1199),
          ],
        ),
      ),
    ],
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('phone plan prices drop .00, as the boards show', (tester) async {
    await _pump(
      tester,
      weekly: '₱49.00',
      monthly: '₱149.00',
      yearly: '₱1,199.00',
    );
    expect(find.text('₱49'), findsOneWidget);
    expect(find.text('₱149'), findsOneWidget);
    expect(find.text('₱1,199'), findsOneWidget);
    expect(find.text('₱1,199.00'), findsNothing);
  });

  testWidgets('a long price stays on one line at 390 wide', (tester) async {
    // Real centavos stay, so this is the longest text a card can receive.
    await _pump(
      tester,
      weekly: '₱49.50',
      monthly: '₱149.50',
      yearly: '₱11,199.50',
    );
    final heights = [
      for (final price in ['₱49.50', '₱149.50', '₱11,199.50'])
        tester.getSize(find.text(price)).height,
    ];
    expect(heights.toSet().length, 1, reason: 'every price is one line');
    final texts = tester.widgetList<Text>(find.text('₱11,199.50'));
    expect(texts.single.softWrap, isFalse);
    expect(texts.single.maxLines, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone plan cards share one height, whatever each holds',
      (tester) async {
    await _pump(
      tester,
      weekly: '\u20b149.00',
      monthly: '\u20b1149.00',
      yearly: '\u20b11,199.00',
    );
    double height(String label) => tester
        .getSize(
          find
              .ancestor(of: find.text(label), matching: find.byType(InkWell))
              .first,
        )
        .height;
    // Yearly states its monthly price on a second line; the others do not.
    expect(find.textContaining(' a month'), findsOneWidget);
    expect(height('Weekly'), height('Yearly'));
    expect(height('Monthly'), height('Yearly'));
    expect(tester.takeException(), isNull);
  });
}
