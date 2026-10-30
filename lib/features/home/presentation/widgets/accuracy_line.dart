import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

class AccuracyLinePainter extends CustomPainter {
  AccuracyLinePainter({
    required this.series,
    required this.lineColor,
    required this.gridColor,
    this.web = false,
    this.areaColor,
  });

  final List<({DateTime weekStart, double accuracy})> series;
  final Color lineColor;
  final Color gridColor;
  final bool web;
  final Color? areaColor;

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

    final gridLines =
        web ? [10 / 170, 60 / 170, 110 / 170] : [0.0, .25, .5, .75, 1.0];
    for (final fraction in gridLines) {
      final y = size.height * fraction;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw accuracy line (board at 1.5px)
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = web ? 2.5 : 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inset = web ? size.width / 60 : 0.0;
    final path = Path();
    for (var i = 0; i < series.length; i++) {
      final x = inset + (i / (series.length - 1)) * (size.width - 2 * inset);
      // Clamp accuracy between 0 and 100
      final acc = series[i].accuracy.clamp(0.0, 100.0);
      final y = size.height - (acc / 100.0) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (web && areaColor != null) {
      final area = Path.from(path)
        ..lineTo(size.width - inset, size.height)
        ..lineTo(inset, size.height)
        ..close();
      canvas.drawPath(area, Paint()..color = areaColor!.withValues(alpha: .6));
    }
    canvas.drawPath(path, linePaint);
    if (web) {
      final lastY =
          size.height * (1 - series.last.accuracy.clamp(0, 100) / 100);
      canvas.drawCircle(
        Offset(size.width - inset, lastY),
        6,
        Paint()..color = lineColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AccuracyLinePainter oldDelegate) {
    return oldDelegate.web != web ||
        oldDelegate.areaColor != areaColor ||
        oldDelegate.series != series ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class AccuracyLine extends StatelessWidget {
  const AccuracyLine({required this.series, this.web = false, super.key});
  final bool web;

  final List<({DateTime weekStart, double accuracy})> series;

  @override
  Widget build(BuildContext context) {
    if (series.length < 2) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    final summary = _semanticSummary(series);

    return Semantics(
      container: true,
      label: summary,
      child: ExcludeSemantics(
        child: SizedBox(
          height: web ? 170 : 120,
          width: double.infinity,
          child: CustomPaint(
            painter: AccuracyLinePainter(
              series: series,
              lineColor: web ? context.webTokens.colors.accent : colors.label,
              gridColor: web ? context.webTokens.colors.separator : colors.fill,
              web: web,
              areaColor: web ? context.webTokens.colors.accentTint : null,
            ),
          ),
        ),
      ),
    );
  }

  String _semanticSummary(
    List<({DateTime weekStart, double accuracy})> points,
  ) {
    int percent(double value) => value.clamp(0, 100).round();

    final first = percent(points.first.accuracy);
    final latest = percent(points.last.accuracy);
    final lowest = points.map((point) => percent(point.accuracy)).reduce(
          (value, next) => value < next ? value : next,
        );
    final highest = points.map((point) => percent(point.accuracy)).reduce(
          (value, next) => value > next ? value : next,
        );
    final difference = latest - first;
    final trend = switch (difference) {
      > 0 => 'Up $difference percentage points overall',
      < 0 => 'Down ${difference.abs()} percentage points overall',
      _ => 'No overall change',
    };

    return 'Accuracy history. $trend, from $first percent to $latest percent. '
        'Lowest $lowest percent. Highest $highest percent. '
        '${points.length} weekly results.';
  }
}
