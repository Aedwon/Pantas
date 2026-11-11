import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A figure credit that is only "Pantas" is our own work and draws no
/// caption. A third-party credit stays.
String _svgUrl() {
  const svg = '<svg xmlns="http://www.w3.org/2000/svg" width="100" '
      'height="60" viewBox="0 0 100 60"><rect width="100" height="60"/></svg>';
  return 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
}

void main() {
  Future<void> pump(WidgetTester tester, String credit) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ContentRenderer(
              readerFigures: true,
              blocks: [
                {
                  '_type': 'image',
                  'asset': {'url': _svgUrl(), 'credit': credit},
                  'alt': 'A figure',
                },
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  for (final own in ['Pantas', 'pantas', ' Pantas ']) {
    testWidgets('the credit "$own" draws no caption', (tester) async {
      await pump(tester, own);
      expect(find.text(own), findsNothing);
      expect(find.textContaining('Pantas'), findsNothing);
    });
  }

  testWidgets('a third-party credit still draws its caption', (tester) async {
    await pump(tester, 'Wikimedia Commons');
    expect(find.text('Wikimedia Commons'), findsOneWidget);
  });

  testWidgets('a credit that only contains Pantas is kept', (tester) async {
    await pump(tester, 'Pantas, after NASA');
    expect(find.text('Pantas, after NASA'), findsOneWidget);
  });
}
