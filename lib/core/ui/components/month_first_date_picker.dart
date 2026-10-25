import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

@immutable
class MonthFirstDate {
  const MonthFirstDate({required this.year, this.month, this.day});
  final int year;
  final int? month;
  final int? day;
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
  @override
  void didUpdateWidget(MonthFirstDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value.year != value.year) {
      _direction = value.year > oldWidget.value.year ? 1 : -1;
    }
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
                if (month != start) const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    key: ValueKey('date-month-$month'),
                    onPressed: year == today.year && month < today.month
                        ? null
                        : () =>
                            onChanged(MonthFirstDate(year: year, month: month)),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 52),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                      backgroundColor:
                          value.month == month ? c.accentFill : c.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      DateFormat('MMM', 'en_US').format(DateTime(year, month)),
                      style: context.type.emphasized.copyWith(
                        fontSize: 17,
                        color: year == today.year && month < today.month
                            ? c.chevron
                            : value.month == month
                                ? (c.onAccent)
                                : c.label,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        )
        ..add(const SizedBox(height: 8));
    }
    if (onboarding && rows.isNotEmpty) rows.removeLast();
    final days = <Widget>[];
    if (value.month != null) {
      final month = value.month!;
      final last = DateTime(year, month + 1, 0).day;
      final scale = MediaQuery.textScalerOf(context);
      final width = (scale.scale(19) * 2.2 + 6).clamp(48.0, double.infinity);
      final height = (scale.scale(11) * 1.35 + scale.scale(19) * 1.35 + 12)
          .clamp(60.0, double.infinity);
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
                  TextButton(
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
                    style: TextButton.styleFrom(
                      minimumSize: Size(width, height),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 8,
                      ),
                      backgroundColor: selected ? c.accentFill : c.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isToday && !selected
                              ? c.accent
                              : context.colors.transparent,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('EEE', 'en_US').format(date),
                          style: context.type.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: past
                                ? c.chevron
                                : selected
                                    ? (c.onAccent)
                                    : isToday
                                        ? c.accent
                                        : c.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$day',
                          style: context.type.body.copyWith(
                            fontSize: 19,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            color: past
                                ? c.chevron
                                : selected
                                    ? (c.onAccent)
                                    : c.label,
                            letterSpacing: -.228,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isToday)
                    Text(
                      'Today',
                      style: context.type.caption.copyWith(color: c.accent),
                    ),
                ],
              ),
            ),
          )
          ..add(const SizedBox(width: 8));
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
    final monthCard = card('onboarding-month-card', [
      Row(
        children: [
          Expanded(child: Text('$year', style: context.type.emphasized)),
          IconButton(
            tooltip: 'Previous year',
            onPressed: year <= today.year
                ? null
                : () => onChanged(MonthFirstDate(year: year - 1)),
            icon: Icon(
              PantasIcons.back,
              size: 22,
              color: year <= today.year ? c.chevron : c.accent,
            ),
          ),
          IconButton(
            tooltip: 'Next year',
            onPressed: () => onChanged(MonthFirstDate(year: year + 1)),
            icon: Icon(PantasIcons.next, size: 22, color: c.accent),
          ),
        ],
      ),
      const SizedBox(height: 10),
      if (onboarding)
        AnimatedSwitcher(
          key: const ValueKey('onboarding-year-motion'),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 320),
          reverseDuration: Duration.zero,
          transitionBuilder: (child, animation) => AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) {
              final p = PantasCurves.riseIn.transform(animation.value);
              return Opacity(
                opacity: p,
                child: Transform.translate(
                  offset: Offset((1 - p) * 40 * _direction, 0),
                  child: child,
                ),
              );
            },
          ),
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
          spacing: 12,
          runSpacing: 4,
          children: [
            Text('Know the exact day?', style: context.type.subheadStrong),
            Text(
              DateFormat('MMMM y', 'en_US')
                  .format(DateTime(year, value.month!)),
              style: context.type.footnote,
            ),
            if (!onboarding && value.day != null)
              TextButton(
                onPressed: () => onChanged(
                  MonthFirstDate(year: year, month: value.month),
                ),
                child: Text(
                  'Month only',
                  style: context.type.footnote.copyWith(color: c.accent),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
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
        const SizedBox(height: 8),
        Text(
          note,
          style: context.type.footnote.copyWith(height: 1.4),
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
            const SizedBox(height: 18),
            card('onboarding-day-card', dayChildren),
          ],
        ],
      );
    }
    return card('date-picker-card', [
      Row(
        children: [
          Expanded(child: Text('$year', style: context.type.emphasized)),
          IconButton(
            tooltip: 'Previous year',
            onPressed: year <= today.year
                ? null
                : () => onChanged(MonthFirstDate(year: year - 1)),
            icon: Icon(
              PantasIcons.back,
              size: 22,
              color: year <= today.year ? c.chevron : c.accent,
            ),
          ),
          IconButton(
            tooltip: 'Next year',
            onPressed: () => onChanged(MonthFirstDate(year: year + 1)),
            icon: Icon(PantasIcons.next, size: 22, color: c.accent),
          ),
        ],
      ),
      const SizedBox(height: 10),
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
          duration: const Duration(milliseconds: 400),
          curve: PantasCurves.houseOut,
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
    final stride = (MediaQuery.textScalerOf(context).scale(19) * 2.2 + 6)
            .clamp(48.0, double.infinity) +
        8;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!still) await Future<void>.delayed(const Duration(milliseconds: 450));
      if (!mounted || generation != _generation || !_scroll.hasClients) return;
      final target = (((widget.selected ?? 1) - 4) * stride)
          .clamp(0.0, _scroll.position.maxScrollExtent);
      if (still) {
        _scroll.jumpTo(target);
      } else {
        await _scroll.animateTo(
          target,
          duration: const Duration(milliseconds: 900),
          curve: const Cubic(.3, .9, .3, 1),
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
