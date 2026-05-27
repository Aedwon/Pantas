import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
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
          DateTime(2026, 9, 14),
          today: DateTime(2026, 5, 22),
        );

    expect(message, 'Your study plan is being rebalanced.');
    expect(
      (await DriftSettingsRepository(db).readUserSettings()).examDate,
      DateTime(2026, 9, 14),
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
            DateTime(2026, 5, 22),
            today: DateTime(2026, 5, 22),
          ),
      throwsA(isA<InvalidExamDateException>()),
    );

    expect((await DriftSettingsRepository(db).readUserSettings()).examDate,
        isNull);
  });

  test('saving reminder time writes settings and reports Spec 9 unavailable',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(settingsActionsProvider)
        .saveReminderTime(const SettingsTime(hour: 19, minute: 0));

    expect(result, ReminderSaveResult.notificationDeliveryPendingSpec9);
    expect(
      (await DriftSettingsRepository(db).readUserSettings()).dailyReminderTime,
      const SettingsTime(hour: 19, minute: 0),
    );
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
