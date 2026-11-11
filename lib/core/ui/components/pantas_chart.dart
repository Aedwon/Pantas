import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/data_table.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';

/// Bars or a line (design system Chart).
enum PantasChartKind { bar, line }

/// One result of a [PantasChart]: its x label and a value from 0 to 100.
///
/// A null [value] is a result with no data: the chart draws no mark for it and
/// the table reads "No data".
@immutable
class PantasChartPoint {
  const PantasChartPoint({
    required this.label,
    required this.value,
    this.valueText,
  });

  /// The x label (a date, a week).
  final String label;

  /// 0 to 100, or null for no data.
  final double? value;

  /// The printed value. Null prints the value with a percent sign, with one
  /// decimal only where the value has one.
  final String? valueText;

  String? get printed {
    final v = value;
    if (v == null) return null;
    return valueText ?? _percent(v);
  }
}

/// A timed entrance for the latest point of a [PantasChart], driven by the
/// caller's clock (the mock results finale): the last line segment draws in,
/// the point pops, and the latest x label and value label fade in. Every field
/// is the state at one instant, so the caller rebuilds the chart each frame.
/// With no entrance the chart is at rest.
@immutable
class PantasChartEntrance {
  const PantasChartEntrance({
    required this.lineProgress,
    required this.dotScale,
    required this.dotOpacity,
    required this.labelOpacity,
    required this.valueOpacity,
    required this.valueOffset,
  });

  /// 0 to 1: how much of the last segment is drawn.
  final double lineProgress;

  /// Scale and opacity of the latest point.
  final double dotScale;
  final double dotOpacity;

  /// Opacity of the latest x label.
  final double labelOpacity;

  /// Opacity and vertical shift of the latest value label.
  final double valueOpacity;
  final double valueOffset;
}

String _percent(double v) =>
    v == v.roundToDouble() ? '${v.round()}%' : '${v.toStringAsFixed(1)}%';

/// Shows results over time as bars or a line (design system Chart).
///
/// A head (title and legend), a one-line [summary], the plot, and a table
/// equivalent. The plot is [PantasSize.chartH] high at every width. The y axis
/// runs 0 to 100 every 25 with gridlines. Every label is a real [Text], so it
/// follows the text scale; the painter draws only gridlines, bars, line
/// segments and points. The plot never scrolls: when the columns do not fit at
/// [PantasSize.chartCol] each, it keeps the most recent points that fit, says
/// so, and a "Show Table" button opens the table with every value.
///
/// The consumer gives the points, the summary sentence and the table headers.
class PantasChart extends StatefulWidget {
  const PantasChart({
    required this.title,
    required this.summary,
    required this.points,
    this.kind = PantasChartKind.bar,
    this.secondary,
    this.primaryName,
    this.secondaryName,
    this.emptyText = 'No results yet.',
    this.unit = 'results',
    this.labelHeader = 'Date',
    this.valueHeader = 'Score',
    this.secondaryHeader,
    this.entrance,
    super.key,
  }) : assert(
          secondary == null || secondary.length == points.length,
          'The second series has one value per point.',
        );

  final String title;

  /// The one-line summary under the head ("Your last 6 mocks ranged...").
  final String summary;
  final List<PantasChartPoint> points;
  final PantasChartKind kind;

  /// A second series, one value (0 to 100, or null) per point. It is drawn
  /// dashed in `text-secondary` with square markers, never in a second hue.
  final List<double?>? secondary;

  /// Legend names. They show only when there is a second series.
  final String? primaryName;
  final String? secondaryName;

  /// The text in the plot when there are no points.
  final String emptyText;

  /// The plural noun in the clipped note ("mocks", "weeks").
  final String unit;
  final String labelHeader;
  final String valueHeader;
  final String? secondaryHeader;

  /// A timed entrance for the latest point; null draws the chart at rest.
  final PantasChartEntrance? entrance;

  /// How many of [total] points fit in [plotWidth] at the minimum column
  /// width, which grows with the text scale.
  @visibleForTesting
  static int fit(double plotWidth, int total, TextScaler scaler) {
    final column = scaler.scale(PantasSize.chartCol);
    return math.min(total, math.max(1, (plotWidth / column).floor()));
  }

  @override
  State<PantasChart> createState() => _PantasChartState();
}

class _PantasChartState extends State<PantasChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _grow = AnimationController(
    vsync: this,
    duration: PantasDurations.long2,
  );
  bool _open = false;
  bool _started = false;

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _grow.value = 1;
    } else {
      _grow.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final w = widget;
    final hasSecond = w.secondary != null && w.secondaryName != null;
    final head = Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              w.title,
              style: PantasType.webH3.copyWith(color: c.textPrimary),
            ),
          ),
        ),
        if (hasSecond && w.primaryName != null) ...[
          const SizedBox(width: PantasSpace.s12),
          Flexible(child: _Key(name: w.primaryName!, second: false, w: w)),
          const SizedBox(width: PantasSpace.s12),
          Flexible(child: _Key(name: w.secondaryName!, second: true, w: w)),
        ],
      ],
    );
    return LayoutBuilder(
      builder: (context, box) {
        final scaler = MediaQuery.textScalerOf(context);
        final axisWidth = _axisWidth(context);
        final plotWidth = math.max<double>(0, box.maxWidth - axisWidth);
        final total = w.points.length;
        final shown =
            total == 0 ? 0 : PantasChart.fit(plotWidth, total, scaler);
        final hidden = total - shown;
        final visible = w.points.sublist(total - shown);
        final visibleSecond = w.secondary?.sublist(total - shown);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            head,
            const SizedBox(height: PantasSpace.s4),
            Text(
              w.summary,
              style: PantasType.webSub.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: PantasSpace.s16),
            _Plot(
              points: visible,
              second: visibleSecond,
              kind: w.kind,
              emptyText: w.emptyText,
              axisWidth: axisWidth,
              grow: _grow,
              entrance: w.entrance,
            ),
            if (hidden > 0) ...[
              const SizedBox(height: PantasSpace.s12),
              Text(
                'Showing the last $shown ${w.unit}. The table has all $total.',
                style: PantasType.webSub.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: PantasSpace.s4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Semantics(
                  expanded: _open,
                  child: WebButton(
                    label: _open ? 'Hide Table' : 'Show Table',
                    kind: PantasButtonKind.tertiary,
                    size: PantasButtonSize.sm,
                    onPressed: () => setState(() => _open = !_open),
                  ),
                ),
              ),
            ],
            if (total > 0) _table(context, open: _open && hidden > 0),
          ],
        );
      },
    );
  }

  /// The table equivalent: every value, in a data table. While it is closed a
  /// screen reader still reaches every value as one labeled region.
  Widget _table(BuildContext context, {required bool open}) {
    final w = widget;
    final second = w.secondary;
    final rows = <List<String?>>[
      for (var i = 0; i < w.points.length; i++)
        [
          w.points[i].label,
          w.points[i].printed,
          if (second != null) second[i] == null ? null : _percent(second[i]!),
        ],
    ];
    if (open) {
      return Padding(
        padding: const EdgeInsets.only(top: PantasSpace.s12),
        child: PantasDataTable(
          caption: w.title,
          columns: [
            PantasTableColumn(w.labelHeader),
            PantasTableColumn(w.valueHeader, numeric: true),
            if (second != null)
              PantasTableColumn(w.secondaryHeader ?? 'Other', numeric: true),
          ],
          rows: rows,
        ),
      );
    }
    final spoken = [
      for (final row in rows)
        '${row[0]}: ${row.skip(1).map((v) => v ?? 'No data').join(', ')}',
    ].join('. ');
    return Semantics(
      container: true,
      label: '${w.title} table. $spoken',
      child: const SizedBox.shrink(),
    );
  }

  double _axisWidth(BuildContext context) {
    final painter = TextPainter(
      text: const TextSpan(text: '100%', style: PantasType.webCaption),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width + PantasSpace.s8;
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.name, required this.second, required this.w});
  final String name;
  final bool second;
  final PantasChart w;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final mark = SizedBox(
      width: PantasSpace.s16,
      height: PantasSpace.s8,
      child: CustomPaint(
        painter: _KeyPainter(
          second: second,
          bar: w.kind == PantasChartKind.bar,
          color: second ? c.textSecondary : c.accent,
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: mark),
        const SizedBox(width: PantasSpace.s6),
        Flexible(
          child: Text(
            name,
            style: PantasType.webCaption.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _KeyPainter extends CustomPainter {
  _KeyPainter({required this.second, required this.bar, required this.color});
  final bool second;
  final bool bar;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    if (second) {
      canvas.drawRect(
        Rect.fromLTWH(
          size.width / 2 - size.height / 2,
          0,
          size.height,
          size.height,
        ),
        paint,
      );
    } else if (bar) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width / 2 - size.height / 2,
            0,
            size.height,
            size.height,
          ),
          const Radius.circular(PantasRadius.xs / 2),
        ),
        paint,
      );
    } else {
      canvas.drawCircle(size.center(Offset.zero), size.height / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_KeyPainter old) =>
      old.second != second || old.bar != bar || old.color != color;
}

/// The plot: y axis, gridlines, marks, value labels and x labels.
class _Plot extends StatelessWidget {
  const _Plot({
    required this.points,
    required this.second,
    required this.kind,
    required this.emptyText,
    required this.axisWidth,
    required this.grow,
    required this.entrance,
  });
  final PantasChartEntrance? entrance;
  final List<PantasChartPoint> points;
  final List<double?>? second;
  final PantasChartKind kind;
  final String emptyText;
  final double axisWidth;
  final Animation<double> grow;

  static const _steps = [100, 75, 50, 25, 0];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final scaler = MediaQuery.textScalerOf(context);
    final valueLine =
        scaler.scale(PantasType.webTag.fontSize!) * PantasType.webTag.height!;
    final captionLine = scaler.scale(PantasType.webCaption.fontSize!) *
        PantasType.webCaption.height!;
    // Room above the plot, so a label over a value of 100 stays in the card.
    final headroom = valueLine + PantasSpace.s8;
    const plotHeight = PantasSize.chartH;
    final axis = TextStyle(
      fontFeatures: const [FontFeature.tabularFigures()],
      color: c.textSecondary,
    );
    final yLabels = SizedBox(
      width: axisWidth,
      height: headroom + plotHeight + captionLine + PantasSpace.s8,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final step in _steps)
            Positioned(
              left: 0,
              right: PantasSpace.s8,
              top: headroom + plotHeight * (1 - step / 100) - captionLine / 2,
              child: Text(
                '$step%',
                textAlign: TextAlign.end,
                maxLines: 1,
                style: PantasType.webCaption.merge(axis),
              ),
            ),
        ],
      ),
    );
    final body = LayoutBuilder(
      builder: (context, box) {
        final n = points.length;
        final colW = n == 0 ? box.maxWidth : box.maxWidth / n;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: headroom + plotHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: grow,
                      builder: (context, _) => CustomPaint(
                        painter: _PlotPainter(
                          values: [for (final p in points) p.value],
                          second: second,
                          kind: kind,
                          headroom: headroom,
                          progress: PantasCurves.house.transform(grow.value),
                          accent: c.accent,
                          muted: c.textSecondary,
                          grid: c.divider,
                          card: c.surfaceCard,
                          entrance: entrance,
                        ),
                      ),
                    ),
                  ),
                  if (n == 0)
                    Positioned.fill(
                      top: headroom,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: PantasSpace.s16,
                          ),
                          child: Text(
                            emptyText,
                            textAlign: TextAlign.center,
                            style: PantasType.webSub
                                .copyWith(color: c.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  for (var i = 0; i < n; i++)
                    if (points[i].printed != null)
                      Positioned(
                        left: colW * i,
                        width: colW,
                        bottom: plotHeight * (points[i].value! / 100) +
                            (kind == PantasChartKind.line
                                ? PantasSpace.s4 + PantasBorder.ringSelected
                                : 0) +
                            PantasSpace.s8,
                        child: _Entering(
                          opacity: i == n - 1 ? entrance?.valueOpacity : null,
                          dy: i == n - 1 ? entrance?.valueOffset : null,
                          child: Text(
                            points[i].printed!,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            style: PantasType.webTag.copyWith(
                              color: c.textPrimary,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: PantasSpace.s8),
            Row(
              children: [
                for (var i = 0; i < n; i++)
                  SizedBox(
                    width: colW,
                    child: _Entering(
                      opacity: i == n - 1 ? entrance?.labelOpacity : null,
                      child: Text(
                        points[i].label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: PantasType.webCaption.copyWith(
                          // The latest result is 600 in the primary ink.
                          fontWeight: i == n - 1 ? FontWeight.w600 : null,
                          color: i == n - 1 ? c.textPrimary : c.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
    return ExcludeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [yLabels, Expanded(child: body)],
      ),
    );
  }
}

/// Fades and shifts a label during an entrance; at rest it is the label.
class _Entering extends StatelessWidget {
  const _Entering({required this.child, this.opacity, this.dy});
  final Widget child;
  final double? opacity;
  final double? dy;

  @override
  Widget build(BuildContext context) {
    if (opacity == null && dy == null) return child;
    return Opacity(
      opacity: (opacity ?? 1).clamp(0, 1),
      child: Transform.translate(offset: Offset(0, dy ?? 0), child: child),
    );
  }
}

class _PlotPainter extends CustomPainter {
  _PlotPainter({
    required this.values,
    required this.second,
    required this.kind,
    required this.headroom,
    required this.progress,
    required this.accent,
    required this.muted,
    required this.grid,
    required this.card,
    this.entrance,
  });
  final PantasChartEntrance? entrance;
  final List<double?> values;
  final List<double?>? second;
  final PantasChartKind kind;
  final double headroom;
  final double progress;
  final Color accent;
  final Color muted;
  final Color grid;
  final Color card;

  @override
  void paint(Canvas canvas, Size size) {
    final plotHeight = size.height - headroom;
    double y(double v) => headroom + plotHeight * (1 - v / 100);
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = PantasBorder.ring;
    // Gridlines every 25%, with the top and the baseline.
    for (var step = 0; step <= 100; step += 25) {
      canvas.drawLine(
        Offset(0, y(step.toDouble())),
        Offset(size.width, y(step.toDouble())),
        gridPaint,
      );
    }
    final n = values.length;
    if (n == 0) return;
    final colW = size.width / n;
    double cx(int i) => colW * i + colW / 2;

    if (kind == PantasChartKind.bar) {
      final barW = math.min(PantasSpace.s28, colW * .6);
      final paint = Paint()..color = accent;
      for (var i = 0; i < n; i++) {
        final v = values[i];
        if (v == null) continue;
        final h = math.max(
              PantasSize.accuracyBar,
              plotHeight * v.clamp(0, 100) / 100,
            ) *
            progress;
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(cx(i) - barW / 2, y(0) - h, barW, h),
            topLeft: const Radius.circular(PantasRadius.xs),
            topRight: const Radius.circular(PantasRadius.xs),
          ),
          paint,
        );
      }
    } else {
      _series(
        canvas,
        values,
        y,
        cx,
        accent,
        dashed: false,
        entrance: entrance,
      );
    }
    final other = second;
    if (other != null) {
      _series(canvas, other, y, cx, muted, dashed: true);
    }
  }

  void _series(
    Canvas canvas,
    List<double?> data,
    double Function(double) y,
    double Function(int) cx,
    Color color, {
    required bool dashed,
    PantasChartEntrance? entrance,
  }) {
    final line = Paint()
      ..color = color
      ..strokeWidth = PantasBorder.ringSelected
      ..style = PaintingStyle.stroke;
    // Each column draws its own segment to the next column's point.
    for (var i = 0; i < data.length - 1; i++) {
      final a = data[i];
      final b = data[i + 1];
      if (a == null || b == null) continue;
      final from = Offset(cx(i), y(a));
      final to = Offset(cx(i + 1), y(b));
      if (!dashed) {
        final entering = entrance != null && i == data.length - 2;
        canvas.drawLine(
          from,
          entering ? Offset.lerp(from, to, entrance.lineProgress)! : to,
          line,
        );
        continue;
      }
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..lineTo(to.dx, to.dy);
      for (final metric in path.computeMetrics()) {
        var at = 0.0;
        while (at < metric.length) {
          canvas.drawPath(
            metric.extractPath(
              at,
              math.min(at + PantasSpace.s4, metric.length),
            ),
            line,
          );
          at += PantasSpace.s4 * 2;
        }
      }
    }
    final dot = Paint()..color = color;
    final edge = Paint()..color = card;
    const radius = PantasSpace.s4;
    for (var i = 0; i < data.length; i++) {
      final v = data[i];
      if (v == null) continue;
      if (!dashed && kind != PantasChartKind.line) continue;
      final at = Offset(cx(i), y(v));
      if (dashed) {
        // Square markers: the second series differs by shape, not hue.
        canvas
          ..drawRect(
            Rect.fromCenter(
              center: at,
              width: radius * 2 + PantasBorder.ringSelected * 2,
              height: radius * 2 + PantasBorder.ringSelected * 2,
            ),
            edge,
          )
          ..drawRect(
            Rect.fromCenter(center: at, width: radius * 2, height: radius * 2),
            dot,
          );
      } else {
        final entering = entrance != null && i == data.length - 1;
        final scale = entering ? entrance.dotScale : 1.0;
        final fade = entering ? entrance.dotOpacity.clamp(0, 1) : 1.0;
        canvas
          ..drawCircle(
            at,
            (radius + PantasBorder.ringSelected) * scale,
            Paint()..color = card.withValues(alpha: fade.toDouble()),
          )
          ..drawCircle(
            at,
            radius * scale,
            Paint()..color = color.withValues(alpha: fade.toDouble()),
          );
      }
    }
  }

  @override
  bool shouldRepaint(_PlotPainter old) =>
      old.values != values ||
      old.second != second ||
      old.kind != kind ||
      old.progress != progress ||
      old.accent != accent ||
      old.muted != muted ||
      old.grid != grid ||
      old.card != card ||
      old.entrance != entrance ||
      old.headroom != headroom;
}
