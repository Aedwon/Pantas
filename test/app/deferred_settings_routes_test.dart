import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/deferred_route.dart';
import 'package:pantas/app/routes/settings_routes_native.dart' as native;
import 'package:pantas/app/routes/settings_routes_web.dart' as web;
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';

void main() {
  test('web declares the same paths and redirects as native', () {
    final ref = _RouteRef();
    final original = native.settingsRoutes(ref).cast<GoRoute>();
    final deferred = web.settingsRoutes(ref).cast<GoRoute>();
    expect(
      deferred.map((route) => route.path),
      original.map((route) => route.path),
    );
    expect(
      deferred
          .where((route) => route.redirect != null)
          .map((route) => route.path),
      original
          .where((route) => route.redirect != null)
          .map((route) => route.path),
    );
  });

  testWidgets(
      'web account deep link loads and Back returns to the previous page',
      (tester) async {
    final provider = Provider(
      (ref) => GoRouter(
        initialLocation: '/before',
        routes: [
          GoRoute(
            path: '/before',
            builder: (_, __) => const Text('Previous page'),
          ),
          ...web.settingsRoutes(ref),
        ],
      ),
    );
    final container = ProviderContainer(
      overrides: [
        entitlementProvider.overrideWith(
          (_) => Stream.value(const Entitlement.free()),
        ),
        isAnonymousProvider.overrideWith((_) async => false),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(provider);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pushed = router.push<void>('/settings/account/delete?source=link');
    await tester.pumpAndSettle();
    expect(find.byType(DeferredRoute), findsOneWidget);
    expect(find.byType(DeleteAccountPage), findsOneWidget);
    expect(
      GoRouterState.of(tester.element(find.byType(DeleteAccountPage)))
          .uri
          .queryParameters['source'],
      'link',
    );
    router.pop();
    await tester.pumpAndSettle();
    await pushed;
    expect(find.text('Previous page'), findsOneWidget);
  });
}

class _RouteRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
