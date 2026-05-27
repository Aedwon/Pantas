import 'dart:convert';

enum NotificationKind {
  dailyReminder('daily_reminder'),
  streakSave('streak_save');

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
  });

  final NotificationKind kind;
  final DateTime scheduledFor;
  final String? route;

  String encode() {
    return jsonEncode({
      'kind': kind.storageValue,
      'scheduled_for': scheduledFor.toIso8601String(),
      if (route != null) 'route': route,
    });
  }

  static NotificationPayload? tryDecode(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map<String, Object?>) return null;
      final kind = NotificationKind.fromStorage(decoded['kind'] as String?);
      final scheduledFor = DateTime.tryParse(
        decoded['scheduled_for'] as String? ?? '',
      );
      if (kind == null || scheduledFor == null) return null;
      return NotificationPayload(
        kind: kind,
        scheduledFor: scheduledFor,
        route: decoded['route'] as String?,
      );
    } on FormatException {
      return null;
    }
  }
}
