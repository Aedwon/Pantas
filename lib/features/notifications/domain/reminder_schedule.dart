import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/time/study_days.dart';

abstract final class NotificationIds {
  static const dailyReminder = 9001;
  static const streakSave = 9002;
  static const examCountdown = 9003;
  static const comeBack = 9004;
}

class ReminderSchedulerClock {
  const ReminderSchedulerClock();

  DateTime nextOccurrence({
    required DateTime now,
    required NotificationTime time,
    StudyDays studyDays = StudyDays.all,
  }) {
    final today =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (today.isAfter(now) && studyDays.isStudyDay(today)) return today;
    final next = studyDays.nextAfter(now)!;
    return DateTime(next.year, next.month, next.day, time.hour, time.minute);
  }
}
