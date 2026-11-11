import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/home/presentation/record_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

import '../helpers/in_memory_database.dart';

late ProviderContainer container;
late AppDatabase database;

/// Pages the mobile boards draw with the floating tab bar, Home lit.
const _homeTabPages = [
  '/plan',
  '/plan/history',
  '/plan/day/2026-11-02',
  '/plan/week/2026-11-02',
  '/performance',
  '/performance/topic/t1',
  '/record',
  '/tendencies',
];

Future<void> _pump(WidgetTester tester, GoRouter router) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

/// Unmounts the app so drift's close timers run before the test ends.
Future<void> _finish(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  container.dispose();
  await tester.runAsync(database.close);
}

/// Route changes parse in a microtask, so the page shows on the second frame.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

int _litTab(WidgetTester tester) =>
    tester.widget<AppNavBar>(find.byType(AppNavBar)).currentIndex;

void main() {
  Future<void> boot() async {
    final db = inMemoryDatabase();
    final contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'cse',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    final preferences = AppPreferencesRepository(db);
    await preferences.setPassedAgeGate(value: true);
    await preferences.setSelectedExamId('cse');
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        entitlementProvider
            .overrideWith((_) => Stream.value(const Entitlement.free())),
        telemetryProvider.overrideWithValue(const DisabledTelemetry()),
      ],
    );
    database = db;
  }

  test('every Home-owned page sits in the Home branch of the tab shell', () {
    final shell =
        buildAppRoutes(_RouteRef()).whereType<StatefulShellRoute>().single;
    final paths = [
      for (final route in shell.branches.first.routes.whereType<GoRoute>())
        route.path,
    ];
    expect(paths.first, '/home');
    expect(paths, containsAll(_homeTabPages.map(_template)));
  });

  // One app instance for the whole flow: repeated drift setup and teardown
  // between widget tests hangs the test binding in this suite.
  testWidgets('Home-owned pages keep the phone tab bar', (tester) async {
    await boot();
    final router = container.read(routerProvider);
    await _pump(tester, router);
    // Every page the boards draw with the bar, Home lit.
    for (final path in _homeTabPages) {
      router.go(path);
      await _settle(tester);
      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        path,
        reason: path,
      );
      expect(find.byType(HomeTab), findsNothing, reason: path);
      expect(find.byType(AppNavBar), findsOneWidget, reason: path);
      expect(_litTab(tester), 0, reason: path);
    }
    router.go('/home');
    await _settle(tester);
    Future<void> settle() => _settle(tester);

    // Back from a pushed page returns to the tab root, bar still there.
    unawaited(router.push('/plan'));
    await settle();
    expect(find.byType(AppNavBar), findsOneWidget);
    expect(router.canPop(), isTrue);
    router.pop();
    await settle();
    expect(
      router.routerDelegate.currentConfiguration.uri.path,
      '/home',
    );
    expect(find.byType(HomeTab), findsOneWidget);
    expect(find.byType(AppNavBar), findsOneWidget);

    // Re-tapping Home on a Home page returns to the Home root.
    unawaited(router.push('/record'));
    await settle();
    expect(find.byType(RecordScreen), findsOneWidget);
    expect(find.byType(AppNavBar), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.bySemanticsLabel('Home'),
      ),
    );
    await settle();
    expect(find.byType(RecordScreen), findsNothing);
    expect(find.byType(HomeTab), findsOneWidget);

    // Settings subpages stay full screen, as on the boards.
    router.go('/settings/about');
    await settle();
    expect(find.byType(AppNavBar), findsNothing);

    // Wide web keeps its sidebar layout and draws no phone tab bar.
    router.go('/home');
    await settle();
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    router.go('/record');
    await settle();
    expect(find.byType(AppNavBar), findsNothing);
    await _finish(tester);
  });
}

String _template(String path) => path
    .replaceFirst('2026-11-02', ':date')
    .replaceFirst('/plan/week/:date', '/plan/week/:start')
    .replaceFirst('/topic/t1', '/topic/:topicId');

class _RouteRef implements Ref {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
