import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('returns default user settings when account prefs are missing',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    final settings = await repo.readUserSettings();

    expect(settings.dailyReminderTime, isNull);
    expect(settings.examDate, isNull);
    expect(settings.strictMockMode, isFalse);
    expect(settings.helpImproveApp, isTrue);
  });

  test('updates reminder time and bumps updatedAt', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(
      db,
      clock: () => DateTime.utc(2026, 5, 22, 12),
    );

    await repo.updateReminderTime(const SettingsTime(hour: 19, minute: 5));

    final settings = await repo.readUserSettings();
    expect(settings.dailyReminderTime, const SettingsTime(hour: 19, minute: 5));
    expect(settings.updatedAt, DateTime.utc(2026, 5, 22, 12));
  });

  test('updates exam date only for tomorrow or later and bumps updatedAt',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(
      db,
      clock: () => DateTime.utc(2026, 5, 22, 12),
    );

    await repo.updateExamDate(
      DateTime(2026, 5, 23),
      today: DateTime(2026, 5, 22),
    );

    expect((await repo.readUserSettings()).examDate, DateTime(2026, 5, 23));
    await expectLater(
      repo.updateExamDate(
        DateTime(2026, 5, 22),
        today: DateTime(2026, 5, 22),
      ),
      throwsA(isA<InvalidExamDateException>()),
    );
  });

  test('updates strict mock mode in account prefs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.updateStrictMockMode(enabled: true);

    expect((await repo.readUserSettings()).strictMockMode, isTrue);
    final rows = await db.select(db.accountPrefs).get();
    expect(
      rows,
      contains(
        const AccountPrefRow(
            key: SettingsPrefKeys.strictMockMode, value: 'true'),
      ),
    );
  });

  test('updates help improve app and calls analytics consent gate', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final analytics = RecordingAnalyticsConsentGateway();
    final repo = DriftSettingsRepository(db, analytics: analytics);

    await repo.updateHelpImproveApp(enabled: false);

    expect((await repo.readUserSettings()).helpImproveApp, isFalse);
    expect(analytics.values, [false]);
  });

  test('theme mode defaults to system from device prefs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    expect(await repo.readThemePreference(), ThemePreference.system);
  });

  test('theme mode writes only device prefs and never account prefs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);

    await repo.updateThemePreference(ThemePreference.dark);

    expect(await repo.readThemePreference(), ThemePreference.dark);
    expect(await db.select(db.accountPrefs).get(), isEmpty);
    expect(await db.select(db.devicePrefs).get(), hasLength(1));
  });
}

class RecordingAnalyticsConsentGateway implements AnalyticsConsentGateway {
  final values = <bool>[];

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    values.add(enabled);
  }
}
