import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/settings/domain/theme_preference.dart';
import 'package:cse_cet_reviewer/features/settings/domain/user_settings.dart';
import 'package:drift/drift.dart';

typedef SettingsClock = DateTime Function();

// ignore: one_member_abstracts
abstract interface class AnalyticsConsentGateway {
  Future<void> setAnalyticsCollectionEnabled({required bool enabled});
}

class NoopAnalyticsConsentGateway implements AnalyticsConsentGateway {
  const NoopAnalyticsConsentGateway();

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {}
}

abstract final class SettingsPrefKeys {
  static const dailyReminderTime = 'settings.daily_reminder_time';
  static const examDate = 'settings.exam_date';
  static const strictMockMode = 'strict_mock_mode';
  static const helpImproveApp = 'settings.help_improve_app';
  static const updatedAt = 'settings.updated_at';
  static const themeMode = 'theme_mode';
}

class DriftSettingsRepository {
  DriftSettingsRepository(
    this._db, {
    AnalyticsConsentGateway? analytics,
    SettingsClock? clock,
  })  : _analytics = analytics ?? const NoopAnalyticsConsentGateway(),
        _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final AnalyticsConsentGateway _analytics;
  final SettingsClock _clock;

  Future<UserSettings> readUserSettings() async {
    final rows = await _db.select(_db.accountPrefs).get();
    final values = {for (final row in rows) row.key: row.value};
    return UserSettings(
      dailyReminderTime:
          SettingsTime.fromStorage(values[SettingsPrefKeys.dailyReminderTime]),
      examDate: _parseDate(values[SettingsPrefKeys.examDate]),
      strictMockMode: values[SettingsPrefKeys.strictMockMode] == 'true',
      helpImproveApp: values[SettingsPrefKeys.helpImproveApp] != 'false',
      updatedAt: DateTime.tryParse(values[SettingsPrefKeys.updatedAt] ?? ''),
    );
  }

  Future<void> updateReminderTime(SettingsTime time) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.dailyReminderTime: time.storageValue,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateExamDate(DateTime date, {required DateTime today}) async {
    final normalizedDate = _dateOnly(date);
    final earliest = _dateOnly(today).add(const Duration(days: 1));
    if (normalizedDate.isBefore(earliest)) {
      throw InvalidExamDateException(normalizedDate);
    }
    await _writeAccountPrefs({
      SettingsPrefKeys.examDate: _formatDate(normalizedDate),
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateStrictMockMode({required bool enabled}) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.strictMockMode: enabled ? 'true' : 'false',
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateHelpImproveApp({required bool enabled}) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.helpImproveApp: enabled ? 'true' : 'false',
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
    await _analytics.setAnalyticsCollectionEnabled(enabled: enabled);
  }

  Future<ThemePreference> readThemePreference() async {
    final row = await (_db.select(_db.devicePrefs)
          ..where((pref) => pref.key.equals(SettingsPrefKeys.themeMode)))
        .getSingleOrNull();
    return ThemePreferenceX.fromStorage(row?.value);
  }

  Future<void> updateThemePreference(ThemePreference preference) async {
    await _db.into(_db.devicePrefs).insertOnConflictUpdate(
          DevicePrefsCompanion.insert(
            key: SettingsPrefKeys.themeMode,
            value: preference.storageValue,
          ),
        );
  }

  Future<void> _writeAccountPrefs(Map<String, String> values) async {
    await _db.batch((batch) {
      for (final entry in values.entries) {
        batch.insert(
          _db.accountPrefs,
          AccountPrefsCompanion.insert(key: entry.key, value: entry.value),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime? _parseDate(String? value) {
    if (value == null) return null;
    final parts = value.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }
}
