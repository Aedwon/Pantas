import 'package:cse_cet_reviewer/features/notifications/domain/notification_time.dart';

abstract final class NotificationIds {
  static const dailyReminder = 9001;
  static const streakSave = 9002;
}

class ReminderSchedulerClock {
  const ReminderSchedulerClock();

  DateTime nextOccurrence({
    required DateTime now,
    required NotificationTime time,
  }) {
    final today =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (today.isAfter(now)) return today;
    return today.add(const Duration(days: 1));
  }
}
