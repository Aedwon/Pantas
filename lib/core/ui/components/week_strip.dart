import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

// Pending Aedwon decision, October 10 lead ruling. HP_Free's day-off text.

enum WeekDayState { done, partial, missed, dayOff, today, plain }

/// How many days the phone Home row shows and where the chip goes (D196).
class WeekWindowPlan {
  const WeekWindowPlan({
    required this.days,
    required this.chipBeside,
    required this.touching,
  });

  /// 3 to 5 beside the chip; 1 to 5 with the chip under.
  final int days;
  final bool chipBeside;

  /// Five days: zero gap, rings inside.
  final bool touching;
}

/// The seven days of the current week (design system WeekStrip): 44 px day
/// columns, a gap that shrinks from 10 toward 4 as the strip narrows and a
/// sideways scroll when seven days do not fit. A day with a status shows a
/// tooltip after `dur-tooltip` on a fine pointer, and at once on keyboard
/// focus; the tooltip lives in the overlay, outside the scroller, so the
/// scroller cannot clip it. The card and the ExamChip belong to the screen.
class WeekStrip extends StatefulWidget {
  const WeekStrip({
    required this.today,
    required this.states,
    required this.onSelected,
    this.todayFraction = 0,
    this.selectedDate,
    super.key,
  })  : assert(states.length == 7, 'A week must have seven days.'),
        windowStart = null,
        windowGap = null;

  /// The phone Home row (D196): [states].length days in a row, starting at
  /// [windowStart] and centered on Today, crossing week boundaries. With
  /// [windowGap] 0 the cells touch and the rings draw inside; null spreads
  /// them across the width (4 at least). Nothing scrolls.
  const WeekStrip.window({
    required this.today,
    required this.states,
    required this.onSelected,
    required DateTime this.windowStart,
    this.windowGap,
    this.todayFraction = 0,
    this.selectedDate,
    super.key,
  }) : assert(states.length > 0, 'A window needs a day.');
  final DateTime today;
  final List<WeekDayState> states;
  final DateTime? windowStart;
  final double? windowGap;
  final ValueChanged<DateTime> onSelected;
  final double todayFraction;
  final DateTime? selectedDate;

  static const double _cell = PantasSize.weekDay;

  /// The day column width at the current text size (44, or wider at large
  /// text).
  static double cellWidth(BuildContext context) => cellFor(_grow(context));

  /// How the phone Home row lays out (D196), for a card [width], day column
  /// [cell] and exam chip block [chip] (hairline, padding and chip).
  ///
  /// Five days with no gap fit beside the chip first; then four, then three,
  /// each at the 4 minimum gap and 4 clear of the chip. If three do not fit,
  /// the chip goes under and the strip shows as many days as fit, at most
  /// five.
  static WeekWindowPlan plan({
    required double width,
    required double cell,
    required double chip,
  }) {
    if (5 * cell + chip <= width) {
      return const WeekWindowPlan(days: 5, chipBeside: true, touching: true);
    }
    for (final n in const [4, 3]) {
      if (n * cell + (n - 1) * _gapMin + _gapMin + chip <= width) {
        return WeekWindowPlan(days: n, chipBeside: true, touching: false);
      }
    }
    var n = 5;
    while (n > 1 && n * cell + (n - 1) * _gapMin > width) {
      n--;
    }
    return WeekWindowPlan(days: n, chipBeside: false, touching: false);
  }

  static const double _gapMax = PantasSpace.s10;
  static const double _gapMin = PantasSpace.s4;

  /// The 34 px ring around Today's disc (`.wd__ring`).
  static const double _ring = PantasSize.avatarLg - PantasSpace.s10;

  /// How much Today's disc and ring grow. Up to 1.3x text the day keeps its
  /// 44px column and the drawn sizes (the 34px ring fits 44 with room), so a
  /// 390 phone still shows seven days unscrolled. Beyond 1.3x they grow by
  /// the excess, so at 200% the date is not squeezed and the ring is not
  /// clipped.
  static double _grow(BuildContext context) {
    final grown = MediaQuery.textScalerOf(context).scale(16) / 16;
    return grown <= 1.3 ? 1 : grown - 0.3;
  }

  /// Today's disc: 26 on wide screens, 28 on the phone, grown with the text.
  static double _disc(bool phone, double grow) =>
      (phone ? PantasSpace.s28 : PantasSize.task) * grow;

  /// A day column: 44, or as wide as the grown ring plus 4 on each side, so
  /// the weekday and the ring fit at large text. The strip scrolls when seven
  /// do not fit.
  static double cellFor(double grow) {
    final needed = _ring * grow + 2 * PantasSpace.s4;
    return needed > _cell ? needed : _cell;
  }

  /// The gap between day columns for a strip [width] wide: 10 when the strip
  /// has room, down to 4 as it narrows.
  static double gapFor(double width, [double cell = _cell]) {
    final room = (width - cell * 7) / 6;
    return room.clamp(_gapMin, _gapMax);
  }

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
    final phone = !context.wideWeb;
    final grow = _grow(context);
    final cell = cellFor(grow);
    final gap = gapFor(width, cell);
    final content = cell * 7 + gap * 6;
    final lastIsToday = states.last == WeekDayState.today;
    final double visible;
    if (lastIsToday) {
      visible = todayFraction > 0 ? _ring * grow : _disc(phone, grow);
    } else {
      final start = PantasDates.weekStart(today);
      final last = DateTime(start.year, start.month, start.day + 6);
      final painter = TextPainter(
        text: TextSpan(
          text: '${last.day}',
          style: _digitStyle(today: false),
        ),
        textDirection: TextDirection.ltr,
        textScaler: scale,
      )..layout(maxWidth: cell);
      visible = painter.width;
      painter.dispose();
    }
    final inset = (cell - visible) / 2;
    if (content <= width) return inset + (width - content);
    final maxScroll = content - width;
    final startScroll = (today.weekday % 7 * (cell + gap)).clamp(
      0.0,
      maxScroll,
    );
    final cutOff = content - width - startScroll;
    final cut = inset - cutOff;
    return cut < 0 ? 0 : cut;
  }

  static TextStyle _digitStyle({required bool today}) => today
      ? PantasType.webLabel.copyWith(fontWeight: FontWeight.w700)
      : PantasType.webNav.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        );

  @override
  State<WeekStrip> createState() => _WeekStripState();
}

class _WeekStripState extends State<WeekStrip> {
  ScrollController? _scroll;
  final List<GlobalKey<TooltipState>> _tips =
      List.generate(7, (_) => GlobalKey<TooltipState>());

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  /// The status a day's tooltip states, or null for a day with none.
  String? _status(WeekDayState state, DateTime date) => switch (state) {
        WeekDayState.today => 'Today',
        WeekDayState.done => 'Done',
        WeekDayState.partial => 'Partly done',
        WeekDayState.missed => 'No study',
        WeekDayState.plain => date.isAfter(widget.today) ? 'Planned' : null,
        WeekDayState.dayOff => null,
      };

  Widget _window(BuildContext context) {
    final phone = !context.wideWeb;
    final grow = WeekStrip._grow(context);
    final cell = WeekStrip.cellFor(grow);
    final first = widget.windowStart!;
    final touching = widget.windowGap == 0;
    final days = [
      for (var i = 0; i < widget.states.length; i++)
        _day(
          context,
          i,
          DateTime(first.year, first.month, first.day + i),
          phone: phone,
          grow: grow,
          cellWidth: cell,
          state: widget.states[i],
          inset: touching,
        ),
    ];
    return Row(
      mainAxisSize: touching ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment:
          touching ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: days,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.windowStart != null) return _window(context);
    final start = PantasDates.weekStart(widget.today);
    final phone = !context.wideWeb;
    return LayoutBuilder(
      builder: (context, constraints) {
        final grow = WeekStrip._grow(context);
        final cell = WeekStrip.cellFor(grow);
        final gap = WeekStrip.gapFor(constraints.maxWidth, cell);
        final content = cell * 7 + gap * 6;
        final scrolls =
            constraints.hasBoundedWidth && content > constraints.maxWidth;
        _scroll ??= ScrollController(
          initialScrollOffset: (widget.today.weekday % 7) * (cell + gap),
        );
        final row = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i > 0) SizedBox(width: gap),
              _day(
                context,
                i,
                DateTime(start.year, start.month, start.day + i),
                phone: phone,
                grow: grow,
                cellWidth: cell,
                state: widget.states[i],
              ),
            ],
          ],
        );
        return Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            // Focus rings reach 4 px outside a day: they may leave the box
            // only while nothing scrolls.
            clipBehavior: scrolls ? Clip.hardEdge : Clip.none,
            physics: scrolls ? null : const NeverScrollableScrollPhysics(),
            child: row,
          ),
        );
      },
    );
  }

  Widget _day(
    BuildContext context,
    int i,
    DateTime date, {
    required bool phone,
    required double grow,
    required double cellWidth,
    required WeekDayState state,
    bool inset = false,
  }) {
    final c = context.colors;
    final today = state == WeekDayState.today;
    final off = state == WeekDayState.dayOff || state == WeekDayState.missed;
    final selected = widget.selectedDate == date;
    final status = _status(state, date);
    final radius = BorderRadius.circular(
      phone ? PantasRadius.sm : PantasRadius.md,
    );
    final disc = WeekStrip._disc(phone, grow);
    final digit = Text(
      '${date.day}',
      style: WeekStrip._digitStyle(today: today).copyWith(
        color: today
            ? c.onAccent
            : off
                ? c.textSecondary
                : c.textPrimary,
        fontWeight: off && !today ? FontWeight.w400 : null,
      ),
    );
    final weekday = Text(
      const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7],
      style: (phone ? PantasType.phoneCaptionSmall : PantasType.webKeyHintSm)
          .copyWith(
        color: today ? c.accent : c.textSecondary,
        fontWeight: today
            ? FontWeight.w700
            : off
                ? FontWeight.w400
                : null,
      ),
    );
    Widget mark;
    if (today) {
      final fill = DecoratedBox(
        decoration: BoxDecoration(color: c.accentFill, shape: BoxShape.circle),
        child: SizedBox.square(
          dimension: disc,
          child: Center(child: digit),
        ),
      );
      mark = widget.todayFraction > 0
          ? ProgressRing(
              size: WeekStrip._ring * grow,
              fraction: widget.todayFraction,
              showCheck: false,
              child: fill,
            )
          : fill;
    } else {
      mark = digit;
    }
    final dot = switch (state) {
      WeekDayState.done => c.accent,
      _ => null,
    };
    final half = state == WeekDayState.partial;
    final label = status == null
        ? PantasDates.heading(date)
        : '${PantasDates.heading(date)}, ${status.toLowerCase()}';
    final ringed = OffsetFocusRing(
      inset: inset,
      borderRadius: radius,
      color: selected ? c.textPrimary : null,
      child: PressScale(
        scale: .97,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: ValueKey('week-day-$i'),
            onTap: () => widget.onSelected(date),
            onFocusChange: (focused) {
              if (focused &&
                  webKeyboardFocus({WidgetState.focused}) &&
                  status != null) {
                _tips[i].currentState?.ensureTooltipVisible();
              }
            },
            borderRadius: radius,
            hoverColor: c.surfaceHover,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              width: cellWidth,
              padding: const EdgeInsets.symmetric(vertical: PantasSpace.s4),
              foregroundDecoration: selected
                  ? BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(
                        color: c.accent,
                        width: PantasBorder.ringSelected,
                      ),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  weekday,
                  const SizedBox(height: PantasSpace.s2),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: math.max<double>(
                        PantasSize.tileDay / 2 - PantasSpace.s8,
                        WeekStrip._ring * grow,
                      ),
                    ),
                    child: Center(child: mark),
                  ),
                  const SizedBox(height: PantasSpace.s2),
                  SizedBox.square(
                    dimension: PantasSize.accuracyBar,
                    child: half
                        ? DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                stops: const [.5, .5],
                                colors: [c.accent, c.dividerStrong],
                              ),
                            ),
                          )
                        : dot == null
                            ? null
                            : DecoratedBox(
                                decoration: BoxDecoration(
                                  color: dot,
                                  shape: BoxShape.circle,
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Widget cell = ringed;
    if (status != null) {
      cell = Tooltip(
        key: _tips[i],
        message: status,
        excludeFromSemantics: true,
        waitDuration: PantasDurations.tooltip,
        triggerMode: TooltipTriggerMode.manual,
        preferBelow: false,
        verticalOffset: cellWidth / 2 + PantasSpace.s16,
        constraints: const BoxConstraints(maxWidth: PantasSize.tooltipMax),
        padding: const EdgeInsets.symmetric(
          horizontal: PantasSpace.s8,
          vertical: PantasSpace.s4,
        ),
        decoration: BoxDecoration(
          color: c.toastBg,
          borderRadius: BorderRadius.circular(PantasRadius.sm),
          boxShadow: context.shadows.toast,
        ),
        textStyle: PantasType.webCaption.copyWith(color: c.toastText),
        child: ringed,
      );
    }
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      excludeSemantics: true,
      onTap: () => widget.onSelected(date),
      child: cell,
    );
  }
}
