import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_tag.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/pump_app.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

Future<void> _pump(
  WidgetTester tester, {
  required String weekly,
  required String monthly,
  required String yearly,
  Size size = const Size(390, 844),
  bool anonymousWeb = false,
}) async {
  tester.view.physicalSize = size;
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
      isAnonymousProvider.overrideWith((ref) async => anonymousWeb),
      if (anonymousWeb) paymentsOnWebProvider.overrideWithValue(true),
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
  testWidgets('phone Pro: Continue with Google carries the Google G',
      (tester) async {
    await _pump(
      tester,
      weekly: '₱49',
      monthly: '₱149',
      yearly: '₱1,199',
      anonymousWeb: true,
    );
    final label = find.text('Continue with Google');
    expect(label, findsOneWidget);
    final button = find.ancestor(of: label, matching: find.byType(TextButton));
    expect(
      find.descendant(of: button.first, matching: find.byType(SvgPicture)),
      findsOneWidget,
    );
  });

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

  testWidgets('phone plan tiles stack one per row, each full width',
      (tester) async {
    await _pump(
      tester,
      weekly: '\u20b149.00',
      monthly: '\u20b1149.00',
      yearly: '\u20b11,199.00',
    );
    Rect rect(String label) => tester.getRect(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byKey(const ValueKey('pro-plan-tile')),
              )
              .first,
        );
    // Yearly states its monthly price on a second line; the others do not.
    expect(find.textContaining(' a month'), findsOneWidget);
    expect(rect('Weekly').width, rect('Monthly').width);
    expect(rect('Monthly').width, rect('Yearly').width);
    expect(rect('Weekly').bottom, lessThan(rect('Monthly').top));
    expect(rect('Monthly').bottom, lessThan(rect('Yearly').top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the SAVE tag sits on the Yearly tile, clear of Monthly',
      (tester) async {
    await _pump(
      tester,
      weekly: '\u20b149.00',
      monthly: '\u20b1149.00',
      yearly: '\u20b11,199.00',
    );
    Rect tile(String label) => tester.getRect(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byKey(const ValueKey('pro-plan-tile')),
              )
              .first,
        );
    final tag = tester.getRect(
      find.ancestor(
        of: find.text('SAVE 32%'),
        matching: find.byType(PantasTag),
      ),
    );
    // The tag clears the tile above by a gap, not by touching it.
    expect(tag.top, greaterThanOrEqualTo(tile('Monthly').bottom + 8));
    expect(tag.center.dy, closeTo(tile('Yearly').top, 12));
  });

  testWidgets('at 320 wide every plan scrolls clear of the pinned bar',
      (tester) async {
    await _pump(
      tester,
      weekly: '\u20b149.00',
      monthly: '\u20b1149.00',
      yearly: '\u20b11,199.00',
      size: const Size(320, 568),
    );
    expect(find.byKey(const ValueKey('pro-bar-fade')), findsOneWidget);
    final bar = tester.getRect(find.byType(PantasButton).first);
    for (final label in ['Weekly', 'Monthly', 'Yearly']) {
      final plan = find
          .ancestor(
            of: find.text(label),
            matching: find.byKey(const ValueKey('pro-plan-tile')),
          )
          .first;
      await tester.ensureVisible(plan);
      await tester.pumpAndSettle();
      expect(tester.getRect(plan).bottom, lessThanOrEqualTo(bar.top));
    }
    expect(tester.takeException(), isNull);
  });
}
