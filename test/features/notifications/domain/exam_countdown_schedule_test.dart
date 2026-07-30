import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/features/notifications/domain/exam_countdown_schedule.dart';
import 'package:pantas/features/notifications/domain/notification_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExamCountdownSchedule', () {
    test('NotificationKind contains examCountdown', () {
      expect(NotificationKind.examCountdown.storageValue, 'exam_countdown');
      expect(
        NotificationKind.fromStorage('exam_countdown'),
        NotificationKind.examCountdown,
      );
    });

    test('a day-precision date 45 days out yields all seven dates', () {
      final examDate = ExamDate.onDay(DateTime(2026, 9, 15));
      final from = DateTime(2026, 8); // 45 days out

      final dates = ExamCountdownSchedule.fireDates(examDate, from: from);

      expect(dates.length, 7);
      expect(dates[0], DateTime(2026, 8, 16)); // 30 days before Sept 15
      expect(dates[1], DateTime(2026, 9)); // 14 days before Sept 15
      expect(dates[2], DateTime(2026, 9, 8)); // 7 days before Sept 15
      expect(dates[3], DateTime(2026, 9, 12)); // 3 days before Sept 15
      expect(dates[4], DateTime(2026, 9, 13)); // 2 days before Sept 15
      expect(dates[5], DateTime(2026, 9, 14)); // 1 day before Sept 15
      expect(dates[6], DateTime(2026, 9, 15)); // 0 days (day of)
    });

    test('a date 5 days out yields only 3, 2, 1 and 0 days', () {
      final examDate = ExamDate.onDay(DateTime(2026, 9, 15));
      final from = DateTime(2026, 9, 10); // 5 days out

      final dates = ExamCountdownSchedule.fireDates(examDate, from: from);

      expect(dates.length, 4);
      expect(dates[0], DateTime(2026, 9, 12)); // 3 days before
      expect(dates[1], DateTime(2026, 9, 13)); // 2 days before
      expect(dates[2], DateTime(2026, 9, 14)); // 1 day before
      expect(dates[3], DateTime(2026, 9, 15)); // day of
    });

    test('a month-precision date yields an empty list', () {
      final examDate = ExamDate.inMonth(year: 2026, month: 9);
      final from = DateTime(2026, 8);

      final dates = ExamCountdownSchedule.fireDates(examDate, from: from);

      expect(dates, isEmpty);
    });

    test('a past date yields an empty list', () {
      final examDate = ExamDate.onDay(DateTime(2026, 8));
      final from = DateTime(2026, 8, 10); // past date

      final dates = ExamCountdownSchedule.fireDates(examDate, from: from);

      expect(dates, isEmpty);
    });

    test('two ladder entries never land on the same day', () {
      final examDate = ExamDate.onDay(DateTime(2026, 9, 15));
      final from = DateTime(2026, 8);

      final dates = ExamCountdownSchedule.fireDates(examDate, from: from);

      final uniqueDates =
          dates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
      expect(uniqueDates.length, dates.length);
    });
  });
}
