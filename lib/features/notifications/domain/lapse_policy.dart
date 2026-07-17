import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';

class LapsePolicy {
  const LapsePolicy();

  /// Fired after three consecutive days with no session, once, then silence
  /// until they return.
  bool shouldSchedule({
    required DateTime? lastSessionAt,
    required DateTime now,
  }) {
    if (lastSessionAt == null) return false;

    final lastSessionDay = DateTime(
      lastSessionAt.year,
      lastSessionAt.month,
      lastSessionAt.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    final quietDays = today.difference(lastSessionDay).inDays;
    return quietDays == 3;
  }

  DateTime? scheduledTime({
    required DateTime? lastSessionAt,
    required NotificationTime reminderTime,
    required DateTime now,
  }) {
    if (!shouldSchedule(lastSessionAt: lastSessionAt, now: now)) {
      return null;
    }
    return DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );
  }
}
