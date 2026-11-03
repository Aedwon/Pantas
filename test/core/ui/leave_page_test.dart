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
