import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/presentation/widgets/web_record_layout.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

void main() {
  for (final width in [1440.0, 1023.0]) {
    testWidgets('shell at $width uses the single web breakpoint',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var tab = -1;
      var searches = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: WebShellFrame(
            web: true,
            activeIndex: 0,
            person: 'Aedwon',
            exam: 'CSE',
            plan: 'Free',
            onNavigate: (i) => tab = i,
            onSearch: () => searches++,
            child: const Text('Route content'),
          ),
        ),
      );
      expect(find.text('Route content'), findsOneWidget);
      if (width >= 1024) {
        expect(find.text('Pantas'), findsOneWidget);
        expect(find.text('CSE · Free'), findsOneWidget);
        expect(tester.getSize(find.byType(WebSidebar)).width, 230.4);
        await tester.tap(find.text('Quiz'));
        expect(tab, 2);
        await tester.tap(find.text('Search lessons'));
        expect(searches, 1);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        expect(searches, 2);
        expect(find.textContaining('Wrapped'), findsNothing);
      } else {
        expect(find.byType(WebSidebar), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'the page area reaches the window bottom and scrolling rows '
      'run to the edge (A-30)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    // The real child is the shell route's Navigator, whose Overlay clips to
    // its own box, so a page cannot paint into padding the shell leaves.
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: WebShellFrame(
          web: true,
          activeIndex: 0,
          person: 'Aedwon',
          exam: 'CSE',
          plan: 'Free',
          onNavigate: (_) {},
          onSearch: () {},
          child: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => WebMyPage(
                title: 'Your record',
                onBack: () {},
                child: Column(
                  children: [
                    for (var i = 0; i < 40; i++)
                      SizedBox(
                        key: ValueKey('row-$i'),
                        height: 80,
                        child: Text('Row $i'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final area = tester.getRect(find.byType(Navigator).first);
    expect(area.bottom, 900);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
    // A row painted in the band the shell used to pad is still on screen.
    final inBand = [
      for (var i = 0; i < 40; i++)
        if (find.byKey(ValueKey('row-$i')).evaluate().isNotEmpty &&
            tester.getRect(find.byKey(ValueKey('row-$i'))).bottom > 856 &&
            tester.getRect(find.byKey(ValueKey('row-$i'))).top < 856)
          i,
    ];
    expect(inBand, isNotEmpty);
    // At the end of the page the last row rests 44 px above the bottom.
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -6000),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(const ValueKey('row-39'))).bottom, 856);
  });
  testWidgets(
      'on a landscape tablet the page reaches the window bottom, scrolls '
      'under the navigation and ends 100 px above it (3K-9)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1180, 820);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    // The real child is the shell route's Navigator, whose Overlay clips to
    // its own box, so a page cannot paint into padding the shell leaves.
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: WebShellFrame(
          web: true,
          activeIndex: 0,
          person: 'Aedwon',
          exam: 'CSE',
          plan: 'Free',
          onNavigate: (_) {},
          onSearch: () {},
          child: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => WebMyPage(
                title: 'Your record',
                onBack: () {},
                child: Column(
                  children: [
                    for (var i = 0; i < 40; i++)
                      SizedBox(
                        key: ValueKey('row-$i'),
                        height: 80,
                        child: Text('Row $i'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final area = tester.getRect(find.byType(Navigator).first);
    expect(area.bottom, 820);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
    // A row painted in the band the shell used to pad (under the
    // navigation) is still on screen.
    final inBand = [
      for (var i = 0; i < 40; i++)
        if (find.byKey(ValueKey('row-$i')).evaluate().isNotEmpty &&
            tester.getRect(find.byKey(ValueKey('row-$i'))).bottom > 720 &&
            tester.getRect(find.byKey(ValueKey('row-$i'))).top < 720)
          i,
    ];
    expect(inBand, isNotEmpty);
    // At the end of the page the last row rests 100 px above the bottom.
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -6000),
    );
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(const ValueKey('row-39'))).bottom, 720);
  });
  testWidgets(
      'Tab never stops on the page node that holds the shortcuts (3K-11)',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: WebShellFrame(
          web: true,
          activeIndex: 0,
          person: 'Aedwon',
          exam: 'CSE',
          plan: 'Free',
          onNavigate: (_) {},
          onSearch: () {},
          child: WebMyPage(
            title: 'Your record',
            onBack: () {},
            child: TextButton(onPressed: () {}, child: const Text('Body')),
          ),
        ),
      ),
    );
    await tester.pump();
    // Two full turns: the sidebar, Back and the body, then round again.
    for (var i = 0; i < 14; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final context = FocusManager.instance.primaryFocus?.context;
      expect(context, isNotNull);
      expect(
        context!.findAncestorWidgetOfExactType<InkWell>(),
        isNotNull,
        reason: 'Tab $i stopped on a node that draws nothing',
      );
    }
  });
  testWidgets('native at 1440 keeps the existing child without a sidebar',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: WebShellFrame(
          web: false,
          activeIndex: 1,
          person: 'Aedwon',
          exam: 'CSE',
          plan: 'Pro',
          onNavigate: (_) {},
          onSearch: () {},
          child: const Text('Native shell'),
        ),
      ),
    );
    expect(find.byType(WebSidebar), findsNothing);
    expect(find.text('Native shell'), findsOneWidget);
  });
  test('sidebar route family excludes focused sessions and onboarding', () {
    for (final path in [
      '/home',
      '/study',
      '/quiz',
      '/settings/account',
      '/plan/week/2026-10-30',
      '/record',
      '/performance',
      '/tendencies',
      '/quiz/mock/setup',
      '/quiz/practice/cse',
      '/legal/privacy',
    ]) {
      expect(webSidebarRoute(path), isTrue, reason: path);
    }
    for (final path in [
      '/onboarding',
      '/lesson/1',
      '/quiz/today/cse',
      '/quiz/practice/cse/run',
      '/quiz/mock/start',
      '/assessment/cse',
      '/mock/results/1',
      '/update-required',
    ]) {
      expect(webSidebarRoute(path), isFalse, reason: path);
    }
  });
}
