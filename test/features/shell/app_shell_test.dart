import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/settings_bar.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';

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

GoRouter stackRouter() => GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, __, shell) => AppShell(navigationShell: shell),
          branches: [
            for (final tab in ['Home', 'Study', 'Quiz', 'Settings'])
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/${tab.toLowerCase()}',
                    builder: (context, state) => Scaffold(
                      body: Column(
                        children: [
                          if (tab == 'Settings')
                            const SettingsBar(title: 'Settings'),
                          Text('$tab root'),
                          TextButton(
                            onPressed: () =>
                                context.push('/${tab.toLowerCase()}/detail'),
                            child: const Text('Open detail'),
                          ),
                        ],
                      ),
                    ),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        builder: (_, __) => Scaffold(body: Text('$tab detail')),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
    );

Future<void> pumpStack(WidgetTester tester, GoRouter router) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [
          telemetryProvider.overrideWithValue(const DisabledTelemetry()),
        ],
        child:
            MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
      ),
    );

void main() {
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

  testWidgets('every tab keeps its stack and re-tapping pops to its root',
      (tester) async {
    final router = stackRouter();
    addTearDown(router.dispose);
    await pumpStack(tester, router);
    await tester.pumpAndSettle();
    for (final label in ['Home', 'Study', 'Quiz', 'Settings']) {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();
      expect(find.text('$label detail'), findsOneWidget);
    }
    for (final label in ['Home', 'Study', 'Quiz', 'Settings']) {
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pumpAndSettle();
      expect(find.text('$label detail'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(label));
      await tester.pumpAndSettle();
      expect(find.text('$label root'), findsOneWidget);
    }
  });

  testWidgets('Settings branch root has no back button', (tester) async {
    final router = stackRouter();
    addTearDown(router.dispose);
    await pumpStack(tester, router);
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Settings root'), findsOneWidget);
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
