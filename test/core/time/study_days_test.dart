import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/study_days.dart';

void main() {
  test('long calendar counts use complete weeks without scanning every date',
      () {
    final clock = Stopwatch()..start();
    final days = StudyDays(const [1, 3, 5]);
    final count = days.countInRange(DateTime(2000, 1, 3), DateTime(2400, 1, 3));
    expect(count, 62613);
    expect(clock.elapsed, lessThan(const Duration(seconds: 2)));
  });

  test('all weekday combinations keep calendar range counts', () {
    for (var mask = 1; mask < 128; mask++) {
      final days = StudyDays([
        for (var day = 1; day <= 7; day++)
          if (mask & (1 << (day - 1)) != 0) day,
      ]);
      for (var offset = 0; offset < 7; offset++) {
        final start = DateTime(2026, 12, 28 + offset);
        for (final length in [-1, 0, 1, 6, 7, 8, 29]) {
          final end = DateTime(start.year, start.month, start.day + length);
          var expected = 0;
          for (var day = start;
              day.isBefore(end);
              day = DateTime(day.year, day.month, day.day + 1)) {
            if (days.isStudyDay(day)) expected++;
          }
          expect(
            days.countInRange(start, end),
            expected,
            reason: 'mask=$mask start=$start length=$length',
          );
        }
      }
    }
  });

  final weekdays = StudyDays(const [1, 2, 3, 4, 5]);

  test('constructor rejects empty and out-of-range weekdays', () {
    expect(() => StudyDays(const []), throwsArgumentError);
    expect(() => StudyDays(const [0]), throwsArgumentError);
    expect(() => StudyDays(const [1, 8]), throwsArgumentError);
  });

  test('storage defaults invalid or absent values to every day', () {
    for (final raw in [null, '', '9', 'x', '1,x', '1,,3', '0', ' ']) {
      expect(StudyDays.fromStorage(raw), StudyDays.all, reason: '$raw');
    }
    expect(StudyDays.all.weekdays, {1, 2, 3, 4, 5, 6, 7});
    expect(StudyDays.all.isEveryDay, isTrue);
    expect(weekdays.isEveryDay, isFalse);
  });

  test('storage sorts and deduplicates weekdays', () {
    expect(StudyDays.fromStorage('1,3').weekdays, {1, 3});
    expect(StudyDays.fromStorage('3,1,3').storageValue, '1,3');
    expect(StudyDays(const [5, 2, 1, 2]).storageValue, '1,2,5');
    expect(StudyDays.all.storageValue, '1,2,3,4,5,6,7');
  });

  test('weekdays are immutable and detached from the constructor input', () {
    final input = <int>{1, 3};
    final days = StudyDays(input);
    input.add(5);
    expect(days.weekdays, {1, 3});
    expect(() => days.weekdays.add(5), throwsUnsupportedError);
    expect(() => days.weekdays.clear(), throwsUnsupportedError);
  });

  test('equality and hash ignore order and duplicates', () {
    final first = StudyDays(const [3, 1, 3]);
    final second = StudyDays(const [1, 3]);
    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(first, isNot(StudyDays(const [1, 5])));
    expect(<StudyDays>{first, second}, hasLength(1));
    expect(StudyDays(const [7, 6, 5, 4, 3, 2, 1]), StudyDays.all);
  });

  test('study day follows the ISO weekday', () {
    expect(weekdays.isStudyDay(DateTime(2026, 10, 2, 23)), isTrue);
    expect(weekdays.isStudyDay(DateTime(2026, 10, 3)), isFalse);
    expect(StudyDays(const [7]).isStudyDay(DateTime(2026, 10, 4)), isTrue);
  });

  test('worked range has 48 study days and 43 before review only', () {
    final start = DateTime(2026, 9, 30);
    for (final end in [DateTime(2026, 12, 7), DateTime(2026, 11, 30)]) {
      var expected = 0;
      for (var day = start;
          day.isBefore(end);
          day = DateTime(day.year, day.month, day.day + 1)) {
        if (day.weekday <= DateTime.friday) expected++;
      }
      expect(expected, end.month == 12 ? 48 : 43);
      expect(weekdays.countInRange(start, end), expected);
    }
  });

  test('ranges include the start date and exclude the end date', () {
    expect(
      weekdays.countInRange(DateTime(2026, 10, 2), DateTime(2026, 10, 5)),
      1,
    );
    expect(
      weekdays.countInRange(
        DateTime(2026, 10, 2, 23),
        DateTime(2026, 10, 5, 12),
      ),
      1,
    );
    expect(
      weekdays.countInRange(DateTime(2026, 10, 5), DateTime(2026, 10, 5)),
      0,
    );
    expect(
      weekdays.countInRange(DateTime(2026, 10, 5), DateTime(2026, 10, 2)),
      0,
    );
  });

  test('calendar counting spans daylight-saving dates and year end', () {
    expect(
      StudyDays.all.countInRange(DateTime(2026, 3, 7), DateTime(2026, 3, 10)),
      3,
    );
    expect(
      weekdays.countInRange(DateTime(2026, 12, 30), DateTime(2027, 1, 5)),
      4,
    );
    expect(
      StudyDays.all.countInRange(DateTime(2026, 12, 30), DateTime(2027, 1, 5)),
      6,
    );
  });

  test('next study day skips rest days and respects an exclusive limit', () {
    final friday = DateTime(2026, 10, 2, 18);
    final monday = DateTime(2026, 10, 5);
    expect(weekdays.nextAfter(friday), monday);
    expect(weekdays.nextAfter(friday, before: monday), isNull);
    expect(
      weekdays.nextAfter(friday, before: DateTime(2026, 10, 6)),
      monday,
    );
    expect(weekdays.nextAfter(friday, before: friday), isNull);
    expect(StudyDays.all.nextAfter(friday), DateTime(2026, 10, 3));
    expect(StudyDays(const [5]).nextAfter(friday), DateTime(2026, 10, 9));
    expect(weekdays.nextAfter(DateTime(2026, 12, 31)), DateTime(2027));
  });

  test('missed study days exclude both activity dates', () {
    expect(
      weekdays.missedBetween(DateTime(2026, 10, 2), DateTime(2026, 10, 5)),
      0,
    );
    expect(
      weekdays.missedBetween(DateTime(2026, 10, 5), DateTime(2026, 10, 7)),
      1,
    );
    expect(
      weekdays.missedBetween(DateTime(2026, 10, 5), DateTime(2026, 10, 5)),
      0,
    );
    expect(
      weekdays.missedBetween(DateTime(2026, 10, 7), DateTime(2026, 10, 5)),
      0,
    );
    expect(
      weekdays.missedBetween(DateTime(2026, 12, 30), DateTime(2027, 1, 5)),
      3,
    );
    expect(
      weekdays.missedBetween(DateTime(2026, 10, 3), DateTime(2026, 10, 5)),
      0,
    );
  });
}
