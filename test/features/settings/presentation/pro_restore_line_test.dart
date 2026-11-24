// T5 (U44): the phone Pro page draws Restore Purchases as the boards do.
//  - Free (ST_ProFree, ST_ProPending): a 24 high 15/600 teal line in the bar,
//    under the fine print.
//  - Pro and lapsed (ST_ProPro, ST_ProPassHave, ST_ProLapsed): a teal row,
//    "Restore purchases", in the last card; no Restore in a bar.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/data/pending_purchase_store.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/presentation/widgets/web_pro_hero.dart';

import 'pro_page_payments_test.dart' show SettingsGateway;

Future<SettingsGateway> _pump(
  WidgetTester tester, {
  required Entitlement entitlement,
  PendingPurchase? pending,
  double width = 390,
  bool web = false,
}) async {
  debugWebPlatformOverride = web;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = Size(width, 844)
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
        currentUserProvider.overrideWith(
          (ref) async => const AuthUser(
            uid: 'owner',
            email: 'owner@example.com',
            displayName: 'Owner',
          ),
        ),
        pendingPurchaseProvider.overrideWithValue(AsyncData(pending)),
      ],
      child: MaterialApp(
        theme: buildLightTheme(web: web),
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
    // The eyebrow now sits in the taller hero, so scroll the row into view.
    await tester.ensureVisible(row);
    await tester.pumpAndSettle();
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

  testWidgets(
      'Pending: Open Google Play is the filled 52 button in the bar, '
      'with the Restore line under it (ST_ProPending)', (tester) async {
    await _pump(
      tester,
      entitlement: const Entitlement.free(),
      pending: PendingPurchase(
        uid: 'owner',
        productId: 'pantas_cs_monthly',
        startedAt: DateTime.now(),
      ),
    );
    final open = find.widgetWithText(PantasButton, 'Open Google Play');
    expect(open, findsOneWidget);
    final bar = find.byKey(const ValueKey('pro-bar'));
    expect(find.descendant(of: bar, matching: open), findsOneWidget);
    expect(tester.getSize(open).height, 52);
    expect(tester.widget<PantasButton>(open).kind, isNull);
    expect(
      tester.widget<PantasButton>(open).variant,
      PantasButtonVariant.primary,
    );
    final restore = find.widgetWithText(PantasButton, 'Restore Purchases');
    // 8 between the button and the line, which has 4 inside.
    expect(
      tester.getTopLeft(restore).dy - tester.getBottomLeft(open).dy,
      closeTo(8, 1),
    );
  });

  testWidgets('Free: the bar pads 30 under the Restore line (ST_ProFree)',
      (tester) async {
    await _pump(tester, entitlement: const Entitlement.free());
    final line = find.widgetWithText(PantasButton, 'Restore Purchases');
    expect(844 - tester.getBottomLeft(line).dy, closeTo(30, 1));
  });

  testWidgets('wide: the Restore label sits 18 in, 4 and the 14 of .btn3',
      (tester) async {
    await _pump(
      tester,
      entitlement: const Entitlement.free(),
      width: 1440,
      web: true,
    );
    final button = find.widgetWithText(TextButton, 'Restore Purchases');
    final label = find.text('Restore Purchases');
    expect(
      tester.getTopLeft(label).dx - tester.getTopLeft(button).dx,
      14,
    );
    final hero = find.byType(WebProHero);
    expect(
      tester.getTopLeft(button).dx - tester.getTopLeft(hero).dx,
      4,
    );
  });

  testWidgets(
      'Pro: 22 between the Plan card and the last card, and a divider '
      'between Manage and Restore (ST_ProPro)', (tester) async {
    await _pump(
      tester,
      entitlement: Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_pro_monthly',
        expiresAt: DateTime.utc(2026, 11, 4),
      ),
    );
    GroupedSection cardOf(String text) => tester.widget<GroupedSection>(
          find.ancestor(
            of: find.text(text),
            matching: find.byType(GroupedSection),
          ),
        );
    expect(cardOf('Plan'), isNot(same(cardOf('Manage in Google Play'))));
    final plan = tester.getRect(
      find.ancestor(
        of: find.text('Plan'),
        matching: find.byType(GroupedSection),
      ),
    );
    final last = tester.getRect(
      find.ancestor(
        of: find.text('Manage in Google Play'),
        matching: find.byType(GroupedSection),
      ),
    );
    expect(last.top - plan.bottom, 22);
    ListRow row(String title) => tester.widget<ListRow>(
          find.byWidgetPredicate((w) => w is ListRow && w.title == title),
        );
    expect(row('Manage in Google Play').divider, isTrue);
    expect(row('Restore purchases').divider, isFalse);
  });
}
