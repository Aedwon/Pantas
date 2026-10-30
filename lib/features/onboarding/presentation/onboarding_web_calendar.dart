import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Desktop month and day panels share the existing date value and save path.
class OnboardingWebCalendar extends StatelessWidget {
  const OnboardingWebCalendar({
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
    final t = context.webTokens;
    String monthName(int year, int month) =>
        DateFormat.MMMM('en_US').format(DateTime(year, month));
    final month = value.month;
    final selected =
        month == null ? null : DateTime(value.year, month, value.day ?? 1);
    final planningStart = selected != null &&
            selected.year == today.year &&
            selected.month == today.month
        ? 'today'
        : selected == null
            ? ''
            : DateFormat('MMMM 1', 'en_US').format(selected);
    final first = month == null ? 0 : DateTime(value.year, month).weekday % 7;
    final last = month == null ? 0 : DateTime(value.year, month + 1, 0).day;
    Widget grid(List<Widget> children, int columns) => GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          mainAxisExtent: columns == 3 ? 42 : 46,
          children: children,
        );
    Widget choice(
      String label,
      VoidCallback? action, {
      required bool picked,
      bool isToday = false,
      String? semantics,
    }) =>
        Semantics(
          selected: picked,
          label: semantics,
          child: TextButton(
            onPressed: action,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor:
                  picked ? t.colors.accentFill : t.colors.background,
              foregroundColor: picked ? Colors.white : t.colors.label,
              disabledForegroundColor: t.disabledText,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(semantics == null ? 12 : 10),
                side: BorderSide(
                  color:
                      isToday && !picked ? t.colors.accent : Colors.transparent,
                ),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isToday)
                  Text(
                    'Today',
                    style: t.style(
                      9,
                      weight: FontWeight.w700,
                      color: picked ? Colors.white : t.colors.accent,
                      height: 1,
                    ),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: semantics == null ? 16 : 15,
                    fontWeight: picked || isToday
                        ? FontWeight.w700
                        : semantics == null
                            ? FontWeight.w400
                            : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 270,
              child: WebCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final year in [today.year, today.year + 1]) ...[
                      Text(
                        '$year',
                        style: t.style(
                          13,
                          weight: FontWeight.w700,
                          color: t.colors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: 8),
                      grid(
                        [
                          for (var m = year == today.year
                                  ? ((today.month - 1) ~/ 3) * 3 + 1
                                  : 1;
                              m <= 12;
                              m++)
                            choice(
                              DateFormat('MMM', 'en_US')
                                  .format(DateTime(year, m)),
                              year == today.year && m < today.month
                                  ? null
                                  : () => onChanged(
                                        MonthFirstDate(year: year, month: m),
                                      ),
                              picked: value.year == year && month == m,
                              semantics: '${monthName(year, m)} $year',
                            ),
                        ],
                        3,
                      ),
                      if (year == today.year) const SizedBox(height: 18),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WebCard(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: month == null
                    ? SizedBox(
                        height: 322,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 32,
                                color: t.colors.tertiaryLabel,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Pick a month first.\n'
                                'Then add the day here if you know it.',
                                textAlign: TextAlign.center,
                                style: t.sm,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                DateFormat('MMMM y', 'en_US').format(selected!),
                                style: t.style(18, weight: FontWeight.w600),
                              ),
                              Text(
                                'Know the exact day? Optional',
                                style: t.sm,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              for (final d in [
                                'Sun',
                                'Mon',
                                'Tue',
                                'Wed',
                                'Thu',
                                'Fri',
                                'Sat',
                              ])
                                Expanded(
                                  child: Text(
                                    d,
                                    textAlign: TextAlign.center,
                                    style: t.style(
                                      12,
                                      weight: FontWeight.w600,
                                      color: t.colors.tertiaryLabel,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          grid(
                            [
                              for (var n = 0; n < first; n++)
                                const SizedBox.shrink(),
                              for (var d = 1; d <= last; d++)
                                choice(
                                  '$d',
                                  DateTime(value.year, month, d).isBefore(today)
                                      ? null
                                      : () => onChanged(
                                            MonthFirstDate(
                                              year: value.year,
                                              month: month,
                                              day: d,
                                            ),
                                          ),
                                  picked: value.day == d,
                                  isToday:
                                      DateTime(value.year, month, d) == today,
                                ),
                            ],
                            7,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          key: const ValueKey('calendar-status'),
          constraints: const BoxConstraints(minHeight: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (selected != null) ...[
                if (value.day != null)
                  Text(
                    DateFormat(
                      selected.year == today.year
                          ? 'EEEE, MMMM d'
                          : 'EEEE, MMMM d, y',
                      'en_US',
                    ).format(selected),
                    style: t.style(18, weight: FontWeight.w600),
                  ),
                Text(
                  value.day != null
                      ? selected == today
                          ? 'Today'
                          : '${selected.difference(today).inDays} '
                              'days from today'
                      : "No day yet? We'll plan from $planningStart "
                          'and ask later.',
                  style: t.sub,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
