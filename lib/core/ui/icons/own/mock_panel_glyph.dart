import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// The question-list icon from the boards: a window with a list strip on the
/// left (panel header) or a thick bar on the left (edge tab).
class MockPanelGlyph extends StatelessWidget {
  const MockPanelGlyph({this.tab = false, super.key});
  final bool tab;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size.square(20),
        painter: _MockPanelGlyphPainter(
          tab: tab,
          color: context.colors.textSecondary,
        ),
      );
}

class _MockPanelGlyphPainter extends CustomPainter {
  const _MockPanelGlyphPainter({required this.tab, required this.color});
  final bool tab;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 1.8 * k;
    if (tab) {
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(3.5 * k, 5.5 * k, 17 * k, 13 * k),
            Radius.circular(3 * k), // ds-geometry: glyph corner
          ),
          paint,
        )
        ..drawLine(
          Offset(7.5 * k, 9.5 * k),
          Offset(7.5 * k, 14.5 * k),
          paint..strokeWidth = 2.4 * k,
        );
      return;
    }
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(3.5 * k, 4.5 * k, 17 * k, 15 * k),
          Radius.circular(2.5 * k), // ds-geometry: glyph corner
        ),
        paint,
      )
      ..drawLine(Offset(9.5 * k, 4.5 * k), Offset(9.5 * k, 19.5 * k), paint);
    for (final y in [8.5, 11.5, 14.5]) {
      canvas.drawLine(Offset(5.8 * k, y * k), Offset(7.4 * k, y * k), paint);
    }
  }

  @override
  bool shouldRepaint(_MockPanelGlyphPainter old) =>
      old.tab != tab || old.color != color;
}
