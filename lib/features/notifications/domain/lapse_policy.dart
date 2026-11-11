import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/time/study_days.dart';

class LapsePolicy {
  const LapsePolicy();

  /// Fired on the third missed study day, once, then silence
  /// until they return.
  bool shouldSchedule({
    required DateTime? lastSessionAt,
    required DateTime now,
    StudyDays studyDays = StudyDays.all,
  }) {
    if (!studyDays.isStudyDay(now)) return false;
    if (lastSessionAt == null) return false;

    final lastSessionDay = DateTime(
      lastSessionAt.year,
      lastSessionAt.month,
      lastSessionAt.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    final quietDays = studyDays.countInRange(
      DateTime(
        lastSessionDay.year,
        lastSessionDay.month,
        lastSessionDay.day + 1,
      ),
      DateTime(today.year, today.month, today.day + 1),
    );
    return quietDays == 3;
  }

  DateTime? scheduledTime({
    required DateTime? lastSessionAt,
    required NotificationTime reminderTime,
    required DateTime now,
    StudyDays studyDays = StudyDays.all,
  }) {
    if (!shouldSchedule(
      lastSessionAt: lastSessionAt,
      now: now,
      studyDays: studyDays,
    )) {
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
