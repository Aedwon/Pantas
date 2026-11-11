import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_tooltip.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/roving_focus.dart';
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
///
/// Keyboard: Tab reaches the selected day only. Left and Right choose the
/// next day, Home and End the first and the last day shown. The tooltip is
/// one bubble above the strip, at the hovered or focused day and clamped to
/// the strip. Hover and focus are tracked apart and it stays while either
/// holds. The hover zone is the strip, the tooltip and the 8 point bridge
/// between them, and Esc dismisses it (WCAG 1.4.13). It is hidden from
/// screen readers: each day's name already ends with its status.
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

class _WeekStripState extends State<WeekStrip>
    with SingleTickerProviderStateMixin {
  ScrollController? _scroll;
  final _stripKey = GlobalKey();
  final List<GlobalKey> _dayKeys = List.generate(7, (_) => GlobalKey());
  final _portal = OverlayPortalController();
  late final AnimationController _fade;

  /// The day under the pointer while it is in the hover zone, and the day
  /// with keyboard focus. They are tracked apart: the tooltip stays while
  /// either holds.
  int? _hover;
  int? _focus;

  /// True once the hover delay has passed, so moving to another day swaps
  /// the tooltip at once.
  bool _hoverShown = false;
  Timer? _timer;

  /// The day the tooltip is on, or null while it is hidden. [_last] keeps the
  /// day while it fades out.
  int? _shown;
  int _last = 0;
  bool _overStrip = false;
  bool _overTip = false;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(vsync: this, duration: PantasDurations.short2)
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && _portal.isShowing) {
          _portal.hide();
        }
      });
  }

  @override
  void dispose() {
    _timer?.cancel();
    HardwareKeyboard.instance.removeHandler(_escape);
    _fade.dispose();
    _scroll?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WeekStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shown = _shown;
    if (shown != null && _statusAt(shown) == null) _show(null);
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

  DateTime _dateAt(int i) {
    final start = widget.windowStart ?? PantasDates.weekStart(widget.today);
    return DateTime(start.year, start.month, start.day + i);
  }

  String? _statusAt(int i) => _status(widget.states[i], _dateAt(i));

  /// The one day Tab reaches: the selected day, or Today when the selection
  /// is outside this week.
  int get _tabStop {
    for (var i = 0; i < widget.states.length; i++) {
      if (widget.selectedDate == _dateAt(i)) return i;
    }
    final today = widget.states.indexOf(WeekDayState.today);
    return today < 0 ? 0 : today;
  }

  void _show(int? day) {
    if (day == _shown) return;
    if (day != null) _last = day;
    setState(() => _shown = day);
    if (day == null) {
      HardwareKeyboard.instance.removeHandler(_escape);
      unawaited(_fade.reverse());
    } else {
      if (_shown != null && !_portal.isShowing) _portal.show();
      HardwareKeyboard.instance
        ..removeHandler(_escape)
        ..addHandler(_escape);
      unawaited(_fade.forward());
    }
  }

  /// Esc hides the tooltip without moving focus or the pointer. The key is
  /// consumed only while a tooltip is up.
  bool _escape(KeyEvent event) {
    if (event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        _shown == null) {
      return false;
    }
    _timer?.cancel();
    _hoverShown = false;
    _show(null);
    return true;
  }

  void _hoverDay(int i) {
    _hover = i;
    _timer?.cancel();
    if (_statusAt(i) == null) {
      _hoverShown = false;
      _show(_focus);
    } else if (_hoverShown) {
      _show(i);
    } else {
      _timer = Timer(PantasDurations.tooltip, () {
        if (!mounted || _hover != i) return;
        _hoverShown = true;
        _show(i);
      });
    }
  }

  void _syncHover() {
    if (_overStrip || _overTip) return;
    _hover = null;
    _hoverShown = false;
    _timer?.cancel();
    _show(_focus);
  }

  /// Exits are delivered before the enters of the same pointer move, so the
  /// zone is judged after both: crossing from the strip onto the tooltip
  /// never leaves it.
  void _zone({bool? strip, bool? tip}) {
    if (strip != null) _overStrip = strip;
    if (tip != null) _overTip = tip;
    scheduleMicrotask(() {
      if (mounted) _syncHover();
    });
  }

  void _focusDay(int i, {required bool focused}) {
    if (focused) {
      if (!webKeyboardFocus({WidgetState.focused}) || _statusAt(i) == null) {
        return;
      }
      _focus = i;
      _show(i);
    } else if (_focus == i) {
      _focus = null;
      _show(_hoverShown ? _hover : null);
    }
  }

  Widget _tip(BuildContext context) {
    final strip = _stripKey.currentContext?.findRenderObject();
    final day = _dayKeys[_last].currentContext?.findRenderObject();
    final overlay = Overlay.maybeOf(context)?.context.findRenderObject();
    final status = _statusAt(_last);
    if (strip is! RenderBox ||
        day is! RenderBox ||
        overlay is! RenderBox ||
        !strip.attached ||
        !day.attached ||
        status == null) {
      return const SizedBox.shrink();
    }
    final origin = overlay.globalToLocal(strip.localToGlobal(Offset.zero));
    final center = overlay.globalToLocal(
      day.localToGlobal(day.size.center(Offset.zero)),
    );
    return Positioned.fill(
      child: CustomSingleChildLayout(
        delegate: _StripTipLayout(
          strip: origin & strip.size,
          centerX: center.dx,
        ),
        child: FadeTransition(
          opacity: _fade,
          child: ExcludeSemantics(
            // The hover zone includes the tooltip and its 8 point bridge.
            child: MouseRegion(
              onEnter: (_) => _zone(tip: true),
              onExit: (_) => _zone(tip: false),
              child: Padding(
                padding: const EdgeInsets.only(bottom: PantasSpace.s8),
                child: PantasTooltipBubble(message: status),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _window(BuildContext context, List<FocusNode> nodes) {
    final phone = !context.wideWeb;
    final grow = WeekStrip._grow(context);
    final cell = WeekStrip.cellFor(grow);
    final touching = widget.windowGap == 0;
    final days = [
      for (var i = 0; i < widget.states.length; i++)
        _day(
          context,
          i,
          _dateAt(i),
          phone: phone,
          grow: grow,
          cellWidth: cell,
          state: widget.states[i],
          inset: touching,
          node: nodes[i],
        ),
    ];
    final row = Row(
      mainAxisSize: touching ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment:
          touching ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: days,
    );
    return KeyedSubtree(
      key: _stripKey,
      child: Semantics(
        role: SemanticsRole.tabBar,
        explicitChildNodes: true,
        child: row,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = !context.wideWeb;
    return RovingFocus(
      count: 7,
      tabStop: _tabStop,
      wrap: false,
      vertical: false,
      onSelect: (i) => widget.onSelected(_dateAt(i)),
      builder: (context, nodes) => OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _tip,
        child: MouseRegion(
          onEnter: (_) => _zone(strip: true),
          onExit: (_) => _zone(strip: false),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (widget.windowStart != null) return _window(context, nodes);
              final grow = WeekStrip._grow(context);
              final cell = WeekStrip.cellFor(grow);
              final gap = WeekStrip.gapFor(constraints.maxWidth, cell);
              final content = cell * 7 + gap * 6;
              final scrolls =
                  constraints.hasBoundedWidth && content > constraints.maxWidth;
              _scroll ??= ScrollController(
                initialScrollOffset: (widget.today.weekday % 7) * (cell + gap),
              );
              final row = Semantics(
                role: SemanticsRole.tabBar,
                explicitChildNodes: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 7; i++) ...[
                      if (i > 0) SizedBox(width: gap),
                      _day(
                        context,
                        i,
                        _dateAt(i),
                        phone: phone,
                        grow: grow,
                        cellWidth: cell,
                        state: widget.states[i],
                        node: nodes[i],
                      ),
                    ],
                  ],
                ),
              );
              return Align(
                key: _stripKey,
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  // Focus rings reach 4 px outside a day: they may leave the
                  // box only while nothing scrolls.
                  clipBehavior: scrolls ? Clip.hardEdge : Clip.none,
                  physics:
                      scrolls ? null : const NeverScrollableScrollPhysics(),
                  child: row,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _day(
    BuildContext context,
    int i,
    DateTime date, {
    required bool phone,
    required double grow,
    required double cellWidth,
    required FocusNode node,
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
            focusNode: node,
            onTap: () => widget.onSelected(date),
            onFocusChange: (focused) => _focusDay(i, focused: focused),
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
    return Semantics(
      key: _dayKeys[i],
      role: SemanticsRole.tab,
      label: label,
      selected: selected,
      excludeSemantics: true,
      onTap: () => widget.onSelected(date),
      child: MouseRegion(
        onEnter: (_) => _hoverDay(i),
        child: ringed,
      ),
    );
  }
}

/// Places the strip's tooltip above the strip, centered on the hovered or
/// focused day and kept inside the strip (the README's `--x` rule).
class _StripTipLayout extends SingleChildLayoutDelegate {
  _StripTipLayout({required this.strip, required this.centerX});

  final Rect strip;
  final double centerX;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final room = math.max(0, strip.width - childSize.width);
    final left = (centerX - childSize.width / 2).clamp(
      strip.left,
      strip.left + room,
    );
    return Offset(left, strip.top - childSize.height);
  }

  @override
  bool shouldRelayout(_StripTipLayout oldDelegate) =>
      oldDelegate.strip != strip || oldDelegate.centerX != centerX;
}
