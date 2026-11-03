import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/leave_page.dart';

void main() {
  group('under a router', () {
    late GoRouter router;
    late List<Object?> results;

    Future<void> pump(WidgetTester tester, Widget Function() page) async {
      results = [];
      router = GoRouter(
        initialLocation: '/start',
        routes: [
          GoRoute(
            path: '/start',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    results.add(await context.push<Object?>('/page')),
                child: const Text('open'),
              ),
            ),
          ),
          GoRoute(path: '/page', builder: (_, __) => page()),
          GoRoute(
            path: '/fallback',
            builder: (_, __) => const Scaffold(body: Text('fallback page')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    }

    Widget leaveButton({
      Object? result,
      bool respectPopScope = true,
      bool block = false,
    }) =>
        Builder(
          builder: (context) => PopScope<Object?>(
            canPop: !block,
            child: Scaffold(
              body: TextButton(
                onPressed: () => leavePage(
                  context,
                  fallback: '/fallback',
                  result: result,
                  respectPopScope: respectPopScope,
                ),
                child: const Text('leave'),
              ),
            ),
          ),
        );

    testWidgets('pops back to the page before, with the result',
        (tester) async {
      await pump(tester, () => leaveButton(result: 'saved'));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('leave'));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
      expect(results, ['saved']);
    });

    testWidgets('goes to the fallback when the page was opened directly',
        (tester) async {
      await pump(tester, () => leaveButton(result: 'saved'));
      router.go('/page');
      await tester.pumpAndSettle();
      expect(Navigator.canPop(tester.element(find.text('leave'))), isFalse);
      await tester.tap(find.text('leave'));
      await tester.pumpAndSettle();
      expect(find.text('fallback page'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/fallback');
    });

    testWidgets('respects a PopScope that blocks the pop', (tester) async {
      await pump(tester, () => leaveButton(block: true));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('leave'));
      await tester.pumpAndSettle();
      expect(find.text('leave'), findsOneWidget);
      expect(results, isEmpty);
    });

    testWidgets('can pop past a PopScope when asked to', (tester) async {
      await pump(
        tester,
        () => leaveButton(block: true, respectPopScope: false),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('leave'));
      await tester.pumpAndSettle();
      expect(find.text('open'), findsOneWidget);
    });
  });

  // On web the shell gives a page its own Navigator, so a page pushed from
  // above (a lesson) can be first in that Navigator while the router can
  // still pop. go_router 17.5 asserts on a ShellRoute pushed above a page,
  // so the shell's Navigator is stood in for by one in the page builder.
  group('a page that is first in a nested Navigator', () {
    testWidgets('goes back through the router, with the result',
        (tester) async {
      final results = <Object?>[];
      final router = GoRouter(
        initialLocation: '/lesson',
        routes: [
          GoRoute(
            path: '/lesson',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () async =>
                    results.add(await context.push<Object?>('/page')),
                child: const Text('lesson'),
              ),
            ),
          ),
          GoRoute(
            path: '/page',
            builder: (_, __) => Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => leavePage(
                      context,
                      fallback: '/fallback',
                      result: 'saved',
                    ),
                    child: const Text('leave'),
                  ),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/fallback',
            builder: (_, __) => const Scaffold(body: Text('fallback page')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.tap(find.text('lesson'));
      await tester.pumpAndSettle();
      expect(Navigator.canPop(tester.element(find.text('leave'))), isFalse);
      expect(router.canPop(), isTrue);
      await tester.tap(find.text('leave'));
      await tester.pumpAndSettle();
      expect(find.text('lesson'), findsOneWidget);
      expect(router.routeInformationProvider.value.uri.path, '/lesson');
      expect(results, ['saved']);
    });
  });

  group('with no router above', () {
    testWidgets('pops when the Navigator can, with the result', (tester) async {
      Object? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async =>
                  result = await Navigator.of(context).push<Object?>(
                MaterialPageRoute(
                  builder: (_) => Builder(
                    builder: (context) => TextButton(
                      onPressed: () => leavePage(
                        context,
                        fallback: '/fallback',
                        result: 7,
                      ),
                      child: const Text('leave'),
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('leave'));
      await tester.pumpAndSettle();
      expect(result, 7);
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('does nothing, and does not throw, with nowhere to go',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => leavePage(context, fallback: '/fallback'),
              child: const Text('leave'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('leave'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('leave'), findsOneWidget);
    });
  });
}
