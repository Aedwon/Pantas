import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';
import 'package:pantas/features/settings/domain/theme_preference.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

typedef SettingsClock = DateTime Function();

abstract interface class AnalyticsConsentGateway {
  void closeTelemetryGate();

  Future<void> setAnalyticsCollectionEnabled({required bool enabled});
}

class NoopAnalyticsConsentGateway implements AnalyticsConsentGateway {
  const NoopAnalyticsConsentGateway();

  @override
  void closeTelemetryGate() {}

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {}
}

abstract final class SettingsPrefKeys {
  static const name = 'settings.name';
  static const dailyReminderTime = 'settings.daily_reminder_time';
  static const studyDays = 'settings.study_days';
  static const examDate = 'settings.exam_date';
  static const examDatePrecision = 'settings.exam_date_precision';
  static const policyAcceptedAt = 'settings.policy_accepted_at';
  static const policyVersion = 'settings.policy_version';
  static const strictMockMode = 'strict_mock_mode';
  static const helpImproveApp = 'settings.help_improve_app';
  static const carryOverProgress = 'settings.carry_over_progress';
  static const sessionOrdering = 'settings.session_ordering';
  static const retainTableOrder = 'settings.retain_table_order';
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

  /// Bumped whenever the Terms or the Privacy Policy change materially. It is
  /// what lets a later release re-prompt only the students who accepted an
  /// older document.
  static const currentPolicyVersion = '1';

  final AppDatabase _db;
  final AnalyticsConsentGateway _analytics;
  final SettingsClock _clock;

  Future<UserSettings> readUserSettings() async {
    final rows = await _db.select(_db.accountPrefs).get();
    final values = {for (final row in rows) row.key: row.value};
    final name = values[SettingsPrefKeys.name]?.trim();

    return UserSettings(
      name: (name == null || name.isEmpty) ? null : name,
      dailyReminderTime:
          SettingsTime.fromStorage(values[SettingsPrefKeys.dailyReminderTime]),
      studyDays: StudyDays.fromStorage(values[SettingsPrefKeys.studyDays]),
      examDate: ExamDate.fromStorage(
        values[SettingsPrefKeys.examDate],
        values[SettingsPrefKeys.examDatePrecision],
      ),
      strictMockMode: values[SettingsPrefKeys.strictMockMode] == 'true',
      // Absent means unanswered, and unanswered means off. Consent that
      // defaults to yes is not consent, and this switch governs crash reports
      // and analytics from 3 August. It used to read `!= 'false'`, so an
      // unanswered student was opted in.
      helpImproveApp: values[SettingsPrefKeys.helpImproveApp] == 'true',
      carryOverProgress: values[SettingsPrefKeys.carryOverProgress] != 'false',
      sessionOrdering:
          SessionOrdering.fromStorage(values[SettingsPrefKeys.sessionOrdering]),
      retainTableOrder: values[SettingsPrefKeys.retainTableOrder] != 'false',
      updatedAt: DateTime.tryParse(values[SettingsPrefKeys.updatedAt] ?? ''),
      acceptedTermsAt: DateTime.tryParse(
        values[SettingsPrefKeys.policyAcceptedAt] ?? '',
      ),
    );
  }

  Future<void> updateName(String? name) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.name: name?.trim() ?? '',
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> recordPolicyAcceptance() async {
    await _writeAccountPrefs({
      SettingsPrefKeys.policyAcceptedAt: _clock().toUtc().toIso8601String(),
      SettingsPrefKeys.policyVersion: currentPolicyVersion,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateReminderTime(SettingsTime time) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.dailyReminderTime: time.storageValue,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateStudyDays(StudyDays days) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.studyDays: days.storageValue,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateExamDate(ExamDate date, {required DateTime today}) async {
    // At month precision the comparison is against the month, not the 1st, so
    // the current month stays selectable while it still has days left in it.
    final earliest = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 1));
    final toCompare = date.day ?? DateTime(date.year, date.month + 1, 0);
    if (toCompare.isBefore(earliest)) {
      throw InvalidExamDateException(date);
    }
    await _writeAccountPrefs({
      SettingsPrefKeys.examDate: date.storageValue,
      SettingsPrefKeys.examDatePrecision: date.precision.name,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> clearExamDate() async {
    await _writeAccountPrefs({
      SettingsPrefKeys.examDate: '',
      SettingsPrefKeys.examDatePrecision: '',
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
    if (!enabled) {
      _analytics.closeTelemetryGate();

      Object? writeError;
      StackTrace? writeStack;
      try {
        await _writeAccountPrefs({
          SettingsPrefKeys.helpImproveApp: 'false',
          SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
        });
      } catch (error, stack) {
        writeError = error;
        writeStack = stack;
      }

      Object? gatewayError;
      StackTrace? gatewayStack;
      try {
        await _analytics.setAnalyticsCollectionEnabled(enabled: false);
      } catch (error, stack) {
        gatewayError = error;
        gatewayStack = stack;
      }

      if (writeError != null) {
        Error.throwWithStackTrace(writeError, writeStack!);
      }
      if (gatewayError != null) {
        Error.throwWithStackTrace(gatewayError, gatewayStack!);
      }
      return;
    }

    await _analytics.setAnalyticsCollectionEnabled(enabled: true);

    try {
      await _writeAccountPrefs({
        SettingsPrefKeys.helpImproveApp: 'true',
        SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
      });
    } catch (writeError, writeStack) {
      try {
        await _analytics.setAnalyticsCollectionEnabled(enabled: false);
      } catch (_) {
        // Cleanup failure is ignored so original write error is rethrown below.
      }
      Error.throwWithStackTrace(writeError, writeStack);
    }
  }

  Future<void> updateCarryOverProgress({required bool enabled}) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.carryOverProgress: enabled ? 'true' : 'false',
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateSessionOrdering(SessionOrdering ordering) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.sessionOrdering: ordering.storageValue,
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
  }

  Future<void> updateRetainTableOrder({required bool enabled}) async {
    await _writeAccountPrefs({
      SettingsPrefKeys.retainTableOrder: enabled ? 'true' : 'false',
      SettingsPrefKeys.updatedAt: _clock().toUtc().toIso8601String(),
    });
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
}
