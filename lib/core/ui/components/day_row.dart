import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// The seven study days in one row (SelectableTile README, D190).
///
/// Each day is at least 44 wide, and wide enough for its weekday at the
/// current text size, so "Sun" never splits at 200 percent. The gap shrinks
/// from 10 toward 4 before the row gives up. A row too narrow for that
/// scrolls sideways, and the day just turned on is scrolled into view.
///
/// [order] is the days in row order (7 is Sunday). [itemBuilder] draws one day
/// at its column; with [fill] the days share the free width (tiles), and
/// without it they keep [itemWidth] and spread to the edges (circles).
class DayRow extends StatefulWidget {
  const DayRow({
    required this.order,
    required this.selected,
    required this.itemBuilder,
    this.itemWidth = PantasSize.targetTouch,
    this.fill = true,
    super.key,
  });

  final List<int> order;
  final Set<int> selected;
  final Widget Function(int day) itemBuilder;
  final double itemWidth;
  final bool fill;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  /// The width a day tile needs: 44, or the widest weekday label at this text
  /// size plus the tile's side padding, whichever is more.
  static double tileWidth(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    var widest = 0.0;
    for (final label in _weekdays) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: PantasType.webTag),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    final needed = widest + 2 * PantasSpace.s4 + PantasSpace.s2;
    return needed > PantasSize.targetTouch ? needed : PantasSize.targetTouch;
  }

  @override
  State<DayRow> createState() => _DayRowState();
}

class _DayRowState extends State<DayRow> {
  final _keys = {for (var day = 1; day <= 7; day++) day: GlobalKey()};
  Set<int> _seen = {};
  bool _scrolls = false;

  @override
  void initState() {
    super.initState();
    _seen = {...widget.selected};
    _reveal(initial: true);
  }

  @override
  void didUpdateWidget(DayRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reveal();
  }

  /// The day just turned on, else the first selected day in row order.
  void _reveal({bool initial = false}) {
    final now = {...widget.selected};
    final added = now.difference(_seen);
    _seen = now;
    final day = added.isNotEmpty
        ? widget.order.firstWhere(added.contains)
        : initial
            ? widget.order.where(now.contains).firstOrNull
            : null;
    if (day == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _keys[day]!.currentContext;
      if (!mounted || !_scrolls || target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : PantasDurations.short3,
        curve: PantasCurves.scroll,
      );
    });
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          const columns = 7;
          final minRow =
              columns * widget.itemWidth + (columns - 1) * PantasSpace.s4;
          _scrolls = constraints.maxWidth < minRow;
          if (_scrolls) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (i, day) in widget.order.indexed) ...[
                    if (i > 0) const SizedBox(width: PantasSpace.s4),
                    SizedBox(
                      key: _keys[day],
                      width: widget.itemWidth,
                      child: widget.itemBuilder(day),
                    ),
                  ],
                ],
              ),
            );
          }
          final gap = ((constraints.maxWidth - columns * widget.itemWidth) /
                  (columns - 1))
              .clamp(PantasSpace.s4, PantasSpace.s10);
          if (!widget.fill) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final day in widget.order)
                  SizedBox(
                    key: _keys[day],
                    width: widget.itemWidth,
                    child: widget.itemBuilder(day),
                  ),
              ],
            );
          }
          return Row(
            children: [
              for (final (i, day) in widget.order.indexed) ...[
                if (i > 0) SizedBox(width: gap),
                Expanded(
                  key: _keys[day],
                  child: widget.itemBuilder(day),
                ),
              ],
            ],
          );
        },
      );
}
