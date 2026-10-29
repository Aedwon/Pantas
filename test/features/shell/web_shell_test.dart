import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
        expect(tester.getSize(find.byType(WebSidebar)).width, 244);
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
