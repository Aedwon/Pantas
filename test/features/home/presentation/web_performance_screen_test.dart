import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/application/performance/table_order_prefs.dart';
import 'package:pantas/features/home/presentation/performance_screen.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

import 'performance_screen_test.dart' as fixtures;

void main() {
  tearDown(() => debugWebPlatformOverride = null);
  for (final dark in [false, true]) {
    testWidgets('wide performance error and retry dark=$dark', (tester) async {
      debugWebPlatformOverride = true;
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var fail = true;
      final router = GoRouter(
        initialLocation: '/performance',
        routes: [
          GoRoute(
            path: '/performance',
            builder: (_, state) => const PerformanceScreen(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            performanceViewProvider.overrideWith((_) async {
              if (fail) throw StateError('offline');
              return fixtures.view;
            }),
            tableOrderProvider.overrideWith(_Order.new),
            proForActiveExamProvider.overrideWith((_) async => true),
            entitlementProvider
                .overrideWith((_) => Stream.value(const Entitlement.free())),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your performance'), findsOneWidget);
      expect(find.text('Could not load your performance.'), findsOneWidget);
      final warning = find.byIcon(Icons.warning_amber_rounded);
      expect(tester.widget<Icon>(warning).size, 28);
      final card = find.ancestor(of: warning, matching: find.byType(WebCard));
      expect(
        tester.widget<WebCard>(card).padding,
        const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
      );
      fail = false;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.text('Mathematics'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('wide topic deep link keeps the performance list behind it',
      (tester) async {
    debugWebPlatformOverride = true;
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await fixtures.pump(
      tester,
      initialPath: '/performance/topic/Geometry',
      realTopic: true,
    );
    await tester.pumpAndSettle();
    expect(find.text('Your performance'), findsOneWidget);
    expect(find.text('Private topic detail'), findsOneWidget);
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('web-performance-topic')),
          )
          .width,
      480,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('wide topic opens above list and Esc returns to it',
      (tester) async {
    debugWebPlatformOverride = true;
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await fixtures.pump(tester, initialPath: '/performance', realTopic: true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Topics'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Geometry'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('web-performance-topic')), findsOneWidget);
    expect(find.text('Your performance'), findsOneWidget);
    expect(find.text('Private topic detail'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Private topic detail'), findsNothing);
    expect(find.text('Geometry'), findsOneWidget);
  });
}

class _Order extends TableOrderNotifier {
  @override
  Future<TableOrder> build() async => TableOrder.defaults;
}
