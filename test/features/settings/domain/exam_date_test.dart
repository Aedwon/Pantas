import 'package:cse_cet_reviewer/core/storage/domain/exam_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a day-precision date exposes its day', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12));

    expect(date.precision, ExamDatePrecision.day);
    expect(date.day, DateTime(2026, 10, 12));
    expect(date.monthStart, DateTime(2026, 10));
    expect(date.year, 2026);
    expect(date.month, 10);
    expect(date.storageValue, '2026-10-12');
  });

  test('a month-precision date refuses to hand out a day', () {
    final date = ExamDate.inMonth(year: 2026, month: 10);

    expect(date.precision, ExamDatePrecision.month);
    expect(date.day, isNull);
    expect(date.monthStart, DateTime(2026, 10));
    expect(date.year, 2026);
    expect(date.month, 10);
    expect(date.storageValue, '2026-10-01');
  });

  test('a day-precision date counts whole days', () {
    final date = ExamDate.onDay(DateTime(2026, 10, 12));

    expect(date.daysUntil(DateTime(2026, 9, 30)), 12);
    expect(date.daysUntil(DateTime(2026, 10, 12)), 0);
  });

  test('a month-precision date never counts days', () {
    final date = ExamDate.inMonth(year: 2026, month: 10);

    expect(date.daysUntil(DateTime(2026, 9, 30)), isNull);
  });

  test('storage round trips at both precisions', () {
    final day = ExamDate.fromStorage('2026-10-12', 'day');
    expect(day!.day, DateTime(2026, 10, 12));

    final month = ExamDate.fromStorage('2026-10-01', 'month');
    expect(month!.day, isNull);
    expect(month.monthStart, DateTime(2026, 10));
  });

  test('an absent precision means no date at all, even with a date string', () {
    expect(ExamDate.fromStorage('2026-10-12', null), isNull);
    expect(ExamDate.fromStorage(null, 'day'), isNull);
    expect(ExamDate.fromStorage('nonsense', 'day'), isNull);
    expect(ExamDate.fromStorage('2026-10-12', 'nonsense'), isNull);
  });

  test('two dates of the same precision and value are equal', () {
    expect(
      ExamDate.onDay(DateTime(2026, 10, 12)),
      ExamDate.onDay(DateTime(2026, 10, 12)),
    );
    expect(
      ExamDate.inMonth(year: 2026, month: 10),
      isNot(ExamDate.onDay(DateTime(2026, 10))),
    );
  });
}
