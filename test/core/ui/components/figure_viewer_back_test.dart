import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/platform/figure_viewer_back.dart';
import 'package:pantas/core/platform/figure_viewer_history.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// 3M-4. Browser Back changes the address instead of popping, so it left the
/// lesson with the viewer open. The lesson route asks the viewer first: the
/// viewer closes, as Esc does, and the lesson stays.
String _svg() {
  const svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="200" height="120" '
      'viewBox="0 0 200 120"><rect x="2" y="2" width="196" height="116" '
      'fill="none" stroke="currentColor" stroke-width="4"/></svg>';
  return 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
}

void main() {
  late ProviderContainer container;
  late GoRouter router;

  /// What the fake browser history saw: entries opened, and released.
  var opened = 0;
  var released = 0;
  VoidCallback? browserBack;

  Future<void> open(WidgetTester tester) async {
    opened = 0;
    released = 0;
    browserBack = null;
    container = ProviderContainer(
      overrides: [
        figureViewerHistoryProvider.overrideWithValue((onBack) {
          opened++;
          browserBack = onBack;
          return () => released++;
        }),
      ],
    );
    addTearDown(container.dispose);
    router = GoRouter(
      initialLocation: '/study',
      routes: [
        GoRoute(
          path: '/study',
          builder: (_, __) => const Scaffold(body: Text('Study page')),
        ),
        GoRoute(
          path: '/lesson',
          onExit: (context, state) =>
              container.read(figureViewerBackProvider).allowLeave(),
          builder: (_, __) => Scaffold(
            body: Column(
              children: [
                const Text('Lesson page'),
                ContentRenderer(
                  readerFigures: true,
                  blocks: [
                    {
                      '_type': 'image',
                      'asset': {'url': _svg(), 'credit': 'Pantas'},
                      'alt': 'A box',
                    },
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
          theme: buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(router.push('/lesson'));
    await tester.pumpAndSettle();
  }

  testWidgets('Back with the viewer open closes it and stays on the lesson',
      (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);

    // Browser Back: the address returns to the page before the lesson.
    router.go('/study');
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.text('Lesson page'), findsOneWidget);
    expect(find.text('Study page'), findsNothing);
  });

  testWidgets('Back with the viewer closed leaves the lesson', (tester) async {
    await open(tester);
    router.go('/study');
    await tester.pumpAndSettle();
    expect(find.text('Study page'), findsOneWidget);
  });

  testWidgets('a closed viewer no longer holds Back', (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(container.read(figureViewerBackProvider).running, isNull);
    router.go('/study');
    await tester.pumpAndSettle();
    expect(find.text('Study page'), findsOneWidget);
  });

  // 6U-5: a page opened as a fresh load has no earlier page of the app, so
  // browser Back never reached the route and left the app with the viewer.
  // The viewer has a history entry of its own that Back removes first.
  testWidgets('the viewer opens one history entry and Back on it closes it',
      (tester) async {
    await open(tester);
    expect(opened, 0);
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(find.byType(InteractiveViewer), findsOneWidget);

    browserBack!();
    await tester.pumpAndSettle();

    expect(find.byType(InteractiveViewer), findsNothing);
    expect(find.text('Lesson page'), findsOneWidget);
    expect(find.text('Study page'), findsNothing);
  });

  testWidgets('closing the viewer another way releases its history entry',
      (tester) async {
    await open(tester);
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pumpAndSettle();
    expect(released, 0);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsNothing);
    expect(released, 1);
  });
}
