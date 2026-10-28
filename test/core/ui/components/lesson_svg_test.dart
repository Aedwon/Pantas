import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/lesson_svg.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/pantas_colors.dart';

const drawing =
    '<svg xmlns="http://www.w3.org/2000/svg" width="200" height="100"> '
    '<rect width="200" height="100" fill="currentColor"/></svg>';
String svgUrl(String source) =>
    'data:image/svg+xml;base64,${base64Encode(utf8.encode(source))}';
Map<String, dynamic> image(String url) => {
      '_type': 'image',
      'asset': {'url': url},
      'alt': 'A measured rectangle',
    };

void main() {
  test('lesson SVG font families resolve to bundled fonts', () {
    for (final (family, resolved) in [
      ('Geist, sans-serif', 'Geist'),
      ('KaTeX_Main, serif', 'packages/flutter_math_fork/KaTeX_Main'),
      ('KaTeX_Math, serif', 'packages/flutter_math_fork/KaTeX_Math'),
      ("Unknown, 'Geist', serif", 'Geist'),
    ]) {
      expect(
        resolveLessonSvgFonts('<text font-family="$family"/>'),
        '<text font-family="$resolved"/>',
      );
    }
    expect(
      resolveLessonSvgFonts('''<text font-family=' "KaTeX_Main" , serif '/>'''),
      "<text font-family='packages/flutter_math_fork/KaTeX_Main'/>",
    );
    const unchanged = '<text font-family="Unknown, serif" font-size="12" '
        'data-font-family="Geist, sans-serif">Geist, sans-serif</text>';
    expect(resolveLessonSvgFonts(unchanged), unchanged);
  });

  test('data URL with Geist text and KaTeX tspan renders', () async {
    const source =
        '<svg xmlns="http://www.w3.org/2000/svg" width="200" height="100"> '
        '<text x="10" y="30" font-family="Geist, sans-serif">Area '
        '<tspan font-family="KaTeX_Main, serif">=</tspan> '
        '<tspan font-family="KaTeX_Math, serif">x</tspan> '
        '</text></svg>';
    final picture = await vg.loadPicture(
      lessonSvgLoader(svgUrl(source), PantasColors.light),
      null,
    );
    final raster = await picture.picture.toImage(200, 100);
    raster.dispose();
    picture.picture.dispose();
  });

  for (final colors in [PantasColors.light, PantasColors.dark]) {
    test(
        'SVG palette follows active theme '
        '${colors == PantasColors.light ? 'light' : 'dark'}', () async {
      final expected = [
        colors.label,
        colors.secondaryLabel,
        colors.surface,
        colors.separator,
        colors.accent,
        colors.destructive,
        colors.warningText,
      ];
      final mapper = LessonSvgColors(colors);
      for (var index = 0; index < expected.length; index++) {
        final token = Color(0xFF000000 | ((index + 1) * 0x010101));
        expect(mapper.substitute(null, 'rect', 'fill', token), expected[index]);
      }
      const fixed = Color(0xFF4682B4);
      expect(mapper.substitute(null, 'path', 'stroke', fixed), fixed);
      final picture =
          await vg.loadPicture(lessonSvgLoader(svgUrl(drawing), colors), null);
      final raster = await picture.picture.toImage(200, 100);
      final bytes = (await raster.toByteData())!;
      expect(bytes.getUint8(0), (colors.label.toARGB32() >> 16) & 255);
      expect(bytes.getUint8(1), (colors.label.toARGB32() >> 8) & 255);
      expect(bytes.getUint8(2), colors.label.toARGB32() & 255);
      raster.dispose();
      picture.picture.dispose();
    });
  }

  test('a data URL is decoded once so rebuilds and theme changes reuse it', () {
    final url = svgUrl(drawing);
    final first = lessonSvgLoader(url, PantasColors.light);
    final again = lessonSvgLoader(url, PantasColors.light);
    final dark = lessonSvgLoader(url, PantasColors.dark);
    expect(again, first);
    expect(
      identical(
        (dark as SvgBytesLoader).bytes,
        (first as SvgBytesLoader).bytes,
      ),
      isTrue,
    );
  });
  testWidgets('a parent rebuild keeps the same SVG loader', (tester) async {
    final rebuild = ValueNotifier<int>(0);
    addTearDown(rebuild.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: rebuild,
            builder: (_, __, ___) =>
                ContentRenderer(blocks: [image(svgUrl(drawing))]),
          ),
        ),
      ),
    );
    final before = tester.widget<SvgPicture>(find.byType(SvgPicture));
    rebuild.value++;
    await tester.pump();
    final after = tester.widget<SvgPicture>(find.byType(SvgPicture));
    expect(after.bytesLoader, before.bytesLoader);
  });

  for (final reader in [false, true]) {
    for (final dark in [false, true]) {
      testWidgets('SVG renders with alt text reader=$reader dark=$dark',
          (tester) async {
        final blocks = [image(svgUrl(drawing))];
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? buildDarkTheme() : buildLightTheme(),
            home: Scaffold(
              body: reader
                  ? ContentRenderer(blocks: blocks, readerFigures: true)
                  : ContentRenderer(blocks: blocks),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(SvgPicture), findsOneWidget);
        expect(find.bySemanticsLabel('A measured rectangle'), findsOneWidget);
        expect(find.text('Content unavailable. Update the app.'), findsNothing);
        if (reader) {
          await tester.tap(find.byTooltip('Expand figure'));
          await tester.pumpAndSettle();
          expect(find.byType(InteractiveViewer), findsOneWidget);
          expect(
            find.descendant(
              of: find.byType(InteractiveViewer),
              matching: find.bySemanticsLabel('A measured rectangle'),
            ),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets('legacy content expansion retains SVG alt text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ContentRenderer(blocks: [image(svgUrl(drawing))]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Expand figure'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(InteractiveViewer),
        matching: find.bySemanticsLabel('A measured rectangle'),
      ),
      findsOneWidget,
    );
  });
  testWidgets('remote SVG uses the SVG loader even with a query',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ContentRenderer(
            blocks: [image('https://example.com/figure.SVG?v=2')],
          ),
        ),
      ),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });
  testWidgets('remote PNG uses the current image path', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ContentRenderer(
            blocks: [image('https://example.com/figure.png')],
          ),
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    expect(tester.widget<Image>(find.byType(Image)).image, isA<NetworkImage>());
  });
  for (final reader in [false, true]) {
    testWidgets('invalid SVG uses existing failure state reader=$reader',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: reader
                ? ContentRenderer(
                    blocks: [image(svgUrl('broken'))],
                    readerFigures: true,
                  )
                : ContentRenderer(blocks: [image(svgUrl('broken'))]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          reader ? 'This illustration didn’t load.' : 'Image could not load.',
        ),
        findsOneWidget,
      );
      if (reader) expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  test('malformed data URLs give no bytes and a loader that does not throw',
      () {
    expect(lessonDataUrlBytes('data:image/png'), isNull);
    expect(lessonDataUrlBytes('data:image/png;base64,@@@@'), isNull);
    expect(lessonDataUrlBytes('https://example.com/a.png'), isNull);
    expect(
      () =>
          lessonSvgLoader('data:image/svg+xml;base64,@@@@', PantasColors.light),
      returnsNormally,
    );
  });
  const malformed = [
    'data:image/svg+xml;base64,@@@@',
    'data:image/png;base64,@@@@',
    'data:image/png',
    'data:image/svg+xml;base64,%zz',
  ];
  for (final url in malformed) {
    for (final reader in [false, true]) {
      testWidgets(
          'malformed data URL shows the failure state '
          '$url reader=$reader', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: buildLightTheme(),
            home: Scaffold(
              body: reader
                  ? ContentRenderer(blocks: [image(url)], readerFigures: true)
                  : ContentRenderer(blocks: [image(url)]),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text(
            reader ? 'This illustration didn’t load.' : 'Image could not load.',
          ),
          findsOneWidget,
        );
      });
    }
    testWidgets(
        'malformed data URL shows the failure state in legacy content '
        '$url', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(body: ContentRenderer(blocks: [image(url)])),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Image could not load.'), findsOneWidget);
    });
  }
  Future<String> pngUrl(WidgetTester tester, int width, int height) async {
    final bytes = await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        Paint()..color = const Color(0xFF336699),
      );
      final raster = await recorder.endRecording().toImage(width, height);
      final data = await raster.toByteData(format: ui.ImageByteFormat.png);
      raster.dispose();
      return data!.buffer.asUint8List();
    });
    return 'data:image/png;base64,${base64Encode(bytes!)}';
  }

  String sizedSvg(int width, int height, {bool attributes = true}) =>
      '<svg xmlns="http://www.w3.org/2000/svg" '
      '${attributes ? 'width="$width" height="$height" ' : ''}'
      'viewBox="0 0 $width $height"><rect width="$width" height="$height" '
      'fill="#336699"/></svg>';

  // The frame and the drawing inside it, for a PNG or an SVG figure.
  Future<(Size, Size)> measure(
    WidgetTester tester,
    String url, {
    required String renderer,
  }) async {
    final blocks = [image(url)];
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: switch (renderer) {
              'portable' => ContentRenderer(blocks: blocks),
              'reader' => ContentRenderer(blocks: blocks, readerFigures: true),
              _ => ContentRenderer(blocks: blocks),
            },
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final isSvg = find.byType(SvgPicture).evaluate().isNotEmpty;
    final drawing = isSvg
        ? find.descendant(
            of: find.byType(SvgPicture),
            matching: find.byType(FittedBox),
          )
        : find.byType(Image);
    return (
      tester.getSize(find.byType(SingleChildScrollView)),
      tester.getSize(drawing),
    );
  }

  for (final renderer in ['legacy', 'reader', 'portable']) {
    for (final attributes in [true, false]) {
      for (final (width, height) in [(200, 100), (390, 195), (2000, 1000)]) {
        testWidgets(
          'SVG and PNG figures take the same size '
          '${width}x$height attributes=$attributes renderer=$renderer',
          (tester) async {
            tester.view.physicalSize = const Size(390, 800);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            final png = await pngUrl(tester, width, height);
            final svg = svgUrl(sizedSvg(width, height, attributes: attributes));
            final fromSvg = await measure(tester, svg, renderer: renderer);
            final fromPng = await measure(tester, png, renderer: renderer);
            expect(fromSvg.$2, fromPng.$2, reason: 'drawing size');
            expect(fromSvg.$1.width, fromPng.$1.width, reason: 'frame width');
            expect(
              fromSvg.$1.height,
              fromPng.$1.height,
              reason: 'frame height',
            );
          },
        );
      }
    }
  }
  testWidgets('a PNG data URL draws through the image path with its alt text',
      (tester) async {
    final png = await pngUrl(tester, 40, 20);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(body: ContentRenderer(blocks: [image(png)])),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);
    expect(find.bySemanticsLabel('A measured rectangle'), findsOneWidget);
    expect(find.text('Image could not load.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('a PNG data URL also draws in the portable renderer',
      (tester) async {
    final png = await pngUrl(tester, 40, 20);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(body: ContentRenderer(blocks: [image(png)])),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Content unavailable. Update the app.'), findsNothing);
  });
  // The figure frame is the only ClipRRect with this radius in a figure.
  final frameFinder = find.byWidgetPredicate(
    (widget) =>
        widget is ClipRRect && widget.borderRadius == BorderRadius.circular(14),
  );
  for (final (name, url) in [
    ('PNG', 'data:image/png;base64,AAAA'),
    ('SVG', svgUrl('broken')),
  ]) {
    testWidgets('a failed $name figure shows its failure inside the frame',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(body: ContentRenderer(blocks: [image(url)])),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Image could not load.'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Image could not load.'),
          matching: frameFinder,
        ),
        findsOneWidget,
      );
    });
  }
  testWidgets('a loading SVG figure holds its place inside the frame',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: ContentRenderer(
            blocks: [image('https://example.com/loading.svg')],
          ),
        ),
      ),
    );
    expect(
      find.descendant(
        of: frameFinder,
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 223,
        ),
      ),
      findsOneWidget,
    );
  });
}
