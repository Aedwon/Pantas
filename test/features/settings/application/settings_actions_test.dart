import 'package:pantas/core/notifications/notification_service.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('saving exam date writes settings and study plan prefs', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final rebalanceGateway = RecordingStudyPlanRebalanceGateway();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        studyPlanRebalanceGatewayProvider.overrideWithValue(rebalanceGateway),
      ],
    );
    addTearDown(container.dispose);

    final message = await container.read(settingsActionsProvider).saveExamDate(
          ExamDate.onDay(DateTime(2026, 9, 14)),
          today: DateTime(2026, 5, 22),
        );

    expect(message, 'Your study plan is being rebalanced.');
    expect(
      (await DriftSettingsRepository(db).readUserSettings()).examDate,
      ExamDate.onDay(DateTime(2026, 9, 14)),
    );
    expect(rebalanceGateway.dates, [DateTime(2026, 9, 14)]);
  });

  test('saving today exam date rejects without writing', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(settingsActionsProvider).saveExamDate(
            ExamDate.onDay(DateTime(2026, 5, 22)),
            today: DateTime(2026, 5, 22),
          ),
      throwsA(isA<InvalidExamDateException>()),
    );

    expect(
      (await DriftSettingsRepository(db).readUserSettings()).examDate,
      isNull,
    );
  });

  test('saving reminder time writes settings and calls notification scheduler',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final notifications = RecordingNotificationService();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(settingsActionsProvider)
        .saveReminderTime(const SettingsTime(hour: 19, minute: 0));

    expect(result, ReminderSaveResult.scheduled);
    expect(
      (await DriftSettingsRepository(db).readUserSettings()).dailyReminderTime,
      const SettingsTime(hour: 19, minute: 0),
    );
    expect(
      notifications.scheduled,
      [const NotificationTime(hour: 19, minute: 0)],
    );
  });

  test('setting the name writes it and invalidates the settings provider',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(settingsActionsProvider).setName('Aedwon');

    final settings = await container.read(userSettingsProvider.future);
    expect(settings.name, 'Aedwon');
  });

  test('setting a month-precision exam date keeps its precision', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container.read(settingsActionsProvider).setExamDate(
          ExamDate.inMonth(year: 2026, month: 10),
          today: DateTime(2026, 8, 3),
        );

    final settings = await container.read(userSettingsProvider.future);
    expect(settings.examDate!.day, isNull);
  });

  test('carry over, ordering and table order all persist', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final actions = container.read(settingsActionsProvider);
    await actions.setCarryOverProgress(enabled: false);
    await actions.setSessionOrdering(SessionOrdering.blocked);
    await actions.setRetainTableOrder(enabled: false);

    final settings = await container.read(userSettingsProvider.future);
    expect(settings.carryOverProgress, isFalse);
    expect(settings.sessionOrdering, SessionOrdering.blocked);
    expect(settings.retainTableOrder, isFalse);
  });

  test('saveExamDate at month precision does not call rebalance gateway',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final rebalanceGateway = RecordingStudyPlanRebalanceGateway();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        studyPlanRebalanceGatewayProvider.overrideWithValue(rebalanceGateway),
      ],
    );
    addTearDown(container.dispose);

    final message = await container.read(settingsActionsProvider).saveExamDate(
          ExamDate.inMonth(year: 2026, month: 10),
          today: DateTime(2026, 8, 3),
        );

    expect(message, 'Your study plan is being rebalanced.');
    expect(rebalanceGateway.dates, isEmpty);
  });
}

class RecordingStudyPlanRebalanceGateway implements StudyPlanRebalanceGateway {
  final dates = <DateTime>[];

  @override
  Future<void> onSettingsExamDateChanged(
    DateTime date, {
    required DateTime today,
  }) async {
    dates.add(date);
  }
}

class RecordingNotificationService implements NotificationService {
  final scheduled = <NotificationTime>[];

  @override
  Future<void> cancelAll() async {}

  @override
  Future<void> onSessionCompleted() async {}

  @override
  Future<void> openAppNotificationSettings() async {}

  @override
  Future<NotificationPermission> requestPermission() async {
    return NotificationPermission.granted;
  }

  @override
  Future<void> rescheduleForForeground() async {}

  @override
  Future<void> scheduleDailyReminder(NotificationTime time) async {
    scheduled.add(time);
  }
}
