import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

const _sidebar = ['Search lessons', 'Home', 'Study', 'Quiz', 'Settings'];

/// The whole Tab cycle, in the router the app uses (6T-2). A test that stopped
/// after the sidebar's second stop, with the page not behind a Navigator's
/// scope, passed while no page content could be reached.
void main() {
  Widget controls(String name) => Align(
        alignment: Alignment.topLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: () {}, child: Text('$name one')),
            TextButton(onPressed: () {}, child: Text('$name two')),
          ],
        ),
      );

  /// Home, Plan and Performance: a node that only holds the page's keys.
  Widget holdingPage(String name) => Focus(
        autofocus: true,
        skipTraversal: true,
        child: controls(name),
      );

  Future<StatefulNavigationShell Function()> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late StatefulNavigationShell current;
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) {
            current = shell;
            return WebShellFrame(
              web: true,
              activeIndex: shell.currentIndex,
              person: 'Aerol',
              exam: 'CSE Pro',
              plan: 'Pro',
              onNavigate: shell.goBranch,
              onSearch: () {},
              child: shell,
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(path: '/home', builder: (_, __) => holdingPage('Page')),
              ],
            ),
            StatefulShellBranch(
              routes: [
                // A page with no node of its own, as Quiz is.
                GoRoute(path: '/study', builder: (_, __) => controls('Bare')),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        theme: buildDarkTheme(web: true),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    return () => current;
  }

  String? focused() {
    String? text;
    void visit(Element e) {
      if (text != null) return;
      final w = e.widget;
      if (w is Text && w.data != null) {
        text = w.data;
        return;
      }
      e.visitChildren(visit);
    }

    final primary = FocusManager.instance.primaryFocus;
    if (primary == null || primary.skipTraversal) return null;
    if (primary is FocusScopeNode) return null;
    final element = primary.context;
    if (element is Element) element.visitChildren(visit);
    return text;
  }

  Future<List<String?>> tabs(
    WidgetTester tester,
    int count, {
    bool shift = false,
  }) async {
    final seen = <String?>[];
    if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    for (var i = 0; i < count; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      seen.add(focused());
    }
    if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    return seen;
  }

  testWidgets('Tab goes through the sidebar, then the page, then around',
      (tester) async {
    await mount(tester);
    expect(await tabs(tester, 7), [..._sidebar, 'Page one', 'Page two']);
    expect((await tabs(tester, 1)).single, 'Search lessons');
  });

  testWidgets('a page with no node of its own has no invisible stop',
      (tester) async {
    final shell = await mount(tester);
    shell().goBranch(1);
    await tester.pumpAndSettle();
    final seen = await tabs(tester, 7);
    expect(seen, containsAllInOrder(['Bare one', 'Bare two']));
    expect(seen, isNot(contains(null)));
    expect(seen, isNot(contains('Page one')));
  });

  testWidgets('a page left and opened again is still reached', (tester) async {
    final shell = await mount(tester);
    shell().goBranch(1);
    await tester.pumpAndSettle();
    shell().goBranch(0);
    await tester.pumpAndSettle();
    final seen = await tabs(tester, 12);
    expect(seen, contains('Page one'));
    expect(seen, isNot(contains('Bare one')));
    expect(seen, isNot(contains(null)));
  });

  testWidgets('Shift+Tab from the page goes back to the sidebar',
      (tester) async {
    await mount(tester);
    expect((await tabs(tester, 6)).last, 'Page one');
    expect((await tabs(tester, 1, shift: true)).single, 'Settings');
  });
}
