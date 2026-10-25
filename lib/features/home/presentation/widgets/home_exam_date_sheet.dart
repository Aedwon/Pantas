import 'package:flutter/material.dart';
import 'package:pantas/core/error/state_patterns.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/month_first_date_picker.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// The exam date picker Home opens in a sheet (D-69): the same month-first
/// picker as onboarding. Save stays grey until a month is picked, or, when
/// [requireDay] is set for the month-only notice, until a day is.
class HomeExamDateSheet extends StatefulWidget {
  const HomeExamDateSheet({
    required this.today,
    required this.onSave,
    this.initial,
    this.requireDay = false,
    this.saving = false,
    this.failed = false,
    super.key,
  });
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'When is your exam?',
            style: context.type.emphasized.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pick the month. Add the day if you know it.',
            style: context.type.subhead
                .copyWith(color: context.colors.secondaryLabel),
          ),
          const SizedBox(height: 18),
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
  }
}
