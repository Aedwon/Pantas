import 'package:meta/meta.dart';
import 'package:pantas/core/notifications/notification_service.dart';

/// Shared by onboarding and Settings. Switching daily off preserves both times.
@immutable
class ReminderPrefs {
  const ReminderPrefs({
    required this.dailyEnabled,
    required this.followUpEnabled,
    required this.countdownEnabled,
    this.dailyTime = const NotificationTime(hour: 19, minute: 0),
    this.followUpTime = const NotificationTime(hour: 21, minute: 0),
  });

  final bool dailyEnabled;
  final NotificationTime dailyTime;
  final bool followUpEnabled;
  final NotificationTime followUpTime;
  final bool countdownEnabled;

  bool get followUpAfterDaily =>
      followUpTime.hour * 60 + followUpTime.minute >
      dailyTime.hour * 60 + dailyTime.minute;
}
