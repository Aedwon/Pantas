import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// On a phone the expand button sits clear of the figure it opens, so it never
/// covers a label drawn in the figure's corner (4O-8). Wide reader figures
/// keep the approved 22 px padded card with the button in its corner.
String _svg() {
  const svg = '<svg xmlns="http://www.w3.org/2000/svg" width="400" '
      'height="220" viewBox="0 0 400 220">'
      ' <rect x="2" y="2" width="396" height="216" fill="none" '
      'stroke="currentColor" stroke-width="4"/></svg>';
  return 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
}

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  for (final reader in [true, false]) {
    testWidgets('the phone expand button clears the figure, reader=$reader',
        (tester) async {
      debugWebPlatformOverride = false;
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 342,
                child: ContentRenderer(
                  readerFigures: reader,
                  blocks: [
                    {
                      '_type': 'image',
                      'asset': {'url': _svg(), 'credit': 'Pantas'},
                      'alt': 'A figure',
                    },
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final button = tester.getRect(
        find.descendant(
          of: find.byTooltip('Expand figure'),
          matching: find.byType(Container),
        ),
      );
      final figure = tester.getRect(
        find
            .byWidgetPredicate(
              (w) => w.runtimeType.toString().contains('RawPicture'),
            )
            .first,
      );
      expect(
        button.overlaps(figure),
        isFalse,
        reason: 'button $button covers the figure $figure',
      );
    });
  }
}
