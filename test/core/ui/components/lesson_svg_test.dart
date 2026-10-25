import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/components/lesson_svg.dart';
import 'package:pantas/core/ui/components/portable_text_renderer.dart';
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
                  : PortableTextRenderer(blocks: blocks),
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
          body: PortableTextRenderer(
            blocks: [image('https://example.com/figure.SVG?v=2')],
          ),
        ),
      ),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });
  testWidgets('existing remote PNG keeps its cached image path',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: PortableTextRenderer(
            blocks: [image('https://example.com/figure.png')],
          ),
        ),
      ),
    );
    expect(find.byType(CachedNetworkImage), findsOneWidget);
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
                : PortableTextRenderer(blocks: [image(svgUrl('broken'))]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          reader
              ? 'This illustration didn’t load.'
              : 'Content unavailable. Update the app.',
        ),
        findsOneWidget,
      );
      if (reader) expect(find.text('Try Again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
