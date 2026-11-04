import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/reader_transition.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The lesson figure viewer: opens fitted to the whole figure, zooms between
/// one and five times, pans only within the figure, and leaves the lesson
/// behind it where it was.
const phone = Size(390, 844);
const wide = Size(1440, 900);

// The Figure Grouping drawing is 449 by 257; the other is the same shape
// turned on its side. Both carry a border so a crop shows.
const landscape = Size(449, 257);
const portrait = Size(257, 449);

String svgUrl(Size size) {
  final svg = [
    '<svg xmlns="http://www.w3.org/2000/svg" width="${size.width}" ',
    'height="${size.height}" viewBox="0 0 ${size.width} ${size.height}">',
    '<rect x="2" y="2" width="${size.width - 4}" height="${size.height - 4}" ',
    'fill="none" stroke="currentColor" stroke-width="4"/></svg>',
  ].join();
  return 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
}

void main() {
  late GoRouter router;
  const lessonKey = ValueKey('lesson-title');

  tearDown(() => debugWebPlatformOverride = null);

  Future<void> openViewer(
    WidgetTester tester, {
    required Size screen,
    required Size figure,
    bool disableAnimations = false,
  }) async {
    debugWebPlatformOverride = screen.width >= 1280;
    tester.view
      ..physicalSize = screen
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (_, state) => readerPage(
            key: state.pageKey,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: screen.width >= 1280 ? 680 : 342,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Figure Grouping', key: lessonKey),
                      ContentRenderer(
                        readerFigures: true,
                        blocks: [
                          {
                            '_type': 'image',
                            'asset': {
                              'url': svgUrl(figure),
                              'credit': 'Pantas',
                            },
                            'alt': 'Five shapes',
                          },
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: buildLightTheme(web: screen.width >= 1280),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pumpAndSettle();
  }

  Finder viewer() => find.byType(InteractiveViewer);

  Matrix4 matrix(WidgetTester tester) => tester
      .widget<InteractiveViewer>(viewer())
      .transformationController!
      .value;

  double zoom(WidgetTester tester) => matrix(tester).getMaxScaleOnAxis();

  // flutter_svg draws through a private vector graphics widget.
  Rect figureRect(WidgetTester tester) => tester.getRect(
        find
            .descendant(
              of: viewer(),
              matching: find.byWidgetPredicate(
                (widget) => widget.runtimeType.toString().contains('Vector'),
              ),
            )
            .first,
      );

  /// Where the viewer's content (the figure and its card) is drawn right now,
  /// after the viewer's transform. It must always cover the viewer's window.
  Rect shownContent(WidgetTester tester) {
    final box = tester.getRect(viewer());
    return MatrixUtils.transformRect(matrix(tester), Offset.zero & box.size)
        .shift(box.topLeft);
  }

  void expectCovers(WidgetTester tester, {String? reason}) {
    final box = tester.getRect(viewer());
    final shown = shownContent(tester);
    expect(shown.left, lessThanOrEqualTo(box.left + .01), reason: reason);
    expect(shown.top, lessThanOrEqualTo(box.top + .01), reason: reason);
    expect(shown.right, greaterThanOrEqualTo(box.right - .01), reason: reason);
    expect(
      shown.bottom,
      greaterThanOrEqualTo(box.bottom - .01),
      reason: reason,
    );
  }

  for (final screen in [phone, wide]) {
    for (final figure in [landscape, portrait]) {
      final name = '${screen.width.toInt()}x${screen.height.toInt()} '
          '${figure.width > figure.height ? 'landscape' : 'portrait'}';

      testWidgets('opens fitted to the whole figure, $name', (tester) async {
        await openViewer(tester, screen: screen, figure: figure);
        expect(find.byType(InteractiveViewer), findsOneWidget);
        expect(matrix(tester), Matrix4.identity());
        final rect = figureRect(tester);
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.top, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(screen.width));
        expect(rect.bottom, lessThanOrEqualTo(screen.height));
        expect(
          figureRect(tester).height / figureRect(tester).width,
          closeTo(figure.height / figure.width, .01),
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('the lesson does not move while the viewer is open, $name',
          (tester) async {
        // The lesson is laid out before the viewer opens, so measure it first.
        debugWebPlatformOverride = screen.width >= 1280;
        await openViewer(tester, screen: screen, figure: figure);
        final open = tester.getRect(find.byKey(lessonKey));
        await tester.tap(find.byTooltip('Close figure'));
        await tester.pumpAndSettle();
        final closed = tester.getRect(find.byKey(lessonKey));
        expect(open, closed);
      });
    }
  }

  testWidgets('the lesson holds still through the whole opening',
      (tester) async {
    // Open by hand so the frames in between can be measured.
    debugWebPlatformOverride = true;
    tester.view
      ..physicalSize = wide
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (_, state) => readerPage(
            key: state.pageKey,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 680,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Figure Grouping', key: lessonKey),
                      ContentRenderer(
                        readerFigures: true,
                        blocks: [
                          {
                            '_type': 'image',
                            'asset': {'url': svgUrl(landscape)},
                            'alt': 'Five shapes',
                          },
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: buildLightTheme(web: true),
      ),
    );
    await tester.pumpAndSettle();
    final before = tester.getRect(find.byKey(lessonKey));
    await tester.tap(find.byTooltip('Expand figure'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getRect(find.byKey(lessonKey)), before);
    }
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byKey(lessonKey)), before);
  });

  group('wide', () {
    testWidgets('plus and minus zoom about the center and stay clamped',
        (tester) async {
      await openViewer(tester, screen: wide, figure: landscape);
      final box = tester.getRect(viewer());
      final center = box.center;
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      expect(zoom(tester), closeTo(1.25, .001));
      // The point at the middle of the figure stays at the middle.
      expect(
        MatrixUtils.transformPoint(matrix(tester), center - box.topLeft) +
            box.topLeft,
        offsetMoreOrLessEquals(center, epsilon: .01),
      );
      for (var i = 0; i < 30; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      }
      expect(zoom(tester), 3);
      for (var i = 0; i < 40; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.minus);
      }
      expect(zoom(tester), 1);
      expect(matrix(tester), Matrix4.identity());
    });

    testWidgets('zooming out after a pan never leaves the figure',
        (tester) async {
      await openViewer(tester, screen: wide, figure: landscape);
      for (var i = 0; i < 8; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      }
      await tester.drag(viewer(), const Offset(-4000, -4000));
      await tester.pump();
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.minus);
        expectCovers(tester);
      }
    });

    testWidgets('the wheel zooms from anywhere on the scrim, within 1 to 3',
        (tester) async {
      await openViewer(tester, screen: wide, figure: landscape);
      const far = Offset(60, 60);
      final pointer = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(pointer.hover(far));
      await tester.sendEventToBinding(pointer.scroll(const Offset(0, -100)));
      await tester.pump();
      expect(zoom(tester), greaterThan(1));
      for (var i = 0; i < 20; i++) {
        await tester.sendEventToBinding(pointer.scroll(const Offset(0, -400)));
      }
      await tester.pump();
      expect(zoom(tester), 3);
      for (var i = 0; i < 20; i++) {
        await tester.sendEventToBinding(pointer.scroll(const Offset(0, 400)));
      }
      await tester.pump();
      expect(zoom(tester), closeTo(1, 1e-6));
      expect(matrix(tester).getTranslation().length, closeTo(0, 1e-6));
    });

    testWidgets('Escape closes it and the scrim covers the whole screen',
        (tester) async {
      await openViewer(tester, screen: wide, figure: landscape);
      expect(
        tester.getRect(find.byKey(const ValueKey('web-figure-scrim'))),
        Offset.zero & wide,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(viewer(), findsNothing);
    });
  });

  for (final screen in [phone, wide]) {
    final name = '${screen.width.toInt()}x${screen.height.toInt()}';

    testWidgets(
        'the window fills the screen, so zooming is not cropped to '
        'the figure, $name', (tester) async {
      await openViewer(tester, screen: screen, figure: landscape);
      final window = tester.getRect(viewer());
      expect(window.width, screen.width);
      expect(window.height, greaterThan(screen.height * .85));
    });

    testWidgets('a figure keeps its shape from the page, $name',
        (tester) async {
      await openViewer(tester, screen: screen, figure: landscape);
      final rect = figureRect(tester);
      expect(rect.width / rect.height, closeTo(landscape.aspectRatio, .01));
    });

    testWidgets('a click on the figure stays, a click beside it closes, $name',
        (tester) async {
      await openViewer(tester, screen: screen, figure: landscape);
      await tester.tapAt(figureRect(tester).center);
      await tester.pumpAndSettle();
      expect(viewer(), findsOneWidget);
      await tester.tapAt(Offset(screen.width / 2, screen.height - 60));
      await tester.pumpAndSettle();
      expect(viewer(), findsNothing);
    });

    testWidgets('a pinch stops at the most zoom, $name', (tester) async {
      await openViewer(tester, screen: screen, figure: landscape);
      final center = tester.getCenter(viewer());
      final a = await tester.startGesture(center - const Offset(20, 0));
      final b = await tester.startGesture(center + const Offset(20, 0));
      await a.moveBy(const Offset(-30, 0));
      await b.moveBy(const Offset(30, 0));
      await tester.pump();
      await a.moveBy(const Offset(-300, 0));
      await b.moveBy(const Offset(300, 0));
      await tester.pump();
      expect(zoom(tester), screen == wide ? 3 : 5);
      await a.moveBy(const Offset(330, 0));
      await b.moveBy(const Offset(-330, 0));
      await tester.pump();
      expect(zoom(tester), 1);
      await a.up();
      await b.up();
    });

    testWidgets('panning never shows past the figure, $name', (tester) async {
      await openViewer(tester, screen: screen, figure: landscape);
      final center = tester.getCenter(viewer());
      final a = await tester.startGesture(center - const Offset(20, 0));
      final b = await tester.startGesture(center + const Offset(20, 0));
      await a.moveBy(const Offset(-30, 0));
      await b.moveBy(const Offset(30, 0));
      await a.up();
      await b.up();
      await tester.pump();
      expect(zoom(tester), greaterThan(1));
      for (final far in const [
        Offset(-5000, 0),
        Offset(5000, 0),
        Offset(0, -5000),
        Offset(0, 5000),
        Offset(5000, 5000),
        Offset(-5000, -5000),
      ]) {
        await tester.drag(viewer(), far, warnIfMissed: false);
        await tester.pump();
        expectCovers(tester, reason: '$far');
      }
    });
  }

  testWidgets('reduced motion shows the viewer at once, fitted',
      (tester) async {
    await openViewer(
      tester,
      screen: wide,
      figure: landscape,
      disableAnimations: true,
    );
    expect(matrix(tester), Matrix4.identity());
    expect(
      tester
          .widget<Opacity>(find.byKey(const ValueKey('reader-viewer-fade')))
          .opacity,
      1,
    );
  });
}
