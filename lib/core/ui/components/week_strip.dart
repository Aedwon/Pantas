import 'package:flutter/material.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

// Pending Aedwon decision, October 10 lead ruling. HP_Free's day-off text.
const weekStripDayOffColor = Color(0xFFC7C7CC);

enum WeekDayState { done, partial, missed, dayOff, today, plain }

class WeekStrip extends StatefulWidget {
  const WeekStrip({
    required this.today,
    required this.states,
    required this.onSelected,
    this.todayFraction = 0,
    this.selectedDate,
    super.key,
  }) : assert(states.length == 7);
  final DateTime today;
  final List<WeekDayState> states;
  final ValueChanged<DateTime> onSelected;
  final double todayFraction;
  final DateTime? selectedDate;
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
    final scale = MediaQuery.textScalerOf(context);
    final markSize = scale.scale(15) * 1.35 + 4;
    final size = markSize > 34 ? markSize : 34.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth / 7)
            .clamp(scale.scale(10) * 3.5, double.infinity);
        _scroll ??= ScrollController(
          initialScrollOffset: (widget.today.weekday % 7) * width,
        );
        return SizedBox(
          height: scale.scale(10) * 1.35 + size + 12,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: (constraints.maxWidth - width) / 2,
            ),
            child: Row(
              children: List.generate(7, (i) {
                final date = DateTime(start.year, start.month, start.day + i);
                final state = widget.states[i];
                final today = state == WeekDayState.today;
                final dayOff = state == WeekDayState.dayOff;
                final color = dayOff
                    ? weekStripDayOffColor
                    : today
                        ? c.accent
                        : c.secondaryLabel;
                final selected = widget.selectedDate == date;
                final digit = Text(
                  '${date.day}',
                  style: context.type.body.copyWith(
                    fontSize: today ? 14 : 15,
                    fontWeight: today ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0,
                    color: dayOff
                        ? weekStripDayOffColor
                        : today
                            ? (Theme.of(context).brightness == Brightness.dark
                                ? c.surface
                                : Colors.white)
                            : c.label,
                  ),
                );
                return SizedBox(
                  width: width,
                  child: Semantics(
                    label: PantasDates.heading(date),
                    selected: selected,
                    child: Material(
                      color: Colors.transparent,
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
                              child: today
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
