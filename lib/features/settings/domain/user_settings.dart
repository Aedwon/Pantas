import 'package:cse_cet_reviewer/features/settings/domain/exam_date.dart';
import 'package:meta/meta.dart';

@immutable
class SettingsTime {
  const SettingsTime({required this.hour, required this.minute})
      : assert(hour >= 0 && hour <= 23, 'hour must be 0 through 23'),
        assert(minute >= 0 && minute <= 59, 'minute must be 0 through 59');

  final int hour;
  final int minute;

  String get storageValue =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  static SettingsTime? fromStorage(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return SettingsTime(hour: hour, minute: minute);
  }

  @override
  bool operator ==(Object other) {
    return other is SettingsTime &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => storageValue;
}

@immutable
class UserSettings {
  const UserSettings({
    required this.dailyReminderTime,
    required this.examDate,
    required this.strictMockMode,
    required this.helpImproveApp,
    required this.updatedAt,
  });

  factory UserSettings.defaults() {
    return const UserSettings(
      dailyReminderTime: null,
      examDate: null,
      strictMockMode: false,
      helpImproveApp: false,
      updatedAt: null,
    );
  }

  final SettingsTime? dailyReminderTime;
  final ExamDate? examDate;
  final bool strictMockMode;
  final bool helpImproveApp;
  final DateTime? updatedAt;
}

class InvalidExamDateException implements Exception {
  const InvalidExamDateException(this.date);

  final ExamDate date;
}
