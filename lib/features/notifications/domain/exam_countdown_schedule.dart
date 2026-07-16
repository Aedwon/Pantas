import 'package:cse_cet_reviewer/core/storage/domain/exam_date.dart';

/// The fixed ladder. Seven notifications across the whole run-up and
/// never two in one day.
const countdownDays = [30, 14, 7, 3, 2, 1, 0];

abstract final class ExamCountdownSchedule {
  /// Empty at month precision. `ExamDate.day` returns null there and
  /// deriving a day from a month is a figure this project inferred.
  static List<DateTime> fireDates(ExamDate date, {required DateTime from}) {
    final examDay = date.day;
    if (examDay == null) return const [];

    final normalizedExam = DateTime(examDay.year, examDay.month, examDay.day);
    final normalizedFrom = DateTime(from.year, from.month, from.day);

    if (normalizedExam.isBefore(normalizedFrom)) {
      return const [];
    }

    final dates = <DateTime>[];
    for (final days in countdownDays) {
      final fireDate = DateTime(
        normalizedExam.year,
        normalizedExam.month,
        normalizedExam.day - days,
      );
      if (!fireDate.isBefore(normalizedFrom)) {
        dates.add(fireDate);
      }
    }

    return dates;
  }
}
