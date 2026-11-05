import 'package:flutter/material.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

// Pending Aedwon decision, October 10 lead ruling. HP_Free's day-off text.

enum WeekDayState { done, partial, missed, dayOff, today, plain }

class WeekStrip extends StatefulWidget {
  const WeekStrip({
    required this.today,
    required this.states,
    required this.onSelected,
    this.todayFraction = 0,
    this.selectedDate,
    super.key,
  }) : assert(states.length == 7, 'A week must have seven days.');
  final DateTime today;
  final List<WeekDayState> states;
  final ValueChanged<DateTime> onSelected;
  final double todayFraction;
  final DateTime? selectedDate;

  /// How far the last day's visible mark ends before the strip's right edge.
  ///
  /// The last day sits centered in its cell, so there is empty space between
  /// its number (or today's mark) and the strip's edge. A neighbor that wants
  /// to be spaced from what the eye reads as the last day, not from the cell
  /// edge, adds this inset. It follows where the strip starts scrolled, so
  /// when the last cell starts partly out of view the inset shrinks to zero
  /// instead of going negative.
  static double lastDayInset(
    BuildContext context, {
    required double width,
    required DateTime today,
    required List<WeekDayState> states,
    double todayFraction = 0,
  }) {
    final scale = MediaQuery.textScalerOf(context);
    final cell = _cellWidth(scale, width);
    final size = _markSize(scale);
    final lastIsToday = states.last == WeekDayState.today;
    final double visible;
    if (lastIsToday) {
      visible = todayFraction > 0 ? size : size - 6;
    } else {
      final start = PantasDates.weekStart(today);
      final last = DateTime(start.year, start.month, start.day + 6);
      final painter = TextPainter(
        text: TextSpan(
          text: '${last.day}',
          style: _digitStyle(context, today: false),
        ),
        textDirection: TextDirection.ltr,
        textScaler: scale,
      )..layout(maxWidth: size); // The cell lets the number use `size`.
      visible = painter.width;
      painter.dispose();
    }
    final maxScroll = (cell * 7 - width).clamp(0.0, double.infinity);
    final startScroll = (today.weekday % 7 * cell).clamp(0.0, maxScroll);
    final cutOff = cell * 7 - width - startScroll;
    final inset = (cell - visible) / 2 - cutOff;
    return inset < 0 ? 0 : inset;
  }

  static double _cellWidth(TextScaler scale, double maxWidth) =>
      (maxWidth / 7).clamp(scale.scale(10) * 3.5, double.infinity);

  static double _markSize(TextScaler scale) {
    final markSize = scale.scale(15) * 1.35 + 4;
    return markSize > 34 ? markSize : 34.0;
  }

  static TextStyle _digitStyle(
    BuildContext context, {
    required bool today,
    Color? color,
  }) =>
      context.type.body.copyWith(
        fontSize: today ? 14 : 15,
        fontWeight: today ? FontWeight.w700 : FontWeight.w500,
        letterSpacing: 0,
        color: color,
      );

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  ScrollController? _scroll;
  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = PantasDates.weekStart(widget.today);
    final c = context.colors;
    // The board's pale gray vanishes into the dark page, so it would show an
    // off-day as bright as a study day. Dark uses the dimmed gray that the
    // wide web strip uses (6U-6).
    final off = Theme.of(context).brightness == Brightness.dark
        ? c.tertiaryLabel
        : c.inactiveDateLabel;
    final scale = MediaQuery.textScalerOf(context);
    final size = WeekStrip._markSize(scale);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = WeekStrip._cellWidth(scale, constraints.maxWidth);
        _scroll ??= ScrollController(
          initialScrollOffset: (widget.today.weekday % 7) * width,
        );
        return SizedBox(
          // Board: the strip is 59.4 px tall, so the card is 75.4 px.
          height: scale.scale(10) * 1.35 + size + 11.5,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (i) {
                final date = DateTime(start.year, start.month, start.day + i);
                final state = widget.states[i];
                final today = state == WeekDayState.today;
                final dayOff = state == WeekDayState.dayOff;
                final color = dayOff
                    ? off
                    : today
                        ? c.accent
                        : c.secondaryLabel;
                final selected = widget.selectedDate == date;
                final digit = Text(
                  '${date.day}',
                  style: WeekStrip._digitStyle(
                    context,
                    today: today,
                    color: dayOff
                        ? off
                        : today
                            ? (c.onAccent)
                            : c.label,
                  ),
                );
                return SizedBox(
                  width: width,
                  child: Semantics(
                    label: PantasDates.heading(date),
                    selected: selected,
                    child: Material(
                      color: context.colors.transparent,
                      child: InkWell(
                        key: ValueKey('week-day-$i'),
                        onTap: () => widget.onSelected(date),
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          children: [
                            Text(
                              const [
                                'Sun',
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                              ][i],
                              style: context.type.captionStrong.copyWith(
                                fontWeight:
                                    today ? FontWeight.w700 : FontWeight.w600,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox.square(
                              dimension: size,
                              child: today && widget.todayFraction > 0
                                  ? ProgressRing(
                                      size: size,
                                      fraction: widget.todayFraction,
                                      showCheck: false,
                                      child: Container(
                                        width: size - 6,
                                        height: size - 6,
                                        decoration: BoxDecoration(
                                          color: c.accentFill,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: digit,
                                      ),
                                    )
                                  : today
                                      ? Center(
                                          child: Container(
                                            width: size - 6,
                                            height: size - 6,
                                            decoration: BoxDecoration(
                                              color: c.accentFill,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: digit,
                                          ),
                                        )
                                      : Center(child: digit),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: 6,
                              child: state == WeekDayState.done ||
                                      state == WeekDayState.partial
                                  ? ClipRect(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        widthFactor:
                                            state == WeekDayState.partial
                                                ? .5
                                                : 1,
                                        child: Container(
                                          width: 5,
                                          height: 5,
                                          decoration: BoxDecoration(
                                            color: c.accent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
