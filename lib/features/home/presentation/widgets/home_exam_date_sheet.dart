import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The exam date picker Home opens in a sheet (D-69): the same month-first
/// picker as onboarding. Save stays grey until a month is picked, or, when
/// [requireDay] is set for the month-only notice, until a day is.
class HomeExamDateSheet extends StatefulWidget {
  const HomeExamDateSheet({
    required this.today,
    required this.onSave,
    this.initial,
    this.onCancel,
    this.requireDay = false,
    this.saving = false,
    this.failed = false,
    this.web = kIsWeb,
    super.key,
  });
  final bool web;
  final VoidCallback? onCancel;
  final DateTime today;
  final ExamDate? initial;
  final bool requireDay;
  final bool saving;
  final bool failed;
  final ValueChanged<ExamDate> onSave;

  @override
  State<HomeExamDateSheet> createState() => _HomeExamDateSheetState();
}

class _HomeExamDateSheetState extends State<HomeExamDateSheet> {
  late MonthFirstDate _value = _from(widget.initial);

  MonthFirstDate _from(ExamDate? date) => date == null
      ? MonthFirstDate(year: widget.today.year)
      : MonthFirstDate(
          year: date.year,
          month: date.month,
          day: date.day?.day,
        );

  ExamDate? get _date {
    final month = _value.month;
    if (month == null) return null;
    final day = _value.day;
    if (day == null) {
      return widget.requireDay
          ? null
          : ExamDate.inMonth(year: _value.year, month: month);
    }
    return ExamDate.onDay(DateTime(_value.year, month, day));
  }

  @override
  Widget build(BuildContext context) {
    final date = _date;
    final monthLabel = DateFormat('MMMM', 'en_US').format(
      DateTime(_value.year, _value.month ?? 1),
    );
    final wide = isWideWebLayout(
      width: MediaQuery.sizeOf(context).width,
      web: widget.web,
    );
    final content = Padding(
      padding: wide
          ? const EdgeInsets.all(24)
          : const EdgeInsets.fromLTRB(20, 8, 20, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            wide && widget.requireDay
                ? 'Which day is your exam?'
                : 'When is your exam?',
            style: wide
                ? context.webTokens.h2
                : context.type.emphasized
                    .copyWith(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            wide && widget.requireDay
                ? 'Pick a day in $monthLabel.'
                : 'Pick the month. Add the day if you know it.',
            style: wide
                ? context.webTokens.sub
                : context.type.subhead
                    .copyWith(color: context.colors.secondaryLabel),
          ),
          const SizedBox(height: 18),
          if (wide)
            HomeWebDatePicker(
              value: _value,
              today: widget.today,
              requireDay: widget.requireDay,
              onChanged: (next) => setState(() => _value = next),
            )
          else
            MonthFirstDatePicker(
              value: _value,
              today: widget.today,
              onChanged: (next) => setState(() => _value = next),
            ),
          const SizedBox(height: 18),
          if (widget.failed && date != null) ...[
            saveFailureLine(() => widget.onSave(date)),
            const SizedBox(height: 8),
          ],
          if (wide)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (date?.day != null) ...[
                        Text(
                          DateFormat('EEEE, MMMM d', 'en_US')
                              .format(date!.day!),
                          style: context.webTokens
                              .style(16, weight: FontWeight.w600),
                        ),
                        Text(
                          '${date.daysUntil(widget.today)} days from today',
                          style: context.webTokens.sm,
                        ),
                      ],
                    ],
                  ),
                ),
                WebButton(
                  label: 'Cancel',
                  variant: WebButtonVariant.tertiary,
                  onPressed: widget.onCancel,
                ),
                const SizedBox(width: 8),
                WebButton(
                  label: 'Save',
                  keyHint: 'Enter',
                  busy: widget.saving,
                  onPressed: date == null || widget.saving
                      ? null
                      : () => widget.onSave(date),
                ),
              ],
            )
          else
            PantasButton(
              label: 'Save',
              busy: widget.saving,
              onPressed: date == null || widget.saving
                  ? null
                  : () => widget.onSave(date),
            ),
        ],
      ),
    );
    if (!wide) return content;
    return CallbackShortcuts(
      bindings: {
        if (date != null && !widget.saving)
          const SingleActivator(LogicalKeyboardKey.enter): () =>
              widget.onSave(date),
      },
      child: Focus(autofocus: true, child: content),
    );
  }
}

/// The same month-first value as the phone picker, laid out beside a calendar.
class HomeWebDatePicker extends StatelessWidget {
  const HomeWebDatePicker({
    required this.value,
    required this.today,
    required this.onChanged,
    this.requireDay = false,
    super.key,
  });
  final MonthFirstDate value;
  final DateTime today;
  final ValueChanged<MonthFirstDate> onChanged;
  final bool requireDay;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final month = value.month;
    final calendar = month == null
        ? const SizedBox.shrink()
        : Column(
            key: const ValueKey('home-web-calendar'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat('MMMM yyyy', 'en_US')
                          .format(DateTime(value.year, month)),
                      style: t.style(15, weight: FontWeight.w600),
                    ),
                  ),
                  if (!requireDay) Text('Optional', style: t.sm),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final day in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                    Expanded(child: Center(child: Text(day, style: t.sm))),
                ],
              ),
              const SizedBox(height: 6),
              for (var week = 0;
                  week <
                      (DateTime(value.year, month).weekday % 7 +
                              DateTime(value.year, month + 1, 0).day +
                              6) ~/
                          7;
                  week++)
                Row(
                  children: [
                    for (var weekday = 0; weekday < 7; weekday++)
                      Expanded(
                        child: _day(
                          context,
                          week * 7 +
                              weekday -
                              DateTime(value.year, month).weekday % 7 +
                              1,
                        ),
                      ),
                  ],
                ),
            ],
          );
    final months = SizedBox(
      key: const ValueKey('home-web-months'),
      width: 160,
      height: 230,
      child: ListView.builder(
        itemBuilder: (context, index) {
          final year = today.year + index;
          final first = year == today.year ? today.month : 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('$year', style: t.sm),
              ),
              for (var start = first; start <= 12; start += 3)
                Row(
                  children: [
                    for (var offset = 0; offset < 3; offset++)
                      Expanded(
                        child: start + offset > 12
                            ? const SizedBox.shrink()
                            : _month(context, year, start + offset),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (requireDay && month != null)
          calendar
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              months,
              const SizedBox(width: 20),
              Expanded(child: calendar),
            ],
          ),
      ],
    );
  }

  Widget _month(BuildContext context, int year, int month) {
    final t = context.webTokens;
    final selected = year == value.year && month == value.month;
    return TextButton(
      key: ValueKey(
        year == value.year ? 'date-month-$month' : 'date-month-$year-$month',
      ),
      onPressed: () => onChanged(MonthFirstDate(year: year, month: month)),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 40),
        backgroundColor: selected ? t.colors.accentFill : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        DateFormat('MMM', 'en_US').format(DateTime(year, month)),
        style: t.style(
          14,
          weight: FontWeight.w500,
          color: selected ? Colors.white : t.colors.label,
        ),
      ),
    );
  }

  Widget _day(BuildContext context, int day) {
    final month = value.month!;
    if (day < 1 || day > DateTime(value.year, month + 1, 0).day) {
      return const SizedBox(height: 36);
    }
    final date = DateTime(value.year, month, day);
    final past = date.isBefore(DateTime(today.year, today.month, today.day));
    final selected = day == value.day;
    final t = context.webTokens;
    return TextButton(
      key: ValueKey('date-day-$day'),
      onPressed: past
          ? null
          : () => onChanged(
                MonthFirstDate(year: value.year, month: month, day: day),
              ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 36),
        backgroundColor: selected ? t.colors.accentFill : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        '$day',
        style: t.style(
          14,
          weight: selected ? FontWeight.w600 : FontWeight.w400,
          color: past
              ? t.colors.tertiaryLabel
              : selected
                  ? Colors.white
                  : t.colors.label,
        ),
      ),
    );
  }
}
