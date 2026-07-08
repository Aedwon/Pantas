import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ContentsGlyph extends StatelessWidget {
  const ContentsGlyph({
    this.size = 22.0,
    this.color,
    super.key,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.ink;
    return CustomPaint(
      size: Size(size, size),
      painter: _ContentsGlyphPainter(color: effectiveColor),
    );
  }
}

class _ContentsGlyphPainter extends CustomPainter {
  const _ContentsGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round
      ..color = color;

    final path1 = Path()
      ..moveTo(4 * scale, 7 * scale)
      ..lineTo(20 * scale, 7 * scale);
    final path2 = Path()
      ..moveTo(4 * scale, 12 * scale)
      ..lineTo(16 * scale, 12 * scale);
    final path3 = Path()
      ..moveTo(4 * scale, 17 * scale)
      ..lineTo(12 * scale, 17 * scale);

    canvas
      ..drawPath(path1, stroke)
      ..drawPath(path2, stroke)
      ..drawPath(path3, stroke);
  }

  @override
  bool shouldRepaint(_ContentsGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}
