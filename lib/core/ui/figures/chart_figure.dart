import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// A compact chart drawn only from values supplied by lesson content.
class ChartFigure extends StatelessWidget {
  const ChartFigure({
    required this.type,
    required this.labels,
    required this.values,
    super.key,
  });

  static const kind = 'chart';
  static const _types = {'bar', 'line', 'number-line'};

  final String type;
  final List<String> labels;
  final List<double> values;

  static ChartFigure? fromSpec(Map<String, Object?> spec) {
    final type = spec['type'];
    final rawLabels = spec['labels'];
    final rawValues = spec['values'];
    if (type is! String || !_types.contains(type)) return null;
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
      if (label is! String || label.trim().isEmpty || label.length > 24) {
        return null;
      }
      if (value is! num || !value.isFinite) return null;
      labels.add(label);
      values.add(value.toDouble());
    }
    return ChartFigure(type: type, labels: labels, values: values);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: 'A $type chart with ${labels.length} labeled values.',
      child: SizedBox(
        height: 210,
        child: CustomPaint(
          size: Size.infinite,
          painter: _ChartPainter(
            type: type,
            labels: labels,
            values: values,
            ink: colors.ink,
            faint: colors.ruleFaint,
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
    required this.labelStyle,
  });

  final String type;
  final List<String> labels;
  final List<double> values;
  final Color ink;
  final Color faint;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(34, 12, size.width - 12, size.height - 34);
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

    final minimum = math.min<double>(0, values.reduce(math.min));
    final maximum = math.max<double>(0, values.reduce(math.max));
    final span = maximum == minimum ? 1.0 : maximum - minimum;
    double yFor(double value) =>
        plot.bottom - (value - minimum) / span * plot.height;
    final slot = plot.width / values.length;

    if (type == 'bar') {
      for (var i = 0; i < values.length; i++) {
        final x = plot.left + slot * (i + 0.18);
        final y = yFor(values[i]);
        canvas.drawRect(
          Rect.fromLTRB(x, y, x + slot * 0.64, yFor(minimum)),
          stroke,
        );
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
      )..layout(maxWidth: slot);
      painter.paint(
        canvas,
        Offset(
          plot.left + slot * (i + 0.5) - painter.width / 2,
          plot.bottom + 7,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) =>
      oldDelegate.type != type ||
      !listEquals(oldDelegate.labels, labels) ||
      !listEquals(oldDelegate.values, values) ||
      oldDelegate.ink != ink ||
      oldDelegate.faint != faint;
}
