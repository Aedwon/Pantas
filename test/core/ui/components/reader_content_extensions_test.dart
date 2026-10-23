import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import '../../../helpers/accessibility.dart';
import 'w2_test_support.dart';

class _PendingClient extends Fake implements HttpClient {
  @override
  set autoUncompress(bool value) {}
  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      Completer<HttpClientRequest>().future;
}

class _PendingImages extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _PendingClient();
}

const figure = {
  '_type': 'figureSpec',
  'spec': <String, Object?>{'kind': 'test'},
  'semanticsLabel': 'Four layers of Earth',
  'credit': 'Published source',
};
Widget diagram() => ContentRenderer(
      readerFigures: true,
      blocks: const [figure],
      figureBuilder: (_, spec) =>
          const SizedBox(width: 342, height: 223, child: Text('Diagram')),
    );

void main() {
  testWidgets('described missing image is silently skipped without gaps',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(
        readerFigures: true,
        blocks: [
          {'_type': 'image', 'alt': 'Description only'},
        ],
      ),
    );
    expect(find.textContaining('load'), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.byTooltip('Expand figure'), findsNothing);
    expect(tester.getSize(find.byType(ContentRenderer)).height, 0);
  });
  testWidgets('reader keeps the approved malformed content fallback',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(
        readerFigures: true,
        blocks: [
          {'_type': 'unknown'},
        ],
      ),
    );
    expect(find.text('Content unavailable. Update the app.'), findsOneWidget);
  });
  testWidgets('corpus numbered headings and solutions use the reader layout',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(
        readerFigures: true,
        blocks: [
          {
            '_type': 'block',
            'style': 'h3',
            'children': [
              {'text': '#1: Why the Outer Core Is Liquid'},
            ],
          },
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {'text': 'A question.'},
            ],
          },
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {
                'text': 'Solution:',
                'marks': ['strong'],
              }
            ],
          },
          {
            '_type': 'block',
            'style': 'normal',
            'listItem': 'number',
            'children': [
              {'text': 'First step.'},
            ],
          },
          {
            '_type': 'block',
            'style': 'normal',
            'listItem': 'number',
            'children': [
              {'text': 'Second step.'},
            ],
          },
        ],
      ),
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Why the Outer Core Is Liquid'), findsOneWidget);
    expect(find.text('SOLUTION'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('SOLUTION')).style!.letterSpacing,
      .48,
    );
  });

  testWidgets('reader math failures keep the approved fallback',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(
        readerFigures: true,
        blocks: [
          {'_type': 'latex', 'body': r'\badcommand'},
          {
            '_type': 'block',
            'children': [
              {
                'text': r'\badcommand',
                'marks': ['latex'],
              }
            ],
          },
        ],
      ),
    );
    expect(find.text('Content unavailable. Update the app.'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
  testWidgets('figure viewer reduced motion shows its final frame',
      (tester) async {
    await pumpAccessibilitySurface(tester, diagram(), disableAnimations: true);
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Opacity>(find.byKey(const ValueKey('reader-viewer-fade')))
          .opacity,
      1,
    );
    expect(
      tester
          .widget<Transform>(
            find.byKey(const ValueKey('reader-viewer-scale')),
          )
          .transform
          .storage[0],
      1,
    );
  });
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
          'reader frames credits and keyboard viewer $brightness $scale',
          (tester) async {
        await pumpAccessibilitySurface(
          tester,
          diagram(),
          brightness: brightness,
          textScale: scale,
          viewportSize: const Size(390, 844),
        );
        final frame = tester.widget<Container>(
          find.byKey(const ValueKey('reader-figure-frame')),
        );
        final decoration = frame.foregroundDecoration! as BoxDecoration;
        expect((decoration.border! as Border).top.width, .5);
        expect((decoration.borderRadius! as BorderRadius).topLeft.x, 14);
        final credit = tester.widget<Text>(find.text('Published source'));
        expect(credit.style!.fontSize, 11);
        expect(credit.style!.fontWeight, FontWeight.w400);
        final background =
            tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor;
        expectContrast(
          credit.style!.color!,
          background ??
              Theme.of(tester.element(find.byType(Scaffold)))
                  .scaffoldBackgroundColor,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.byType(InteractiveViewer), findsOneWidget);
        expect(find.byTooltip('Close figure'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(InteractiveViewer), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('table shares the frame and fullscreen expansion',
      (tester) async {
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(
        readerFigures: true,
        blocks: [
          {
            '_type': 'table',
            'rows': [
              ['Layer', 'State'],
              ['Core', 'Solid'],
            ],
          }
        ],
      ),
    );
    expect(find.byKey(const ValueKey('reader-figure-frame')), findsOneWidget);
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });
  testWidgets('figure entrance follows 280ms fade and 380ms scale',
      (tester) async {
    await pumpAccessibilitySurface(tester, diagram());
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 140));
    expect(
      tester
          .widget<Opacity>(find.byKey(const ValueKey('reader-viewer-fade')))
          .opacity,
      closeTo(PantasCurves.ease.transform(.5), .001),
    );
    final expected =
        .92 + .08 * const Cubic(.25, .9, .3, 1).transform(140 / 380);
    expect(
      tester
          .widget<Transform>(
            find.byKey(const ValueKey('reader-viewer-scale')),
          )
          .transform
          .storage[0],
      closeTo(expected, .001),
    );
    await tester.pumpAndSettle();
  });
  testWidgets('full screen figure responds to a real pinch', (tester) async {
    await pumpAccessibilitySurface(tester, diagram());
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pumpAndSettle();
    final center = tester.getCenter(find.byType(InteractiveViewer));
    final first =
        await tester.startGesture(center - const Offset(40, 0), pointer: 1);
    final second =
        await tester.startGesture(center + const Offset(40, 0), pointer: 2);
    await first.moveBy(const Offset(-40, 0));
    await second.moveBy(const Offset(40, 0));
    await tester.pump();
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(InteractiveViewer),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(transform.transform.getMaxScaleOnAxis(), greaterThan(1));
    await first.up();
    await second.up();
  });
  testWidgets('image uses nested asset credit and corpus alt', (tester) async {
    final previous = HttpOverrides.current;
    HttpOverrides.global = _PendingImages();
    addTearDown(() => HttpOverrides.global = previous);
    await pumpAccessibilitySurface(
      tester,
      const ContentRenderer(
        readerFigures: true,
        blocks: [
          {
            '_type': 'image',
            'asset': {
              'url': 'https://example.invalid/pending.png',
              'credit': 'USGS, public domain',
            },
            'alt': 'Cutaway Earth',
          }
        ],
      ),
    );
    expect(find.text('USGS, public domain'), findsOneWidget);
    expect(
      tester.widget<Image>(find.byType(Image)).semanticLabel,
      'Cutaway Earth',
    );
    expect(find.byTooltip('Expand figure'), findsNothing);
  });
}
