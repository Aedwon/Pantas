import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a day-precision date exposes its day', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12));

    expect(date.precision, ExamDatePrecision.day);
    expect(date.day, DateTime(2026, 10, 12));
    expect(date.year, 2026);
    expect(date.month, 10);
  });

  test('a month-precision date refuses to hand over a day', () {
    final date = ExamDate.inMonth(year: 2026, month: 10);

    expect(date.precision, ExamDatePrecision.month);
    expect(date.day, isNull);
    expect(date.year, 2026);
    expect(date.month, 10);
  });

  test(
    'monthStart returns the first of the month for day/month precision',
    () {
      final dayDate = ExamDate.onDay(DateTime(2026, 10, 12));
      final monthDate = ExamDate.inMonth(year: 2026, month: 10);

      expect(dayDate.monthStart, DateTime(2026, 10));
      expect(monthDate.monthStart, DateTime(2026, 10));
    },
  );

  test('a day-precision date counts whole days', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12));

    expect(date.daysUntil(DateTime(2026, 9, 30)), 12);
    expect(date.daysUntil(DateTime(2026, 10, 12)), 0);
  });

  test('a month-precision date never counts days', () {
    final date = ExamDate.inMonth(year: 2026, month: 10);

    expect(date.daysUntil(DateTime(2026, 9, 30)), isNull);
  });

  test('the time of day never affects the count', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12, 23, 59));

    expect(date.daysUntil(DateTime(2026, 10, 11, 0, 1)), 1);
  });

  test('a day-precision date round-trips through storage', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12));

    expect(date.storageValue, '2026-10-12');
    expect(
      ExamDate.fromStorage(date.storageValue, date.precision.name),
      date,
    );
  });

  test('a month-precision date stores the first of the month', () {
    final date = ExamDate.inMonth(year: 2026, month: 10);

    expect(date.storageValue, '2026-10-01');

    final parsed = ExamDate.fromStorage(date.storageValue, 'month');
    expect(parsed, date);
    expect(parsed!.day, isNull);
  });

  test('a missing or unreadable value is no date at all', () {
    expect(ExamDate.fromStorage(null, 'day'), isNull);
    expect(ExamDate.fromStorage('2026-10-12', null), isNull);
    expect(ExamDate.fromStorage('nonsense', 'day'), isNull);
    expect(ExamDate.fromStorage('2026-10-12', 'sideways'), isNull);
  });
}
