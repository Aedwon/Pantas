import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_home.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

import '../../helpers/in_memory_database.dart';

Widget harness({
  required int currentIndex,
  required ValueChanged<int> onTap,
  TextScaler textScaler = TextScaler.noScaling,
  bool dark = false,
  bool disableAnimations = false,
}) =>
    MaterialApp(
      theme: dark ? buildDarkTheme() : buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: textScaler,
          disableAnimations: disableAnimations,
        ),
        child: Scaffold(
          bottomNavigationBar:
              AppNavBar(currentIndex: currentIndex, onTap: onTap),
        ),
      ),
    );

late ProviderContainer shellContainer;

GoRouter stackRouter() => shellContainer.read(routerProvider);

Future<void> pumpStack(WidgetTester tester, GoRouter router) =>
    tester.pumpWidget(
      UncontrolledProviderScope(
        container: shellContainer,
        child:
            MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
      ),
    );

void main() {
  setUpAll(() async {
    final font = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      font.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await font.load();
  });
  setUp(() async {
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
    shellContainer = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        entitlementProvider
            .overrideWith((_) => Stream.value(const Entitlement.free())),
        telemetryProvider.overrideWithValue(const DisabledTelemetry()),
      ],
    );
    addTearDown(() async {
      shellContainer.dispose();
      await db.close();
    });
  });

  test('shell harness uses the complete production route tree', () {
    final router = stackRouter();
    final paths = <String>[];
    void collect(List<RouteBase> routes) {
      for (final route in routes) {
        if (route is GoRoute) paths.add(route.path);
        collect(route.routes);
      }
    }

    collect(router.configuration.routes);
    expect(paths, unorderedEquals(collectRoutePaths()));
  });

  testWidgets('four tabs appear in the approved order with regular glyphs',
      (tester) async {
    await tester.pumpWidget(harness(currentIndex: 0, onTap: (_) {}));
    final labels = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(AppNavBar),
            matching: find.byType(Text),
          ),
        )
        .map((text) => text.data);
    expect(labels, ['Home', 'Study', 'Quiz', 'Settings']);
    expect(
      tester.widgetList<Icon>(find.byType(Icon)).map((icon) => icon.icon),
      [
        PantasIcons.homeTab,
        PantasIcons.studyTab,
        PantasIcons.quizTab,
        PantasIcons.settingsTab,
      ],
    );
  });

  for (final dark in [false, true]) {
    testWidgets(
        'active tab uses accent and approved caption weights, dark=$dark',
        (tester) async {
      await tester
          .pumpWidget(harness(currentIndex: 1, onTap: (_) {}, dark: dark));
      final colors = dark ? PantasColors.dark : PantasColors.light;
      final text = tester.widget<Text>(find.text('Study'));
      expect(text.style!.fontSize, 10);
      expect(text.style!.fontWeight, FontWeight.w600);
      expect(text.style!.color, colors.accent);
      expect(
        tester.widget<Text>(find.text('Home')).style!.fontWeight,
        FontWeight.w500,
      );
    });
  }

  testWidgets('large text keeps targets usable without layout overflow',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      harness(
        currentIndex: 0,
        onTap: (_) {},
        textScaler: const TextScaler.linear(2),
      ),
    );
    expect(tester.takeException(), isNull);
    for (final label in ['Home', 'Study', 'Quiz', 'Settings']) {
      final target = find.ancestor(
        of: find.text(label),
        matching: find.byType(GestureDetector),
      );
      expect(target, findsOneWidget);
      final size = tester.getSize(target);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(tester.widget<Text>(find.text(label)).maxLines, 1);
    }
  });

  testWidgets('selection swaps immediately because the board has no tab motion',
      (tester) async {
    await tester.pumpWidget(harness(currentIndex: 0, onTap: (_) {}));
    await tester.pumpWidget(harness(currentIndex: 2, onTap: (_) {}));
    expect(
      tester.widget<Text>(find.text('Quiz')).style!.color,
      PantasColors.light.accent,
    );
    expect(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.byType(AnimatedBuilder),
      ),
      findsNothing,
    );
  });

  testWidgets('reduce motion preserves the selected final state',
      (tester) async {
    await tester.pumpWidget(
      harness(currentIndex: 3, onTap: (_) {}, disableAnimations: true),
    );
    expect(
      tester.widget<Text>(find.text('Settings')).style!.color,
      PantasColors.light.accent,
    );
  });

  testWidgets('tapping Settings reports index 3', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(harness(currentIndex: 0, onTap: taps.add));
    await tester.tap(find.text('Settings'));
    expect(taps, [3]);
  });

  testWidgets('the current tab is selected in semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(harness(currentIndex: 1, onTap: (_) {}));
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Study'))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Home'))
          .flagsCollection
          .isSelected,
      Tristate.isFalse,
    );
    semantics.dispose();
  });

  testWidgets(
      'every production tab retains its location and re-tap returns to root',
      (tester) async {
    final router = stackRouter();
    await pumpStack(tester, router);
    await tester.pumpAndSettle();
    final tabs = [
      ('Home', '/home', HomeTab),
      ('Study', '/study', StudyTabHome),
      ('Quiz', '/quiz', QuizTabHome),
      ('Settings', '/settings', SettingsHomePage),
    ];
    final pages = <String, Element>{};
    for (final (label, path, type) in tabs) {
      await tester.tap(
        find.descendant(
          of: find.byType(AppNavBar),
          matching: find.bySemanticsLabel(label),
        ),
      );
      await tester.pumpAndSettle();
      router.go('$path?probe=$label');
      await tester.pumpAndSettle();
      pages[label] = tester.element(find.byType(type));
    }
    for (final (label, path, type) in tabs) {
      await tester.tap(
        find.descendant(
          of: find.byType(AppNavBar),
          matching: find.bySemanticsLabel(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        '$path?probe=$label',
      );
      expect(tester.element(find.byType(type)), same(pages[label]));
      await tester.tap(
        find.descendant(
          of: find.byType(AppNavBar),
          matching: find.bySemanticsLabel(label),
        ),
      );
      await tester.pumpAndSettle();
      expect(router.routerDelegate.currentConfiguration.uri.toString(), path);
      expect(find.byType(type), findsOneWidget);
    }
  });

  testWidgets('Settings branch root has no back button', (tester) async {
    final router = stackRouter();
    await pumpStack(tester, router);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AppNavBar),
        matching: find.bySemanticsLabel('Settings'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SettingsHomePage), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(SettingsHomePage),
        matching: find.byType(AppShell),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(SettingsBar),
        matching: find.bySemanticsLabel('Back'),
      ),
      findsNothing,
    );
  });
  testWidgets('floating bar exposes occupied space to scrolling screens',
      (tester) async {
    double? bottom;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryProvider.overrideWithValue(const DisabledTelemetry()),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: AppShell(
            navigationShell: _PaddingProbe((value) => bottom = value),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(bottom, greaterThanOrEqualTo(88));
  });
}

class _PaddingProbe extends StatefulWidget implements StatefulNavigationShell {
  const _PaddingProbe(this.onPadding);
  final ValueChanged<double> onPadding;
  @override
  int get currentIndex => 0;
  @override
  void goBranch(int index, {bool initialLocation = false}) {}
  @override
  State<_PaddingProbe> createState() => _PaddingProbeState();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PaddingProbeState extends State<_PaddingProbe> {
  @override
  Widget build(BuildContext context) {
    widget.onPadding(MediaQuery.paddingOf(context).bottom);
    return const SizedBox();
  }
}
