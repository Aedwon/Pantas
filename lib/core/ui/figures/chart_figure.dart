import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/data_table.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

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

  /// The plot's inset from the left and from the right (`_ChartPainter`).
  static const double _plotLeft = PantasSpace.s40;
  static const double _plotRight = PantasSpace.s16;

  bool get _hasColumns =>
      (type == 'bar' || type == 'line') &&
      !(compareZero ?? false) &&
      labels.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scaler = MediaQuery.textScalerOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        // A column is at least `size-chart-col` (2.75rem) wide at the scaled
        // text. When the plot is narrower than that, the chart keeps only
        // the most recent points that fit, and a visible "Show Table" button
        // opens every value (D190 item 16).
        var keep = labels.length;
        if (_hasColumns && constraints.hasBoundedWidth) {
          final minColumn = scaler.scale(PantasSize.chartCol);
          final room = constraints.maxWidth - _plotLeft - _plotRight;
          keep = math.max(1, math.min(labels.length, room ~/ minColumn));
        }
        final clipped = keep < labels.length;
        final shownLabels =
            clipped ? labels.sublist(labels.length - keep) : labels;
        final shownValues =
            clipped ? values.sublist(values.length - keep) : values;
        final chart = Semantics(
          label: 'A $type chart.',
          child: SizedBox(
            height: PantasSize.chartH,
            child: CustomPaint(
              size: Size.infinite,
              painter: _ChartPainter(
                type: type,
                labels: shownLabels,
                values: shownValues,
                yAxis: yAxis,
                yMin: yMin,
                compareZero: compareZero,
                plots: plots,
                trend: trend,
                xLabel: xLabel,
                yLabel: yLabel,
                points: points,
                ink: colors.textPrimary,
                faint: colors.divider,
                background: colors.bgPage,
                accent: colors.accent,
                card: colors.surfaceCard,
                ramp: [
                  colors.chart1,
                  colors.chart2,
                  colors.chart3,
                  colors.chart4,
                  colors.chart5,
                ],
                scaler: scaler,
                labelStyle: PantasType.webCaption.copyWith(
                  color: colors.textSecondary,
                ),
                valueStyle: PantasType.webTag.copyWith(
                  color: colors.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                latestStyle: PantasType.webCaption.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
        if (!clipped) return chart;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            chart,
            const SizedBox(height: PantasSpace.s8),
            _ClippedNote(
              shown: keep,
              labels: labels,
              values: values,
              columnLabel: yAxis != null && yAxis!['label'] is String
                  ? yAxis!['label']! as String
                  : 'Value',
            ),
          ],
        );
      },
    );
  }
}

/// The note under a chart that hides its oldest columns, with the tertiary
/// "Show Table" button that opens every value.
class _ClippedNote extends StatefulWidget {
  const _ClippedNote({
    required this.shown,
    required this.labels,
    required this.values,
    required this.columnLabel,
  });

  final int shown;
  final List<String> labels;
  final List<double> values;
  final String columnLabel;

  @override
  State<_ClippedNote> createState() => _ClippedNoteState();
}

class _ClippedNoteState extends State<_ClippedNote> {
  bool _open = false;

  static String _text(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = widget.labels.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Showing the last ${widget.shown}. The table has all $total.',
          style: PantasType.webCaption.copyWith(color: colors.textSecondary),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Semantics(
            button: true,
            expanded: _open,
            child: TextButton(
              key: const ValueKey('chart-table-toggle'),
              onPressed: () => setState(() => _open = !_open),
              style: TextButton.styleFrom(
                minimumSize: const Size(
                  PantasSize.targetTouch,
                  PantasSize.targetTouch,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: colors.textSecondary,
                textStyle: PantasType.webLabel,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(PantasRadius.sm),
                ),
              ),
              child: Text(_open ? 'Hide Table' : 'Show Table'),
            ),
          ),
        ),
        if (_open)
          PantasDataTable(
            key: const ValueKey('chart-table'),
            columns: [
              const PantasTableColumn('Label'),
              PantasTableColumn(widget.columnLabel, numeric: true),
            ],
            rows: [
              for (var i = 0; i < total; i++)
                [widget.labels[i], _text(widget.values[i])],
            ],
          ),
      ],
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
    required this.valueStyle,
    required this.latestStyle,
    required this.accent,
    required this.card,
    required this.ramp,
    required this.scaler,
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
  final TextStyle valueStyle;
  final TextStyle latestStyle;
  final Color accent;
  final Color card;
  final List<Color> ramp;
  final TextScaler scaler;

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

    // The labels under the plot are text at the scaled size, never painted at
    // a fixed one: the bottom margin follows the scaled caption line.
    final labelHeight = scaler.scale(labelStyle.fontSize!) * labelStyle.height!;
    final plot = Rect.fromLTRB(
      ChartFigure._plotLeft,
      PantasSpace.s16 + valueStyle.fontSize!,
      size.width - ChartFigure._plotRight,
      size.height - PantasSpace.s8 * 2 - labelHeight,
    );
    final gridline = Paint()
      ..color = faint
      ..style = PaintingStyle.stroke
      ..strokeWidth = PantasBorder.ring;

    // Gridlines every 25%, plus the top and the baseline (`divider`).
    for (var i = 0; i <= 4; i++) {
      final y = plot.top + plot.height * i / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridline);
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
      // Bars: `accent`, up to 28 wide (60% of the column), radius 5 at the
      // top, at least 5 high so a low value shows.
      final barWidth = math.min(slot * .6, PantasSpace.s28);
      final fill = Paint()..color = accent;
      for (var i = 0; i < values.length; i++) {
        final x = plot.left + slot * (i + .5) - barWidth / 2;
        final base = yFor(minimum);
        final top = math.min(yFor(values[i]), base - PantasSize.accuracyBar);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTRB(x, top, x + barWidth, base),
            topLeft: const Radius.circular(PantasRadius.xs),
            topRight: const Radius.circular(PantasRadius.xs),
          ),
          fill,
        );
        final valText = values[i] == values[i].roundToDouble()
            ? values[i].toInt().toString()
            : values[i].toString();
        _drawCentered(
          canvas,
          valText,
          valueStyle,
          Offset(plot.left + slot * (i + .5), top - PantasSpace.s8),
          slot,
          above: true,
        );
      }
    } else {
      // Line: a 2 px `accent` segment between points, and 8 px `accent`
      // discs with a 2 px `surface-card` edge above it.
      final line = Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = PantasBorder.ringSelected
        ..strokeCap = StrokeCap.round;
      final points = [
        for (var i = 0; i < values.length; i++)
          Offset(plot.left + slot * (i + .5), yFor(values[i])),
      ];
      for (var i = 0; i + 1 < points.length; i++) {
        canvas.drawLine(points[i], points[i + 1], line);
      }
      for (var i = 0; i < points.length; i++) {
        canvas
          ..drawCircle(
            points[i],
            PantasSpace.s4 + PantasBorder.ringSelected,
            Paint()..color = card,
          )
          ..drawCircle(points[i], PantasSpace.s4, Paint()..color = accent);
        final valText = values[i] == values[i].roundToDouble()
            ? values[i].toInt().toString()
            : values[i].toString();
        _drawCentered(
          canvas,
          valText,
          valueStyle,
          points[i] - const Offset(0, PantasSpace.s8 + PantasSpace.s4),
          slot,
          above: true,
        );
      }
    }

    for (var i = 0; i < labels.length; i++) {
      _drawCentered(
        canvas,
        labels[i],
        i == labels.length - 1 ? latestStyle : labelStyle,
        Offset(plot.left + slot * (i + .5), plot.bottom + PantasSpace.s8),
        slot + PantasSpace.s8,
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

    final total = values.fold<double>(0, (sum, val) => sum + val);
    var startAngle = -math.pi / 2;
    // Slices take the five chart steps in order; the outline and the legend
    // names carry the meaning, so hue is never the only cue.
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / (total == 0 ? 1 : total)) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        Paint()..color = ramp[i % ramp.length],
      );
      startAngle += sweep;
    }
    canvas.drawCircle(center, radius, stroke);
    startAngle = -math.pi / 2;

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
      canvas
        ..drawRect(
          Rect.fromLTWH(legendLeft, y, 10, 10),
          Paint()..color = ramp[i % ramp.length],
        )
        ..drawRect(Rect.fromLTWH(legendLeft, y, 10, 10), stroke);
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

  /// Draws [text] centered on [anchor].dx: below [anchor].dy, or with its
  /// bottom edge on it when [above].
  void _drawCentered(
    Canvas canvas,
    String text,
    TextStyle style,
    Offset anchor,
    double maxWidth, {
    bool above = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout(maxWidth: maxWidth);
    painter
      ..paint(
        canvas,
        Offset(
          anchor.dx - painter.width / 2,
          above ? anchor.dy - painter.height : anchor.dy,
        ),
      )
      ..dispose();
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
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
      oldDelegate.accent != accent ||
      oldDelegate.card != card ||
      !listEquals(oldDelegate.ramp, ramp) ||
      oldDelegate.scaler != scaler ||
      oldDelegate.labelStyle != labelStyle ||
      oldDelegate.faint != faint ||
      oldDelegate.background != background;
}
