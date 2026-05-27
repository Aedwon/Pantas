import 'notification_time.dart';

class StreakSavePolicy {
  const StreakSavePolicy();

  NotificationTime streakSaveTime(NotificationTime dailyReminderTime) {
    final dailyMinutes = dailyReminderTime.hour * 60 + dailyReminderTime.minute;
    final saveMinutes = dailyMinutes - 60;
    final cappedMinutes = saveMinutes > 20 * 60 ? 20 * 60 : saveMinutes;
    final normalized =
        cappedMinutes < 0 ? cappedMinutes + 24 * 60 : cappedMinutes;
    return NotificationTime(
      hour: normalized ~/ 60,
      minute: normalized % 60,
    );
  }

  bool shouldSchedule({
    required int streakLength,
    required bool completedToday,
    required DateTime now,
    required DateTime fireAt,
  }) {
    if (streakLength < 1) return false;
    if (completedToday) return false;
    return now.isBefore(fireAt);
  }
}
