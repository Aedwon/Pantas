import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/contents_glyph.dart';

import '../../../helpers/pump_app.dart';

void main() {
  final paint = find.descendant(
    of: find.byType(ContentsGlyph),
    matching: find.byType(CustomPaint),
  );
  testWidgets('Contents glyph preserves the default three-path stroke',
      (tester) async {
    await tester.pumpApp(const ContentsGlyph());
    expect(tester.getSize(paint), const Size(22, 22));
    expect(
      find.byType(ContentsGlyph),
      paints
        ..path(strokeWidth: 1.5 * 22 / 24)
        ..path(strokeWidth: 1.5 * 22 / 24)
        ..path(strokeWidth: 1.5 * 22 / 24),
    );
  });

  testWidgets('reader Contents glyph uses23px and1.8 in SVG coordinates',
      (tester) async {
    const color = Color(0xFF8E8E93);
    final stroke = Float32List.fromList([1.8 * 23 / 24]).single;
    await tester.pumpApp(
      const ContentsGlyph(
        size: 23,
        strokeWidth: 1.8,
        color: color,
      ),
    );
    expect(tester.getSize(paint), const Size(23, 23));
    expect(
      find.byType(ContentsGlyph),
      paints
        ..path(strokeWidth: stroke, color: color)
        ..path(strokeWidth: stroke, color: color)
        ..path(strokeWidth: stroke, color: color),
    );
  });

  testWidgets('changing only Contents stroke repaints the existing painter',
      (tester) async {
    await tester.pumpApp(const ContentsGlyph());
    final oldPainter = tester.widget<CustomPaint>(paint).painter!;
    await tester.pumpApp(const ContentsGlyph(strokeWidth: 1.8));
    final newPainter = tester.widget<CustomPaint>(paint).painter!;
    expect(newPainter.shouldRepaint(oldPainter), isTrue);
  });
}
