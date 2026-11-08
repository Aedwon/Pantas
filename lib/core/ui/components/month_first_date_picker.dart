import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

@immutable
class MonthFirstDate {
  const MonthFirstDate({required this.year, this.month, this.day});
  final int year;
  final int? month;
  final int? day;
}

/// Swaps a keyed child with the date picker's year motion: 320 ms on
/// `riseIn`, drifting 40 px in from [direction] (1 from the right, -1 from
/// the left). The old child leaves at once. The wide calendar reuses it for
/// a month change.
class MonthRiseSwitcher extends StatelessWidget {
  const MonthRiseSwitcher({
    required this.direction,
    required this.child,
    this.switcherKey,
    super.key,
  });
  final int direction;
  final Widget child;
  final Key? switcherKey;
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        key: switcherKey,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : PantasDurations.medium2,
        reverseDuration: Duration.zero,
        transitionBuilder: (child, animation) => AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final p = PantasCurves.enter.transform(animation.value);
            return Opacity(
              opacity: p,
              child: Transform.translate(
                offset: Offset((1 - p) * PantasSpace.s40 * direction, 0),
                child: child,
              ),
            );
          },
        ),
        child: child,
      );
}

class MonthFirstDatePicker extends StatefulWidget {
  const MonthFirstDatePicker({
    required this.value,
    required this.today,
    required this.onChanged,
    this.dayNote,
    super.key,
  }) : onboarding = false;
  const MonthFirstDatePicker.onboarding({
    required this.value,
    required this.today,
    required this.onChanged,
    this.dayNote,
    super.key,
  }) : onboarding = true;
  final bool onboarding;

  /// Words for the note under a chosen day. Callers that draw their own note
  /// pass this; without it the note is the weekday and date.
  final String Function(DateTime day)? dayNote;
  final MonthFirstDate value;
  final DateTime today;
  final ValueChanged<MonthFirstDate> onChanged;
  @override
  State<MonthFirstDatePicker> createState() => _MonthFirstDatePickerState();
}

class _MonthFirstDatePickerState extends State<MonthFirstDatePicker> {
  MonthFirstDate get value => widget.value;
  DateTime get today => widget.today;
  ValueChanged<MonthFirstDate> get onChanged => widget.onChanged;
  bool get onboarding => widget.onboarding;
  int _direction = 1;

  /// A day cell is 48 wide at default text and grows with the scaled digit.
  static double _dayWidth(TextScaler scale) => math.max<double>(
        PantasSize.weekDay + PantasSpace.s4,
        scale.scale(PantasType.webNav.fontSize!) * 2.2 + PantasSpace.s6,
      );
  @override
  void didUpdateWidget(MonthFirstDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value.year != value.year) {
      _direction = value.year > oldWidget.value.year ? 1 : -1;
    }
  }

  /// A grid cell's look (DatePicker README): `bg-page` well, `radius-md`,
  /// `surface-hover` under the pointer, `accent-fill` when chosen.
  ButtonStyle _cellStyle(
    PantasColors c, {
    required bool chosen,
    required Size minimum,
    required EdgeInsets padding,
  }) =>
      ButtonStyle(
        minimumSize: WidgetStatePropertyAll(minimum),
        padding: WidgetStatePropertyAll(padding),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        animationDuration: PantasDurations.short2,
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => chosen
              ? c.accentFill
              : states.contains(WidgetState.hovered) &&
                      !states.contains(WidgetState.disabled)
                  ? c.surfaceHover
                  : c.bgPage,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PantasRadius.md),
          ),
        ),
      );

  /// The year, with its previous and next buttons (44 px targets).
  Widget _yearRow(BuildContext context, int year) {
    final c = context.colors;
    const target = ButtonStyle(
      fixedSize: WidgetStatePropertyAll(
        Size.square(PantasSize.targetTouch),
      ),
      minimumSize: WidgetStatePropertyAll(
        Size.square(PantasSize.targetTouch),
      ),
      padding: WidgetStatePropertyAll(EdgeInsets.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return Row(
      children: [
        Expanded(
          child: Text(
            '$year',
            style: PantasType.webTitleSm.copyWith(color: c.textPrimary),
          ),
        ),
        OffsetFocusRing(
          borderRadius: BorderRadius.circular(PantasRadius.full),
          child: IconButton(
            style: target,
            tooltip: 'Previous year',
            onPressed: year <= today.year
                ? null
                : () => onChanged(MonthFirstDate(year: year - 1)),
            icon: Icon(
              PantasIcons.back,
              size: PantasSize.icon + PantasSpace.s2,
              color: year <= today.year ? c.iconChevron : c.accent,
            ),
          ),
        ),
        OffsetFocusRing(
          borderRadius: BorderRadius.circular(PantasRadius.full),
          child: IconButton(
            style: target,
            tooltip: 'Next year',
            onPressed: () => onChanged(MonthFirstDate(year: year + 1)),
            icon: Icon(
              PantasIcons.next,
              size: PantasSize.icon + PantasSpace.s2,
              color: c.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _monthCell(BuildContext context, int year, int month) {
    final c = context.colors;
    final past = year == today.year && month < today.month;
    final chosen = value.month == month;
    final label = DateFormat('MMMM', 'en_US').format(DateTime(year, month));
    return Semantics(
      label: label,
      button: true,
      selected: chosen,
      enabled: !past,
      excludeSemantics: true,
      child: OffsetFocusRing(
        borderRadius: BorderRadius.circular(PantasRadius.md),
        child: TextButton(
          key: ValueKey('date-month-$month'),
          onPressed: past
              ? null
              : () => onChanged(MonthFirstDate(year: year, month: month)),
          style: _cellStyle(
            c,
            chosen: chosen,
            minimum: const Size(
              PantasSize.targetTouch,
              PantasSize.targetTouch,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s4,
              vertical: PantasSpace.s12,
            ),
          ),
          child: Text(
            DateFormat('MMM', 'en_US').format(DateTime(year, month)),
            style: PantasType.webNav.copyWith(
              fontWeight: chosen
                  ? FontWeight.w700
                  : past
                      ? FontWeight.w400
                      : FontWeight.w500,
              color: past
                  ? c.textSecondary
                  : chosen
                      ? c.onAccent
                      : c.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final year = value.year < today.year ? today.year : value.year;
    final rows = <Widget>[];
    for (var start = 1; start <= 12; start += 3) {
      if (year == today.year && start + 2 < today.month) continue;
      rows
        ..add(
          Row(
            children: [
              for (var month = start; month < start + 3; month++) ...[
                if (month != start) const SizedBox(width: PantasSpace.s8),
                Expanded(
                  child: _monthCell(context, year, month),
                ),
              ],
            ],
          ),
        )
        ..add(const SizedBox(height: PantasSpace.s8));
    }
    if (onboarding && rows.isNotEmpty) rows.removeLast();
    final days = <Widget>[];
    if (value.month != null) {
      final month = value.month!;
      final last = DateTime(year, month + 1, 0).day;
      final scale = MediaQuery.textScalerOf(context);
      final width = _dayWidth(scale);
      final height = math.max<double>(
        PantasSize.dateCell + PantasSpace.s14,
        scale.scale(PantasType.webKeyHintSm.fontSize!) *
                PantasType.webKeyHintSm.height! +
            scale.scale(PantasType.webNav.fontSize!) *
                PantasType.webNav.height! +
            PantasSpace.s16,
      );
      for (var day = 1; day <= last; day++) {
        final date = DateTime(year, month, day);
        final past =
            date.isBefore(DateTime(today.year, today.month, today.day));
        final isToday = date == DateTime(today.year, today.month, today.day);
        final selected = value.day == day;
        // Fully past week rows are omitted; remaining past days stay dimmed.
        final endOfWeek = date.add(Duration(days: 7 - date.weekday % 7 - 1));
        if (endOfWeek.isBefore(DateTime(today.year, today.month, today.day))) {
          continue;
        }
        days
          ..add(
            SizedBox(
              width: width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: DateFormat('MMMM d, y', 'en_US').format(date),
                    button: true,
                    selected: selected,
                    enabled: !past,
                    excludeSemantics: true,
                    child: OffsetFocusRing(
                      borderRadius: BorderRadius.circular(PantasRadius.md),
                      child: TextButton(
                        key: ValueKey('date-day-$day'),
                        onPressed: past
                            ? null
                            : () => onChanged(
                                  MonthFirstDate(
                                    year: year,
                                    month: month,
                                    day: day,
                                  ),
                                ),
                        style: _cellStyle(
                          c,
                          chosen: selected,
                          minimum: Size(width, height),
                          padding: const EdgeInsets.symmetric(
                            horizontal: PantasSpace.s2,
                            vertical: PantasSpace.s8,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('EEE', 'en_US').format(date),
                              style: PantasType.webKeyHintSm.copyWith(
                                color: past
                                    ? c.textSecondary
                                    : selected
                                        ? c.onAccent
                                        : isToday
                                            ? c.accent
                                            : c.textSecondary,
                                fontWeight: isToday && !selected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: PantasSpace.s2),
                            Text(
                              '$day',
                              style: PantasType.webNav.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                fontWeight: selected || isToday
                                    ? FontWeight.w700
                                    : past
                                        ? FontWeight.w400
                                        : FontWeight.w500,
                                color: past
                                    ? c.textSecondary
                                    : selected
                                        ? c.onAccent
                                        : isToday
                                            ? c.accent
                                            : c.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isToday)
                    Text(
                      'Today',
                      style: PantasType.webCaption.copyWith(color: c.accent),
                    ),
                ],
              ),
            ),
          )
          ..add(const SizedBox(width: PantasSpace.s8));
      }
    }
    final monthLabel = value.month == null
        ? ''
        : DateFormat('MMMM', 'en_US').format(DateTime(year, value.month!));
    final planningStart = year == today.year && value.month == today.month
        ? 'today'
        : '1 $monthLabel';
    final note = value.day == null
        ? "No day yet? We'll plan from $planningStart and ask later."
        : widget.dayNote?.call(DateTime(year, value.month!, value.day!)) ??
            DateFormat('EEEE, MMMM d', 'en_US')
                .format(DateTime(year, value.month!, value.day!));
    Widget card(String key, List<Widget> children) => Container(
          key: ValueKey(key),
          padding: const EdgeInsets.all(PantasSpace.s14),
          decoration: BoxDecoration(
            color: c.surfaceCard,
            borderRadius: BorderRadius.circular(PantasRadius.xl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
    final monthCard = card('onboarding-month-card', [
      _yearRow(context, year),
      const SizedBox(height: PantasSpace.s10),
      if (onboarding)
        MonthRiseSwitcher(
          switcherKey: const ValueKey('onboarding-year-motion'),
          direction: _direction,
          child: Column(
            key: ValueKey(year),
            mainAxisSize: MainAxisSize.min,
            children: rows,
          ),
        )
      else
        ...rows,
    ]);
    final dayChildren = <Widget>[
      if (value.month != null) ...[
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: PantasSpace.s12,
          runSpacing: PantasSpace.s4,
          children: [
            Text(
              'Know the exact day?',
              style: PantasType.webLabel.copyWith(color: c.textPrimary),
            ),
            Text(
              DateFormat('MMMM y', 'en_US')
                  .format(DateTime(year, value.month!)),
              style: PantasType.webSmall.copyWith(color: c.textSecondary),
            ),
            if (!onboarding && value.day != null)
              TextButton(
                onPressed: () => onChanged(
                  MonthFirstDate(year: year, month: value.month),
                ),
                child: Text(
                  'Month only',
                  style: PantasType.webSmall.copyWith(color: c.accent),
                ),
              ),
          ],
        ),
        const SizedBox(height: PantasSpace.s8),
        if (onboarding)
          _DayStrip(
            key: ValueKey('$year-${value.month}'),
            selected: value.day,
            children: days,
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: days),
          ),
        const SizedBox(height: PantasSpace.s8),
        Text(
          note,
          style: PantasType.webSmall.copyWith(color: c.textSecondary),
        ),
      ],
    ];
    if (onboarding) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          monthCard,
          if (value.month != null) ...[
            const SizedBox(height: PantasSpace.s18),
            card('onboarding-day-card', dayChildren),
          ],
        ],
      );
    }
    return card('date-picker-card', [
      _yearRow(context, year),
      const SizedBox(height: PantasSpace.s10),
      ...rows,
      _CalendarExpansion(
        child: value.month == null
            ? const SizedBox.shrink()
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: dayChildren,
              ),
      ),
    ]);
  }
}

class _CalendarExpansion extends StatelessWidget {
  const _CalendarExpansion({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => MediaQuery.disableAnimationsOf(context)
      ? child
      : AnimatedSize(
          duration: PantasDurations.drawerClose,
          curve: PantasCurves.house,
          child: child,
        );
}

class _DayStrip extends StatefulWidget {
  const _DayStrip({required this.children, required this.selected, super.key});
  final List<Widget> children;
  final int? selected;
  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  final _scroll = ScrollController();
  int _generation = 0;
  bool _scheduled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_scheduled) {
      _scheduled = true;
      _scrollToSelected();
    }
  }

  @override
  void didUpdateWidget(_DayStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) _scrollToSelected();
  }

  void _scrollToSelected() {
    final generation = ++_generation;
    final still = MediaQuery.disableAnimationsOf(context);
    final stride =
        _MonthFirstDatePickerState._dayWidth(MediaQuery.textScalerOf(context)) +
            PantasSpace.s8;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!still) await Future<void>.delayed(PantasDurations.long1);
      if (!mounted || generation != _generation || !_scroll.hasClients) return;
      final target = (((widget.selected ?? 1) - 4) * stride)
          .clamp(0.0, _scroll.position.maxScrollExtent);
      if (still) {
        _scroll.jumpTo(target);
      } else {
        await _scroll.animateTo(
          target,
          duration: PantasDurations.long3,
          curve: PantasCurves.house,
        );
      }
    });
  }

  @override
  void dispose() {
    _generation++;
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        key: const ValueKey('onboarding-day-strip'),
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: Row(children: widget.children),
      );
}
