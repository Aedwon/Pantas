import 'dart:convert';

enum NotificationKind {
  dailyReminder('daily_reminder'),
  followUp('follow_up'),
  trialEnding('trial_ending'),
  examCountdown('exam_countdown'),
  comeBack('come_back');

  const NotificationKind(this.storageValue);

  final String storageValue;

  static NotificationKind? fromStorage(String? value) {
    for (final kind in NotificationKind.values) {
      if (kind.storageValue == value) return kind;
    }
    return null;
  }
}

class NotificationPayload {
  const NotificationPayload({
    required this.kind,
    required this.scheduledFor,
    this.route,
    this.shareId,
  });

  final NotificationKind kind;
  final DateTime scheduledFor;
  final String? route;
  final String? shareId;

  String encode() {
    return jsonEncode({
      'kind': kind.storageValue,
      'scheduled_for': scheduledFor.toIso8601String(),
      if (route != null) 'route': route,
      if (shareId != null) 'share_id': shareId,
    });
  }

  static NotificationPayload? tryDecode(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, Object?>) return null;
      final rawKind = decoded['kind'];
      final rawTime = decoded['scheduled_for'];
      final route = decoded['route'];
      final shareId = decoded['share_id'];
      if (rawKind is! String ||
          rawTime is! String ||
          (route != null && route is! String) ||
          (shareId != null && shareId is! String)) {
        return null;
      }
      final kind = NotificationKind.fromStorage(rawKind);
      final scheduledFor = DateTime.tryParse(
        rawTime,
      );
      if (kind == null || scheduledFor == null) return null;
      return NotificationPayload(
        kind: kind,
        scheduledFor: scheduledFor,
        route: route as String?,
        shareId: shareId as String?,
      );
    } on FormatException {
      return null;
    }
  }
}
