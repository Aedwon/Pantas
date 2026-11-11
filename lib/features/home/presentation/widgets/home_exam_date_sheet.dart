import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_tap_area.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
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
    this.examName,
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

  /// Names the exam in the day question (board HM_MonthOnlyPick).
  final String? examName;
  final bool saving;
  final bool failed;
  final ValueChanged<ExamDate> onSave;

  @override
  State<HomeExamDateSheet> createState() => _HomeExamDateSheetState();
}

class _HomeExamDateSheetState extends State<HomeExamDateSheet> {
  late MonthFirstDate _value = _from(widget.initial);

  /// The phone field holds text that is not a valid date.
  bool _unresolved = false;

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
          ? const EdgeInsets.all(PantasSpace.s24)
          : const EdgeInsets.fromLTRB(
              PantasSpace.s20,
              PantasSpace.s8,
              PantasSpace.s20,
              PantasSpace.s32,
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            wide && widget.requireDay
                ? 'Which day is your ${widget.examName ?? 'exam'}?'
                : 'When is your exam?',
            style: wide
                ? context.webTokens.h3
                : PantasType.phoneTitle2
                    .copyWith(color: context.colors.textPrimary),
          ),
          SizedBox(height: wide ? PantasSpace.s0 : PantasSpace.s4),
          Text(
            wide && widget.requireDay
                ? 'Pick a day in $monthLabel.'
                : 'Pick the month. Add the day if you know it.',
            style: wide
                ? context.webTokens.sub
                : context.type.subhead
                    .copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: PantasSpace.s18),
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
              onUnresolvedChanged: (unresolved) =>
                  setState(() => _unresolved = unresolved),
              onChanged: (next) => setState(() => _value = next),
            ),
          const SizedBox(height: PantasSpace.s18),
          if (widget.failed && date != null) ...[
            saveFailureLine(() => widget.onSave(date)),
            const SizedBox(height: PantasSpace.s8),
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
                          switch (date.daysUntil(widget.today)) {
                            1 => '1 day from today',
                            final days => '$days days from today',
                          },
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
                const SizedBox(width: PantasSpace.s8),
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
              onPressed: date == null || widget.saving || _unresolved
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
          const SingleActivator(
            LogicalKeyboardKey.enter,
            includeRepeats: false,
          ): () => widget.onSave(date),
      },
      child: Focus(autofocus: true, child: content),
    );
  }
}

/// The same month-first value as the phone picker, laid out beside a calendar.
/// Sizes follow the web date boards: a 160 px month column of 77 by 38 tiles
/// in two columns beside a 14 px padded calendar panel with 42 by 32 day cells.
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

  static const _panelHeight = 259.0;

  @override
  Widget build(BuildContext context) {
    final t = context.webTokens;
    final month = value.month;
    final weeks = month == null
        ? 0
        : (DateTime(value.year, month).weekday % 7 +
                DateTime(value.year, month + 1, 0).day +
                6) ~/
            7;
    final calendar = month == null
        ? const SizedBox.shrink()
        : Container(
            key: const ValueKey('home-web-calendar'),
            height: requireDay ? null : _panelHeight,
            padding: const EdgeInsets.all(PantasSpace.s14),
            decoration: BoxDecoration(
              color: t.colors.bgPage,
              borderRadius: BorderRadius.circular(PantasRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy', 'en_US')
                            .format(DateTime(value.year, month)),
                        style: PantasType.webTitleSm.copyWith(
                          fontWeight: FontWeight.w700,
                          color: t.colors.textPrimary,
                        ),
                      ),
                    ),
                    if (!requireDay) Text('Optional', style: t.sm),
                  ],
                ),
                const SizedBox(height: PantasSpace.s8),
                Row(
                  children: [
                    for (var i = 0; i < 7; i++) ...[
                      if (i > 0) const SizedBox(width: PantasSpace.s2),
                      Expanded(
                        child: Center(
                          child: Text(
                            'SMTWTFS'[i],
                            style: PantasType.webKeyHintSm.copyWith(
                              color: t.colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: PantasSpace.s4),
                for (var week = 0; week < weeks; week++) ...[
                  if (week > 0) const SizedBox(height: PantasSpace.s2),
                  Row(
                    children: [
                      for (var weekday = 0; weekday < 7; weekday++) ...[
                        if (weekday > 0) const SizedBox(width: PantasSpace.s2),
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
                    ],
                  ),
                ],
              ],
            ),
          );
    final months = SizedBox(
      key: const ValueKey('home-web-months'),
      width: PantasSpace.s56 * 2 + PantasSpace.s44 + PantasSpace.s4,
      height: _panelHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final year = today.year + index;
                final first = year == today.year ? today.month : 1;
                final gap = index == 0 ? PantasSpace.s0 : PantasSpace.s16;
                return Padding(
                  padding: EdgeInsets.only(top: gap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '$year',
                        style: PantasType.webChipName
                            .copyWith(color: t.colors.textSecondary),
                      ),
                      const SizedBox(height: PantasSpace.s8),
                      for (var start = first; start <= 12; start += 2) ...[
                        if (start > first)
                          const SizedBox(height: PantasSpace.s6),
                        Row(
                          children: [
                            Expanded(child: _month(context, year, start)),
                            const SizedBox(width: PantasSpace.s6),
                            Expanded(
                              child: start + 1 > 12
                                  ? const SizedBox.shrink()
                                  : _month(context, year, start + 1),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Text('Scroll for more', style: t.sm),
        ],
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
              const SizedBox(width: PantasSpace.s14),
              Expanded(child: calendar),
            ],
          ),
      ],
    );
  }

  Widget _month(BuildContext context, int year, int month) {
    final t = context.webTokens;
    final selected = year == value.year && month == value.month;
    return SizedBox(
      height: PantasSpace.s32 + PantasSpace.s6,
      child: Semantics(
        selected: selected,
        child: PantasTapArea(
          key: ValueKey(
            year == value.year
                ? 'date-month-$month'
                : 'date-month-$year-$month',
          ),
          onTap: () => onChanged(MonthFirstDate(year: year, month: month)),
          borderRadius: BorderRadius.circular(PantasRadius.md),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? t.colors.accentFill : t.colors.surfaceCard,
              borderRadius: BorderRadius.circular(PantasRadius.md),
              border: selected ? null : Border.all(color: t.cardEdge),
            ),
            child: Center(
              child: Text(
                DateFormat('MMM', 'en_US').format(DateTime(year, month)),
                style: PantasType.webTitleSm.copyWith(
                  color: selected ? t.colors.onAccent : t.colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _day(BuildContext context, int day) {
    final month = value.month!;
    if (day < 1 || day > DateTime(value.year, month + 1, 0).day) {
      return const SizedBox(height: PantasSpace.s32);
    }
    final date = DateTime(value.year, month, day);
    final past = date.isBefore(DateTime(today.year, today.month, today.day));
    final selected = day == value.day;
    final t = context.webTokens;
    return SizedBox(
      height: PantasSpace.s32,
      child: Semantics(
        selected: selected,
        child: PantasTapArea(
          key: ValueKey('date-day-$day'),
          onTap: past
              ? null
              : () => onChanged(
                    MonthFirstDate(year: value.year, month: month, day: day),
                  ),
          borderRadius: BorderRadius.circular(selected ? 99 : 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected ? t.colors.accentFill : Colors.transparent,
              borderRadius: BorderRadius.circular(selected ? 99 : 8),
            ),
            child: Center(
              child: Text(
                '$day',
                style: PantasType.webRowSub.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: past
                      ? t.colors.textSecondary
                      : selected
                          ? t.colors.onAccent
                          : t.colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
