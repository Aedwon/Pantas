import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/settings.dart';

void main() {
  test('every settings row has a route to land on', () {
    const required = [
      '/settings',
      '/settings/exam',
      '/settings/exam/change',
      '/settings/exam/included',
      '/settings/pro',
      '/settings/account',
      '/settings/backup',
      '/settings/about',
    ];

    final paths = collectRoutePaths();

    for (final path in required) {
      expect(paths, contains(path), reason: 'missing route $path');
    }
  });

  test('the retired subscription path still redirects', () {
    expect(collectRoutePaths(), contains('/settings/subscription'));
  });

  Future<SettingsEntitlementSnapshot> deletionSnapshot(
    WidgetTester tester,
    Entitlement entitlement,
  ) async {
    final routes = Provider(
      (ref) => GoRouter(
        initialLocation: '/settings/account/delete',
        routes: settingsRoutes(ref),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        entitlementProvider.overrideWith((_) => Stream.value(entitlement)),
        isAnonymousProvider.overrideWith((_) async => false),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(routes);
    addTearDown(router.dispose);
    await container.read(entitlementProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: appLightTheme(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return tester
        .widget<DeleteAccountPage>(find.byType(DeleteAccountPage))
        .entitlement;
  }

  testWidgets(
      'non-subscription coverage never becomes a renewing deletion plan',
      (tester) async {
    final end = DateTime.utc(2030);
    for (final entitlement in [
      Entitlement(plan: EntitlementPlan.free, passes: {'exam_cse_pro': end}),
      Entitlement(
        plan: EntitlementPlan.free,
        promotions: [CoveragePeriod(id: 'promo_student', endsAt: end)],
      ),
      Entitlement.activeUnknown(productId: 'future-product', expiresAt: end),
    ]) {
      final snapshot = await deletionSnapshot(tester, entitlement);
      expect(snapshot.plan, SettingsEntitlementPlan.free);
      expect(snapshot.willRenew, isFalse);
      expect(snapshot.expiresAt, isNull);
      expect(deleteAccountBillingLine(snapshot), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('canceled paid period survives the deletion route conversion',
      (tester) async {
    final end = DateTime.utc(2030);
    final snapshot = await deletionSnapshot(
      tester,
      Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_cs_monthly',
        expiresAt: end,
        willRenew: false,
      ),
    );
    expect(snapshot.plan, SettingsEntitlementPlan.monthly);
    expect(snapshot.willRenew, isFalse);
    expect(snapshot.expiresAt, end);
  });
}
