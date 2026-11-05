import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Desktop month and day panels share the existing date value and save path.
///
/// Aedwon overrode the board's wider calendar on Nov 2, 2026: both panels now
/// fit the 580 column that every onboarding step uses.
class OnboardingWebCalendar extends StatefulWidget {
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
  State<OnboardingWebCalendar> createState() => _OnboardingWebCalendarState();
}

class _OnboardingWebCalendarState extends State<OnboardingWebCalendar> {
  MonthFirstDate get value => widget.value;
  DateTime get today => widget.today;
  ValueChanged<MonthFirstDate> get onChanged => widget.onChanged;
  int _direction = 1;

  /// Months counted from year zero, so a later month is a larger number.
  int _ordinal(MonthFirstDate date) => date.year * 12 + (date.month ?? 0);

  @override
  void didUpdateWidget(OnboardingWebCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = _ordinal(oldWidget.value);
    final after = _ordinal(value);
    if (before != after) _direction = after > before ? 1 : -1;
  }

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
    // Built from rows, not a GridView, so the panels can size to each other.
    Widget grid(List<Widget> children, int columns) {
      final gap = columns == 7 ? 4.0 : 6.0;
      final extent = columns == 3 ? 42.0 : 46.0;
      return Column(
        children: [
          for (var i = 0; i < children.length; i += columns) ...[
            if (i > 0) SizedBox(height: gap),
            SizedBox(
              height: extent,
              child: Row(
                children: [
                  for (var j = i; j < i + columns; j++) ...[
                    if (j > i) SizedBox(width: gap),
                    Expanded(
                      child: j < children.length
                          ? children[j]
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    }

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
              backgroundColor: picked
                  ? t.colors.accentFill
                  : semantics == null
                      ? Colors.transparent
                      : t.colors.background,
              foregroundColor: picked
                  ? Colors.white
                  : isToday
                      ? t.colors.accent
                      : t.colors.label,
              disabledForegroundColor: t.disabledText,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(semantics == null ? 12 : 10),
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
    // The day panel always draws six week rows.
    Widget monthBody(int year, int monthNumber) {
      final first = DateTime(year, monthNumber).weekday % 7;
      final last = DateTime(year, monthNumber + 1, 0).day;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                DateFormat('MMMM y', 'en_US')
                    .format(DateTime(year, monthNumber)),
                style: t.style(18, weight: FontWeight.w600),
              ),
              Text('Know the exact day? Optional', style: t.sm),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final d in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'])
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
          const SizedBox(height: 12),
          grid(
            [
              for (var n = 0; n < first; n++) const SizedBox.shrink(),
              for (var d = 1; d <= last; d++)
                choice(
                  '$d',
                  DateTime(year, monthNumber, d).isBefore(today)
                      ? null
                      : () => onChanged(
                            MonthFirstDate(
                              year: year,
                              month: monthNumber,
                              day: d,
                            ),
                          ),
                  picked: value.day == d,
                  isToday: DateTime(year, monthNumber, d) == today,
                ),
              for (var n = first + last; n < 42; n++) const SizedBox.shrink(),
            ],
            7,
          ),
        ],
      );
    }

    // The panel is as tall as the tallest a month can make it, so its height
    // does not depend on the month or on the placeholder: the cards and
    // buttons below no longer move when a month is picked (7W-3). That is six
    // week rows under a title that wraps above its hint, which only the long
    // month names do. Every month's header is laid out unseen to size it. They
    // are RichText, not Text, so nothing else finds them as content.
    final base = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    Widget ghostText(String text, TextStyle style) => RichText(
          text: TextSpan(text: text, style: base.merge(style)),
          textScaler: scaler,
        );
    Widget ghost(int monthNumber) => Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ghostText(
                    DateFormat('MMMM y', 'en_US')
                        .format(DateTime(today.year + 1, monthNumber)),
                    t.style(18, weight: FontWeight.w600),
                  ),
                  ghostText('Know the exact day? Optional', t.sm),
                ],
              ),
              const SizedBox(height: 12),
              ghostText('Sun', t.style(12, weight: FontWeight.w600)),
              const SizedBox(height: 12),
              grid([for (var n = 0; n < 42; n++) const SizedBox.shrink()], 7),
            ],
          ),
        );
    Widget panel(Key key, Widget content) => Stack(
          key: key,
          children: [for (var m = 1; m <= 12; m++) ghost(m), content],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 236,
                child: WebCard(
                  padding: const EdgeInsets.all(16),
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
              const SizedBox(width: 12),
              Expanded(
                child: WebCard(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  child: MonthRiseSwitcher(
                    direction: _direction,
                    child: month == null
                        ? panel(
                            const ValueKey('calendar-month-none'),
                            Positioned.fill(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.string(
                                      '<svg viewBox="0 0 24 24" fill="none" '
                                      'stroke="currentColor" '
                                      'stroke-width="1.5" '
                                      'stroke-linecap="round" '
                                      'stroke-linejoin="round"> '
                                      '<rect x="3.5" y="5" width="17" '
                                      'height="15.5" rx="2.5"/> '
                                      '<path d="M3.5 9.5h17M8 3v4M16 3v4"/></svg>',
                                      width: 36,
                                      height: 36,
                                      colorFilter: ColorFilter.mode(
                                        t.dark
                                            ? t.colors.tertiaryLabel
                                            : const Color(0xFFC7C7CC),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Pick a month first.\n'
                                      'Then add the day here if you know it.',
                                      textAlign: TextAlign.center,
                                      style: t.style(
                                        15,
                                        height: 1.45,
                                        color: t.colors.tertiaryLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : panel(
                            ValueKey('calendar-month-${value.year}-$month'),
                            monthBody(value.year, month),
                          ),
                  ),
                ),
              ),
            ],
          ),
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
