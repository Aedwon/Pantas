import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A compact chart drawn only from values supplied by lesson content.
class ChartFigure extends StatelessWidget {
  const ChartFigure({
    required this.type,
    this.labels = const [],
    this.values = const [],
    this.yAxis,
    this.yMin,
    this.compareZero,
    this.plots,
    this.trend,
    this.xLabel,
    this.yLabel,
    this.points = const [],
    super.key,
  });

  static const kind = 'chart';
  static const _types = {'bar', 'line', 'number-line', 'pie', 'scatter'};

  final String type;
  final List<String> labels;
  final List<double> values;
  final Map<String, Object?>? yAxis;
  final double? yMin;
  final bool? compareZero;
  final List<String>? plots;
  final String? trend;
  final String? xLabel;
  final String? yLabel;
  final List<Offset> points;

  static ChartFigure? fromSpec(Map<String, Object?> spec) {
    final type = spec['type'];
    if (type is! String || !_types.contains(type)) return null;

    if (type == 'scatter') {
      final rawPlots = spec['plots'];
      List<String>? plots;
      if (rawPlots != null) {
        if (rawPlots is! List || rawPlots.isEmpty) return null;
        plots = <String>[];
        for (final p in rawPlots) {
          if (p is! String ||
              (p != 'upward' &&
                  p != 'downward' &&
                  p != 'none' &&
                  p != 'random')) {
            return null;
          }
          plots.add(p);
        }
      }
      final trend = spec['trend'];
      if (trend != null &&
          (trend is! String ||
              (trend != 'upward' &&
                  trend != 'downward' &&
                  trend != 'none' &&
                  trend != 'random'))) {
        return null;
      }
      final xLabel = spec['xLabel'];
      if (xLabel != null && (xLabel is! String || xLabel.trim().isEmpty)) {
        return null;
      }
      final yLabel = spec['yLabel'];
      if (yLabel != null && (yLabel is! String || yLabel.trim().isEmpty)) {
        return null;
      }

      final rawPoints = spec['points'];
      final points = <Offset>[];
      if (rawPoints != null) {
        if (rawPoints is! List) return null;
        for (final pt in rawPoints) {
          if (pt is! List || pt.length != 2) return null;
          final x = pt[0];
          final y = pt[1];
          if (x is! num || y is! num || !x.isFinite || !y.isFinite) return null;
          points.add(Offset(x.toDouble(), y.toDouble()));
        }
      }

      if (plots == null) {
        if (trend == null ||
            xLabel == null ||
            yLabel == null && points.isEmpty) {
          return null;
        }
      }

      return ChartFigure(
        type: type,
        plots: plots,
        trend: trend as String?,
        xLabel: xLabel as String?,
        yLabel: yLabel as String?,
        points: points,
      );
    }

    final rawLabels = spec['labels'];
    final rawValues = spec['values'];
    if (rawLabels is! List || rawValues is! List) return null;
    if (rawLabels.isEmpty ||
        rawLabels.length > 12 ||
        rawLabels.length != rawValues.length) {
      return null;
    }

    final labels = <String>[];
    final values = <double>[];
    for (var i = 0; i < rawLabels.length; i++) {
      final label = rawLabels[i];
      final value = rawValues[i];
      if (label is! String || label.trim().isEmpty || label.length > 32) {
        return null;
      }
      if (value is! num || !value.isFinite) return null;
      if (type == 'pie' && value <= 0) return null;
      labels.add(label);
      values.add(value.toDouble());
    }

    final rawYAxis = spec['yAxis'];
    Map<String, Object?>? yAxis;
    if (rawYAxis != null) {
      if (rawYAxis is! Map) return null;
      final yLabel = rawYAxis['label'];
      if (yLabel != null && (yLabel is! String || yLabel.trim().isEmpty)) {
        return null;
      }
      final yAxisMin = rawYAxis['min'];
      if (yAxisMin != null && (yAxisMin is! num || !yAxisMin.isFinite)) {
        return null;
      }
      yAxis = rawYAxis.cast<String, Object?>();
    }

    final rawYMin = spec['yMin'];
    final double? yMin;
    if (rawYMin != null) {
      if (rawYMin is! num || !rawYMin.isFinite) return null;
      yMin = rawYMin.toDouble();
    } else {
      yMin = null;
    }

    final rawCompareZero = spec['compareZero'];
    if (rawCompareZero != null && rawCompareZero is! bool) return null;
    final compareZero = rawCompareZero as bool?;

    return ChartFigure(
      type: type,
      labels: labels,
      values: values,
      yAxis: yAxis,
      yMin: yMin,
      compareZero: compareZero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A $type chart.',
      child: SizedBox(
        height: 210,
        child: CustomPaint(
          size: Size.infinite,
          painter: _ChartPainter(
            type: type,
            labels: labels,
            values: values,
            yAxis: yAxis,
            yMin: yMin,
            compareZero: compareZero,
            plots: plots,
            trend: trend,
            xLabel: xLabel,
            yLabel: yLabel,
            points: points,
            ink: colors.ink,
            faint: colors.ruleFaint,
            background: colors.background,
            labelStyle: context.textStyles.bodySmall.copyWith(
              color: colors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.type,
    required this.labels,
    required this.values,
    required this.ink,
    required this.faint,
    required this.background,
    required this.labelStyle,
    this.yAxis,
    this.yMin,
    this.compareZero,
    this.plots,
    this.trend,
    this.xLabel,
    this.yLabel,
    this.points = const [],
  });

  final String type;
  final List<String> labels;
  final List<double> values;
  final Map<String, Object?>? yAxis;
  final double? yMin;
  final bool? compareZero;
  final List<String>? plots;
  final String? trend;
  final String? xLabel;
  final String? yLabel;
  final List<Offset> points;

  final Color ink;
  final Color faint;
  final Color background;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    if (type == 'pie') {
      _drawPieChart(canvas, size);
      return;
    }

    if (type == 'scatter') {
      _drawScatterChart(canvas, size);
      return;
    }

    if (compareZero ?? false) {
      _drawTruncatedComparisonBar(canvas, size);
      return;
    }

    final plot = Rect.fromLTRB(40, 16, size.width - 16, size.height - 36);
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas
      ..drawLine(plot.bottomLeft, plot.topLeft, stroke)
      ..drawLine(plot.bottomLeft, plot.bottomRight, stroke);
    for (var i = 1; i < 4; i++) {
      final y = plot.top + plot.height * i / 4;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        faintStroke,
      );
    }

    final minimum = yMin ??
        (values.isNotEmpty
            ? math.min<double>(0, values.reduce(math.min))
            : 0.0);
    final maximum = values.isNotEmpty
        ? math.max<double>(0, values.reduce(math.max))
        : 100.0;
    final span = maximum == minimum ? 1.0 : maximum - minimum;
    double yFor(double value) =>
        plot.bottom - (value - minimum) / span * plot.height;
    final slot = values.isNotEmpty ? plot.width / values.length : plot.width;

    if (type == 'bar') {
      for (var i = 0; i < values.length; i++) {
        final x = plot.left + slot * (i + 0.18);
        final y = yFor(values[i]);
        canvas.drawRect(
          Rect.fromLTRB(x, y, x + slot * 0.64, yFor(minimum)),
          stroke,
        );
        final valText = values[i] == values[i].roundToDouble()
            ? values[i].toInt().toString()
            : values[i].toString();
        _drawText(canvas, valText, Offset(x + slot * 0.1, y - 14));
      }
    } else {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final point = Offset(plot.left + slot * (i + 0.5), yFor(values[i]));
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
        canvas.drawCircle(point, 2.5, stroke);
      }
      canvas.drawPath(path, stroke);
    }

    for (var i = 0; i < labels.length; i++) {
      final painter = TextPainter(
        text: TextSpan(text: labels[i], style: labelStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: slot + 8);
      painter.paint(
        canvas,
        Offset(
          plot.left + slot * (i + 0.5) - painter.width / 2,
          plot.bottom + 8,
        ),
      );
    }

    if (yAxis != null && yAxis!['label'] is String) {
      _drawText(canvas, yAxis!['label']! as String, Offset(plot.left, 2));
    }
  }

  void _drawTruncatedComparisonBar(Canvas canvas, Size size) {
    final leftWidth = size.width * 0.58;
    final leftPlot = Rect.fromLTRB(36, 26, leftWidth, size.height - 34);
    final rightPlot =
        Rect.fromLTRB(leftWidth + 24, 26, size.width - 12, size.height - 34);

    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Left chart (starts at 80)
    _drawText(canvas, 'Starting at 80 (Exaggerated)', Offset(leftPlot.left, 8));
    canvas
      ..drawLine(leftPlot.bottomLeft, leftPlot.topLeft, stroke)
      ..drawLine(leftPlot.bottomLeft, leftPlot.bottomRight, stroke);
    _drawText(canvas, '80', Offset(leftPlot.left - 24, leftPlot.bottom - 6));
    _drawText(canvas, '90', Offset(leftPlot.left - 24, leftPlot.top - 6));

    final slotL = leftPlot.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final h = (values[i] - 80) / 10 * leftPlot.height;
      final x = leftPlot.left + slotL * (i + 0.18);
      final y = leftPlot.bottom - h;
      canvas.drawRect(
        Rect.fromLTRB(x, y, x + slotL * 0.64, leftPlot.bottom),
        stroke,
      );
      _drawText(canvas, '${values[i].toInt()}', Offset(x + 4, y - 14));
      _drawText(canvas, labels[i], Offset(x, leftPlot.bottom + 6));
    }

    // Right chart (starts at 0)
    _drawText(canvas, 'Starting at 0 (Real)', Offset(rightPlot.left, 8));
    canvas
      ..drawLine(rightPlot.bottomLeft, rightPlot.topLeft, stroke)
      ..drawLine(rightPlot.bottomLeft, rightPlot.bottomRight, stroke);
    _drawText(canvas, '0', Offset(rightPlot.left - 18, rightPlot.bottom - 6));
    _drawText(canvas, '100', Offset(rightPlot.left - 24, rightPlot.top - 6));

    final slotR = rightPlot.width / values.length;
    for (var i = 0; i < values.length; i++) {
      final h = values[i] / 100 * rightPlot.height;
      final x = rightPlot.left + slotR * (i + 0.18);
      final y = rightPlot.bottom - h;
      canvas.drawRect(
        Rect.fromLTRB(x, y, x + slotR * 0.64, rightPlot.bottom),
        stroke,
      );
      _drawText(canvas, '${values[i].toInt()}', Offset(x + 2, y - 14));
      _drawText(canvas, labels[i], Offset(x, rightPlot.bottom + 6));
    }
  }

  void _drawPieChart(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.38, size.height / 2);
    final radius = math.min(size.width * 0.28, size.height * 0.4);
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius, stroke);

    final total = values.fold<double>(0, (sum, val) => sum + val);
    var startAngle = -math.pi / 2;

    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / (total == 0 ? 1 : total)) * 2 * math.pi;
      final lineEnd = center +
          Offset(math.cos(startAngle) * radius, math.sin(startAngle) * radius);
      canvas.drawLine(center, lineEnd, stroke);
      startAngle += sweep;
    }

    // Legend on the right
    final legendLeft = size.width * 0.7;
    for (var i = 0; i < labels.length; i++) {
      final y = size.height / 2 - (labels.length * 12) + i * 24;
      canvas.drawRect(Rect.fromLTWH(legendLeft, y, 10, 10), stroke);
      _drawText(canvas, labels[i], Offset(legendLeft + 16, y - 2));
    }
  }

  void _drawScatterChart(Canvas canvas, Size size) {
    if (plots != null) {
      final slotW = size.width / plots!.length;
      final faintStroke = Paint()
        ..color = faint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      for (var i = 0; i < plots!.length; i++) {
        final box =
            Rect.fromLTWH(slotW * i + 8, 20, slotW - 16, size.height - 48);
        canvas.drawRect(box, faintStroke);
        final title = switch (plots![i]) {
          'upward' => 'Positive correlation',
          'downward' => 'Negative correlation',
          _ => 'No correlation',
        };
        _drawText(canvas, title, Offset(box.left + 4, size.height - 20));

        final rng = math.Random(i * 17);
        for (var j = 0; j < 18; j++) {
          final t = j / 18.0;
          final noise = (rng.nextDouble() - 0.5) * 0.3;
          final yRel = switch (plots![i]) {
            'upward' => 1.0 - t + noise,
            'downward' => t + noise,
            _ => rng.nextDouble(),
          };
          final px = box.left + 6 + t * (box.width - 12);
          final py = box.top + 6 + yRel.clamp(0.0, 1.0) * (box.height - 12);
          canvas.drawCircle(Offset(px, py), 2.2, Paint()..color = ink);
        }
      }
      return;
    }

    // Single scatter plot
    final plot = Rect.fromLTRB(44, 20, size.width - 24, size.height - 36);
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final faintStroke = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas
      ..drawLine(plot.bottomLeft, plot.topLeft, stroke)
      ..drawLine(plot.bottomLeft, plot.bottomRight, stroke);

    if (xLabel != null) {
      _drawText(canvas, xLabel!, Offset(plot.center.dx - 40, size.height - 18));
    }
    if (yLabel != null) {
      _drawText(canvas, yLabel!, Offset(plot.left, 4));
    }

    final rng = math.Random(42);
    for (var i = 0; i < 22; i++) {
      final t = i / 22.0;
      final noise = (rng.nextDouble() - 0.5) * 0.25;
      final yRel = (t + noise).clamp(0.05, 0.95);
      final px = plot.left + 10 + t * (plot.width - 20);
      final py = plot.top + 10 + yRel * (plot.height - 20);
      canvas.drawCircle(Offset(px, py), 2.5, Paint()..color = ink);
    }
    // Dashed trend line
    canvas.drawLine(
      Offset(plot.left + 10, plot.top + 10),
      Offset(plot.right - 10, plot.bottom - 10),
      faintStroke,
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )
      ..layout()
      ..paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) =>
      oldDelegate.type != type ||
      !listEquals(oldDelegate.labels, labels) ||
      !listEquals(oldDelegate.values, values) ||
      !mapEquals(oldDelegate.yAxis, yAxis) ||
      oldDelegate.yMin != yMin ||
      oldDelegate.compareZero != compareZero ||
      !listEquals(oldDelegate.plots, plots) ||
      oldDelegate.trend != trend ||
      oldDelegate.xLabel != xLabel ||
      oldDelegate.yLabel != yLabel ||
      !listEquals(oldDelegate.points, points) ||
      oldDelegate.ink != ink ||
      oldDelegate.faint != faint ||
      oldDelegate.background != background;
}
