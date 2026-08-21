import 'package:flutter/material.dart';

class BackChevron extends StatelessWidget {
  const BackChevron({this.color, this.size = 15, super.key});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _BackChevronPainter(
        color: color ?? Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _BackChevronPainter extends CustomPainter {
  const _BackChevronPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.7, size.height * 0.15)
      ..lineTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.85);

    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_BackChevronPainter oldDelegate) =>
      oldDelegate.color != color;
}
