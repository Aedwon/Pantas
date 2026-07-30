import 'package:pantas/features/notifications/domain/notification_payload.dart';

/// One notification per day. When two are eligible the order is fixed
/// and is not a judgment call.
const kindPriority = [
  NotificationKind.examCountdown,
  NotificationKind.streakSave,
  NotificationKind.dailyReminder,
  NotificationKind.comeBack,
];

abstract final class NotificationCeiling {
  /// Returns at most one payload for the day given. The losers are dropped,
  /// never deferred: a queue that fires yesterday's nudge tomorrow says
  /// something untrue.
  static NotificationPayload? pick(List<NotificationPayload> eligible) {
    if (eligible.isEmpty) return null;

    NotificationPayload? bestPayload;
    var bestIndex = 999999;

    for (final payload in eligible) {
      final index = kindPriority.indexOf(payload.kind);
      final priorityIndex = index >= 0 ? index : 999999;
      if (priorityIndex < bestIndex) {
        bestIndex = priorityIndex;
        bestPayload = payload;
      }
    }

    return bestPayload;
  }
}
