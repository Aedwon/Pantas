// T5 (U44): the phone Pro page draws Restore Purchases as the boards do.
//  - Free (ST_ProFree, ST_ProPending): a 24 high 15/600 teal line in the bar,
//    under the fine print.
//  - Pro and lapsed (ST_ProPro, ST_ProPassHave, ST_ProLapsed): a teal row,
//    "Restore purchases", in the last card; no Restore in a bar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import 'pro_page_payments_test.dart' show SettingsGateway;

Future<SettingsGateway> _pump(
  WidgetTester tester, {
  required Entitlement entitlement,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final gateway = SettingsGateway(initial: entitlement);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        revenueCatGatewayProvider.overrideWithValue(gateway),
        entitlementProvider.overrideWith((ref) => Stream.value(entitlement)),
        proForActiveExamProvider
            .overrideWith((ref) async => entitlement.proIsActive),
      ],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: const ProPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return gateway;
}

void main() {
  testWidgets(
      'Free: Restore Purchases is a 24 high 15/600 teal line in the bar',
      (tester) async {
    await _pump(tester, entitlement: const Entitlement.free());
    final line = find.byWidgetPredicate(
      (w) => w is PantasButton && w.label == 'Restore Purchases',
    );
    expect(line, findsOneWidget);
    final button = tester.getSize(
      find.descendant(of: line, matching: find.byType(TextButton)),
    );
    expect(button.height, closeTo(24, 1));
    final text = tester.widget<Text>(
      find.descendant(of: line, matching: find.text('Restore Purchases')),
    );
    expect(text.style!.fontSize, 15);
    expect(text.style!.fontWeight, FontWeight.w600);
    // It sits inside the bar, and no card row repeats it.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('pro-bar')),
        matching: find.text('Restore Purchases'),
      ),
      findsOneWidget,
    );
    expect(find.text('Restore purchases'), findsNothing);
  });

  testWidgets('Free: the line restores', (tester) async {
    final gateway = await _pump(tester, entitlement: const Entitlement.free());
    await tester.tap(find.text('Restore Purchases'));
    await tester.pumpAndSettle();
    expect(gateway.restoreCalls, 1);
  });

  testWidgets('Pro: Restore is a teal row under Manage, with no bar',
      (tester) async {
    final gateway = await _pump(
      tester,
      entitlement: const Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
      ),
    );
    expect(find.byKey(const ValueKey('pro-bar')), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) => w is PantasButton && w.label.toLowerCase().contains('restore'),
      ),
      findsNothing,
    );
    final row = find.text('Restore purchases');
    expect(row, findsOneWidget);
    final style = tester.widget<Text>(row).style!;
    expect(style.fontSize, 17);
    expect(style.fontWeight, FontWeight.w400);
    // Below Manage in Google Play, in the same card.
    expect(
      tester.getTopLeft(row).dy,
      greaterThan(tester.getTopLeft(find.text('Manage in Google Play')).dy),
    );
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(gateway.restoreCalls, 1);
  });

  testWidgets('Lapsed: Restore is a teal row in the card, not in the bar',
      (tester) async {
    final gateway = await _pump(
      tester,
      entitlement: Entitlement(
        plan: EntitlementPlan.free,
        expiresAt: DateTime.utc(2020),
      ),
    );
    expect(
      find.byWidgetPredicate(
        (w) => w is PantasButton && w.label.toLowerCase().contains('restore'),
      ),
      findsNothing,
    );
    final row = find.text('Restore purchases');
    expect(row, findsOneWidget);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(gateway.restoreCalls, 1);
  });
}
