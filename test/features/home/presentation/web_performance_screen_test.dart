import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/motion/web_overlay_motion.dart';
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
        const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
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
      440,
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
  const drawerKey = ValueKey('web-performance-topic');
  double drawerLeft(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(drawerKey)).dx;
  testWidgets('a topic drawer slides in and out when a row opens it',
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
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final middle = drawerLeft(tester);
    expect(middle, inExclusiveRange(1000, 1440));
    await tester.pumpAndSettle();
    expect(drawerLeft(tester), 1000);

    await tester.tapAt(const Offset(100, 100));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(drawerKey), findsOneWidget);
    expect(drawerLeft(tester), greaterThan(1000));
    await tester.pumpAndSettle();
    expect(find.byKey(drawerKey), findsNothing);
  });
  testWidgets('a topic drawer opened by address slides in too', (tester) async {
    debugWebPlatformOverride = true;
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await fixtures.pump(
      tester,
      initialPath: '/performance/topic/Geometry',
      realTopic: true,
      settle: false,
    );
    final layer = find.byType(WebOverlayLayer);
    for (var i = 0; i < 20 && layer.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    expect(layer, findsOneWidget);
    final panel = find
        .descendant(
          of: layer,
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == 440,
          ),
        )
        .first;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getTopLeft(panel).dx, inExclusiveRange(1000, 1440));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(panel).dx, 1000);
  });
  group('a topic drawer opened by address leaves with an exit', () {
    Future<void> openByAddress(
      WidgetTester tester, {
      bool still = false,
    }) async {
      debugWebPlatformOverride = true;
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      if (still) {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await fixtures.pump(
        tester,
        initialPath: '/performance/topic/Geometry',
        realTopic: true,
      );
      await tester.pumpAndSettle();
      expect(drawerLeft(tester), 1000);
    }

    testWidgets('a scrim tap slides it out, then goes home', (tester) async {
      await openByAddress(tester);
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(drawerLeft(tester), inExclusiveRange(1000, 1440));
      expect(find.text('open'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(find.byKey(drawerKey), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Esc in the drawer does the same', (tester) async {
      await openByAddress(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(drawerLeft(tester), inExclusiveRange(1000, 1440));
      expect(find.text('open'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('a second tap while it leaves does nothing more',
        (tester) async {
      await openByAddress(tester);
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tapAt(const Offset(100, 100));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reduced motion goes home at once', (tester) async {
      await openByAddress(tester, still: true);
      await tester.tapAt(const Offset(100, 100));
      await tester.pump();
      await tester.pump();
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('Back on a pushed topic page plays the exit, then pops',
        (tester) async {
      debugWebPlatformOverride = true;
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await fixtures.pump(tester, realTopic: true);
      await tester.pumpAndSettle();
      GoRouter.of(tester.element(find.byType(PerformanceScreen)))
          .push<void>('/performance/topic/Geometry')
          .ignore();
      await tester.pumpAndSettle();
      expect(drawerLeft(tester), 1000);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      await navigator.maybePop();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(drawerLeft(tester), inExclusiveRange(1000, 1440));
      await tester.pumpAndSettle();
      expect(find.byKey(drawerKey), findsNothing);
      expect(find.text('Your performance'), findsOneWidget);
    });
  });
  testWidgets('reduced motion shows a topic drawer at once', (tester) async {
    debugWebPlatformOverride = true;
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await fixtures.pump(
      tester,
      initialPath: '/performance/topic/Geometry',
      realTopic: true,
    );
    await tester.pump();
    await tester.pump();
    expect(drawerLeft(tester), 1000);
  });
}

class _Order extends TableOrderNotifier {
  @override
  Future<TableOrder> build() async => TableOrder.defaults;
}
