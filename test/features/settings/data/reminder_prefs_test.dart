import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/features/notifications/domain/reminder_prefs.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('legacy opt-in and separate switches survive repository recreation',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.accountPrefs).insert(
          AccountPrefsCompanion.insert(
            key: SettingsPrefKeys.dailyReminderTime,
            value: '18:30',
          ),
        );
    final repo = DriftSettingsRepository(db);
    final legacy = await repo.readReminderPrefs();
    expect(legacy.dailyEnabled, isTrue);
    expect(legacy.dailyTime, const NotificationTime(hour: 18, minute: 30));
    expect(legacy.followUpTime, const NotificationTime(hour: 21, minute: 0));
    await repo.updateReminderPrefs(
      const ReminderPrefs(
        dailyEnabled: false,
        dailyTime: NotificationTime(hour: 18, minute: 30),
        followUpEnabled: true,
        followUpTime: NotificationTime(hour: 22, minute: 15),
        countdownEnabled: false,
      ),
    );
    final saved = await DriftSettingsRepository(db).readReminderPrefs();
    expect(saved.dailyEnabled, isFalse);
    expect(saved.dailyTime, const NotificationTime(hour: 18, minute: 30));
    expect(saved.followUpEnabled, isTrue);
    expect(saved.followUpTime, const NotificationTime(hour: 22, minute: 15));
    expect(saved.countdownEnabled, isFalse);
  });

  test('an unanswered daily reminder stays off with the drawn default times',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final prefs = await DriftSettingsRepository(db).readReminderPrefs();
    expect(prefs.dailyEnabled, isFalse);
    expect(prefs.dailyTime, const NotificationTime(hour: 19, minute: 0));
    expect(prefs.followUpTime, const NotificationTime(hour: 21, minute: 0));
  });

  test('invalid follow-up time cannot partially save preferences', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final repo = DriftSettingsRepository(db);
    await expectLater(
      repo.updateReminderPrefs(
        const ReminderPrefs(
          dailyEnabled: true,
          followUpEnabled: true,
          followUpTime: NotificationTime(hour: 18, minute: 59),
          countdownEnabled: true,
        ),
      ),
      throwsArgumentError,
    );
    expect((await repo.readReminderPrefs()).dailyEnabled, isFalse);
  });
}
