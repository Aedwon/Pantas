import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class AccuracyLinePainter extends CustomPainter {
  AccuracyLinePainter({
    required this.series,
    required this.lineColor,
    required this.gridColor,
  });

  final List<({DateTime weekStart, double accuracy})> series;
  final Color lineColor;
  final Color gridColor;

  double get minY => 0;
  double get maxY => 100;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.length < 2) return;

    // Draw horizontal gridlines (ruleFaint at 1px)
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridLineCount = 4;
    for (var i = 0; i <= gridLineCount; i++) {
      final y = size.height * (i / gridLineCount);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw accuracy line (board at 1.5px)
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (var i = 0; i < series.length; i++) {
      final x = (i / (series.length - 1)) * size.width;
      // Clamp accuracy between 0 and 100
      final acc = series[i].accuracy.clamp(0.0, 100.0);
      final y = size.height - (acc / 100.0) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant AccuracyLinePainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class AccuracyLine extends StatelessWidget {
  const AccuracyLine({required this.series, super.key});

  final List<({DateTime weekStart, double accuracy})> series;

  @override
  Widget build(BuildContext context) {
    if (series.length < 2) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return SizedBox(
      height: 120,
      width: double.infinity,
      child: CustomPaint(
        painter: AccuracyLinePainter(
          series: series,
          lineColor: colors.board,
          gridColor: colors.ruleFaint,
        ),
      ),
    );
  }
}
