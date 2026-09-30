import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/local_day.dart';

void main() {
  test('localDay strips every time component', () {
    final day = localDay(DateTime(2026, 9, 30, 23, 59, 58, 123, 456));

    expect(day, DateTime(2026, 9, 30));
    expect(day.isUtc, isFalse);
  });

  test('localDay uses the supplied calendar fields and returns a local day',
      () {
    final day = localDay(DateTime.utc(2026, 9, 30, 23, 59));

    expect(day, DateTime(2026, 9, 30));
    expect(day.isUtc, isFalse);
  });

  test('localDaysBetween ignores time within the same calendar day', () {
    expect(
      localDaysBetween(
        DateTime(2026, 9, 30, 23, 59),
        DateTime(2026, 9, 30, 1),
      ),
      0,
    );
  });

  test('localDaysBetween counts calendar days across spring DST', () {
    final from = DateTime(2026, 3, 8);
    final to = DateTime(2026, 3, 9);
    if (Platform.environment['TZ'] == 'America/New_York') {
      expect(to.difference(from).inHours, 23);
      expect(from.timeZoneOffset, const Duration(hours: -5));
      expect(to.timeZoneOffset, const Duration(hours: -4));
    }

    expect(localDaysBetween(from, to), 1);
    expect(localDaysBetween(to, from), -1);
    expect(localDaysBetween(DateTime(2026, 3, 7), to), 2);
  });

  test('localDaysBetween counts calendar days across fall DST', () {
    final from = DateTime(2026, 11);
    final to = DateTime(2026, 11, 2);
    if (Platform.environment['TZ'] == 'America/New_York') {
      expect(to.difference(from).inHours, 25);
      expect(from.timeZoneOffset, const Duration(hours: -4));
      expect(to.timeZoneOffset, const Duration(hours: -5));
    }

    expect(localDaysBetween(from, to), 1);
    expect(localDaysBetween(to, from), -1);
  });

  test('localDaysBetween counts across month and year boundaries', () {
    expect(
      localDaysBetween(DateTime(2026, 12, 31, 23), DateTime(2027, 1, 2, 1)),
      2,
    );
  });
}
