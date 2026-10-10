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

class MonthFirstDatePicker extends StatelessWidget {
  const MonthFirstDatePicker({
    required this.value,
    required this.today,
    required this.onChanged,
    super.key,
  });
  final MonthFirstDate value;
  final DateTime today;
  final ValueChanged<MonthFirstDate> onChanged;
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
                        color: year == today.year && month < today.month
                            ? c.chevron
                            : value.month == month
                                ? (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? c.surface
                                    : Colors.white)
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
    final days = <Widget>[];
    if (value.month != null) {
      final month = value.month!;
      final last = DateTime(year, month + 1, 0).day;
      final scale = MediaQuery.textScalerOf(context);
      final width = (scale.scale(19) * 2.2 + 8).clamp(48.0, double.infinity);
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
                              : Colors.transparent,
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
                                    ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? c.surface
                                        : Colors.white)
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
                                    ? (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? c.surface
                                        : Colors.white)
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
        : DateFormat('EEEE, MMMM d', 'en_US')
            .format(DateTime(year, value.month!, value.day!));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 400),
            curve: PantasCurves.houseOut,
            child: value.month == null
                ? const SizedBox.shrink()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Know the exact day?',
                              style: context.type.subheadStrong,
                            ),
                          ),
                          if (value.day != null)
                            TextButton(
                              onPressed: () => onChanged(
                                MonthFirstDate(
                                  year: year,
                                  month: value.month,
                                ),
                              ),
                              child: Text(
                                'Month only',
                                style: context.type.footnote
                                    .copyWith(color: c.accent),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                  ),
          ),
        ],
      ),
    );
  }
}
