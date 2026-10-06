import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/pantas_dates.dart';

void main() {
  final now = DateTime(2026, 10, 7);

  test('full uses the approved American month-day-year format', () {
    expect(PantasDates.full(DateTime(2026, 11, 11)), 'Nov 11, 2026');
  });
  test('short omits only the current year', () {
    expect(PantasDates.short(DateTime(2026, 10, 17), now: now), 'Oct 17');
    expect(PantasDates.short(DateTime(2027, 10, 17), now: now), 'Oct 17, 2027');
  });
  test('weekday and heading use their approved forms', () {
    expect(PantasDates.withWeekday(DateTime(2026, 10, 17)), 'Sat, Oct 17');
    expect(PantasDates.heading(DateTime(2026, 10, 3)), 'Saturday, October 3');
  });
  test('monthOnly includes the full month and year', () {
    expect(PantasDates.monthOnly(DateTime(2026, 11)), 'November 2026');
  });
  test('a week within a month abbreviates its second date', () {
    expect(PantasDates.weekRange(DateTime(2026, 10, 4)), 'Oct 4 – 10');
  });
  test('a week across months names both months', () {
    expect(PantasDates.weekRange(DateTime(2026, 9, 27)), 'Sep 27 – Oct 3');
  });
  test('a week across years names both years', () {
    expect(
      PantasDates.weekRange(DateTime(2026, 12, 27)),
      'Dec 27, 2026 – Jan 2, 2027',
    );
  });
  test('relativeDay distinguishes today, yesterday and earlier dates', () {
    expect(
      PantasDates.relativeDay(DateTime(2026, 10, 7, 23), now: now),
      'Today',
    );
    expect(
      PantasDates.relativeDay(DateTime(2026, 10, 6), now: now),
      'Yesterday',
    );
    expect(PantasDates.relativeDay(DateTime(2026, 10, 5), now: now), 'Oct 5');
    expect(
      PantasDates.relativeDay(DateTime(2025, 10, 5), now: now),
      'Oct 5, 2025',
    );
    expect(
      PantasDates.relativeDay(DateTime(2025, 12, 31), now: DateTime(2026, 1)),
      'Yesterday',
    );
  });
  for (var weekday = 0; weekday < 7; weekday++) {
    test('weekStart is Sunday for weekday offset $weekday', () {
      expect(
        PantasDates.weekStart(DateTime(2026, 10, 4 + weekday, 23)),
        DateTime(2026, 10, 4),
      );
    });
  }
  test('weekStart handles year boundaries and UTC dates', () {
    expect(PantasDates.weekStart(DateTime(2026, 1, 1)), DateTime(2025, 12, 28));
    expect(
      PantasDates.weekStart(DateTime.utc(2026, 10, 10)),
      DateTime.utc(2026, 10, 4),
    );
  });
}
