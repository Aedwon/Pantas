import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// A hairline magnifier icon drawn directly with canvas vector paths.
///
/// 19px box, stroke 1.6, inkMuted: circle of radius 6.5 centred at (10.5, 10.5)
/// with a handle from (15.3, 15.3) to (20, 20).
class InkMagnifier extends StatelessWidget {
  const InkMagnifier({this.size = 19, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MagnifierPainter(
        color: color ?? context.colors.inkMuted,
      ),
    );
  }
}

class _MagnifierPainter extends CustomPainter {
  const _MagnifierPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 19.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6 * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final center = Offset(10.5 * scale, 10.5 * scale);
    final radius = 6.5 * scale;
    canvas.drawCircle(center, radius, paint);

    final handleStart = Offset(15.3 * scale, 15.3 * scale);
    final handleEnd = Offset(20.0 * scale, 20.0 * scale);
    canvas.drawLine(handleStart, handleEnd, paint);
  }

  @override
  bool shouldRepaint(_MagnifierPainter oldDelegate) =>
      oldDelegate.color != color;
}
