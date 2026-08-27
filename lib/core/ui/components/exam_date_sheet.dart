import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/ink_sheet.dart';
import 'package:pantas/core/ui/components/ink_wheel.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

const List<String> _monthLabels = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

sealed class ExamDateSheetResult {
  const ExamDateSheetResult();
  const factory ExamDateSheetResult.chosen(ExamDate date) = ExamDateChosen;
  const factory ExamDateSheetResult.cleared() = ExamDateCleared;
}

@immutable
class ExamDateChosen extends ExamDateSheetResult {
  const ExamDateChosen(this.date);
  final ExamDate date;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamDateChosen &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}

@immutable
class ExamDateCleared extends ExamDateSheetResult {
  const ExamDateCleared();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamDateCleared && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

/// Returns the chosen date, or [ExamDateSheetResult.cleared] when the student
/// answers "I don't know yet", or null when the sheet is dismissed.
Future<ExamDateSheetResult?> showExamDateSheet({
  required BuildContext context,
  required ExamDate? current,
  required DateTime today,
}) {
  return showInkSheet<ExamDateSheetResult>(
    context: context,
    builder: (sheetContext) {
      return _ExamDateSheetBody(current: current, today: today);
    },
  );
}

class _ExamDateSheetBody extends StatefulWidget {
  const _ExamDateSheetBody({
    required this.current,
    required this.today,
  });

  final ExamDate? current;
  final DateTime today;

  @override
  State<_ExamDateSheetBody> createState() => _ExamDateSheetBodyState();
}

class _ExamDateSheetBodyState extends State<_ExamDateSheetBody> {
  late final List<DateTime> _months;
  late int _monthIndex;
  late int _dayIndex;

  @override
  void initState() {
    super.initState();
    _months = List.generate(
      36,
      (i) => DateTime(widget.today.year, widget.today.month + i),
    );

    final current = widget.current;
    if (current == null) {
      _monthIndex = 0;
      _dayIndex = 0;
    } else {
      final offset = (current.year - widget.today.year) * 12 +
          (current.month - widget.today.month);
      _monthIndex = offset.clamp(0, _months.length - 1);

      final days = _computeActualDays(_monthIndex);
      final exactDay = current.day;
      if (exactDay == null) {
        _dayIndex = 0;
      } else {
        final idx = days.indexOf(exactDay.day);
        _dayIndex = idx >= 0 ? idx + 1 : 0;
      }
    }
  }

  List<int> _computeActualDays(int monthIndex) {
    final monthDate = _months[monthIndex];
    final daysInMonth =
        DateUtils.getDaysInMonth(monthDate.year, monthDate.month);
    final isCurrentMonth = monthDate.year == widget.today.year &&
        monthDate.month == widget.today.month;

    final startDay = isCurrentMonth ? widget.today.day + 1 : 1;
    if (startDay > daysInMonth) return const [];
    return List.generate(daysInMonth - startDay + 1, (i) => startDay + i);
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    final actualDays = _computeActualDays(_monthIndex);
    final dayValues = ['-', ...actualDays.map((d) => '$d')];

    // Ensure day index remains in bounds
    if (_dayIndex >= dayValues.length) {
      _dayIndex = dayValues.length - 1;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exam date',
          style: styles.headlineSmall.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          'Leave the day on the dash if you only know the month.',
          style: styles.bodySmall.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: InkWheel.itemHeight * InkWheel.visibleItems,
          child: Stack(
            children: [
              const InkWheelBand(),
              Row(
                children: [
                  Expanded(
                    child: InkWheel<String>(
                      key: ValueKey('day_wheel_$_monthIndex'),
                      values: dayValues,
                      selectedIndex: _dayIndex,
                      semanticLabel: 'Day',
                      semanticValueBuilder: (value) =>
                          value == '-' ? 'Month only' : value,
                      onSelected: (index) {
                        setState(() => _dayIndex = index);
                      },
                      labelBuilder: (v) => v,
                    ),
                  ),
                  Expanded(
                    child: InkWheel<DateTime>(
                      values: _months,
                      selectedIndex: _monthIndex,
                      semanticLabel: 'Month',
                      semanticValueBuilder: (value) =>
                          _monthLabels[value.month - 1],
                      onSelected: (index) {
                        setState(() {
                          _monthIndex = index;
                          final newActualDays = _computeActualDays(index);
                          if (_dayIndex > newActualDays.length) {
                            _dayIndex = newActualDays.length;
                          }
                        });
                      },
                      labelBuilder: (m) => _monthLabels[m.month - 1],
                    ),
                  ),
                  Expanded(
                    child: InkWheel<DateTime>(
                      values: _months,
                      selectedIndex: _monthIndex,
                      semanticLabel: 'Year',
                      semanticValueBuilder: (value) => '${value.year}',
                      onSelected: (index) {
                        setState(() {
                          _monthIndex = index;
                          final newActualDays = _computeActualDays(index);
                          if (_dayIndex > newActualDays.length) {
                            _dayIndex = newActualDays.length;
                          }
                        });
                      },
                      labelBuilder: (m) => '${m.year}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        BoardButton(
          label: 'Save',
          onPressed: () {
            final monthDate = _months[_monthIndex];
            final ExamDate date;
            if (_dayIndex == 0) {
              date = ExamDate.inMonth(
                year: monthDate.year,
                month: monthDate.month,
              );
            } else {
              final dayVal = actualDays[_dayIndex - 1];
              date = ExamDate.onDay(
                DateTime(monthDate.year, monthDate.month, dayVal),
              );
            }
            Navigator.of(context).pop(ExamDateSheetResult.chosen(date));
          },
        ),
        BoardButton(
          label: "I don't know yet",
          secondary: true,
          onPressed: () {
            Navigator.of(context).pop(const ExamDateSheetResult.cleared());
          },
        ),
      ],
    );
  }
}
