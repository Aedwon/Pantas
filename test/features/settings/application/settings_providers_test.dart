import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/repos/assessment_repository.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('userSettingsProvider reads repository defaults', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    final settings = await container.read(userSettingsProvider.future);

    expect(settings.helpImproveApp, isFalse);
    expect(settings.strictMockMode, isFalse);
  });

  test('themeModeProvider initializes from repository', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await DriftSettingsRepository(db).updateThemePreference(
      ThemePreference.dark,
    );
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    expect(
      await container.read(themePreferenceProvider.future),
      ThemePreference.dark,
    );
  });

  test('themeModeController writes selected theme', () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    await container
        .read(themePreferenceControllerProvider.notifier)
        .setThemePreference(ThemePreference.light);

    expect(
      await DriftSettingsRepository(db).readThemePreference(),
      ThemePreference.light,
    );
    expect(
      await container.read(themePreferenceProvider.future),
      ThemePreference.light,
    );
  });

  test('analytics consent gateway is invoked when help improve app changes',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final analytics = RecordingAnalyticsConsentGateway();
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        analyticsConsentGatewayProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(settingsActionsProvider)
        .setHelpImproveApp(enabled: false);

    expect(analytics.values, [false]);
  });

  for (final initiallyStudyDay in [true, false]) {
    test('study day change refreshes the watched panel: $initiallyStudyDay',
        () async {
      final now = DateTime(2026, 9, 30, 8); // Wednesday.
      final db = inMemoryDatabase();
      final contentDb = inMemoryContentDatabase();
      addTearDown(db.close);
      addTearDown(contentDb.close);
      final repository = DriftSettingsRepository(db);
      await repository.updateExamDate(
        ExamDate.onDay(DateTime(2026, 10, 3)),
        today: now,
      );
      final restDays = StudyDays(const [1, 2, 4, 5]);
      await repository.updateStudyDays(
        initiallyStudyDay ? StudyDays.all : restDays,
      );
      await seedContentTopicWithQuestions(
        contentDb,
        examId: 'e1',
        topicId: 't1',
        topicName: 'Algebra',
        questionIds: ['q1', 'q2', 'q3'],
      );
      await AssessmentRepository(db).saveResult('e1', now, const []);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          nowProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(container.dispose);
      final subscription =
          container.listen(sessionPanelProvider('e1'), (_, __) {});
      addTearDown(subscription.close);
      final before = await container.read(sessionPanelProvider('e1').future);
      expect(
        before,
        initiallyStudyDay
            ? isA<SessionPanelAvailable>()
            : isA<SessionPanelCaughtUp>(),
      );
      await container.read(settingsActionsProvider).updateStudyDays(
            initiallyStudyDay ? restDays : StudyDays.all,
          );
      final after = await container.read(sessionPanelProvider('e1').future);
      expect(
        after,
        initiallyStudyDay
            ? isA<SessionPanelCaughtUp>()
            : isA<SessionPanelAvailable>(),
      );
      await container.read(settingsActionsProvider).updateStudyDays(
            initiallyStudyDay ? StudyDays.all : restDays,
          );
      final restored = await container.read(sessionPanelProvider('e1').future);
      expect(
        restored,
        initiallyStudyDay
            ? isA<SessionPanelAvailable>()
            : isA<SessionPanelCaughtUp>(),
      );
    });
  }

  test('default analytics consent gateway is NoopAnalyticsConsentGateway', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(analyticsConsentGatewayProvider),
      isA<NoopAnalyticsConsentGateway>(),
    );
  });
}

class RecordingAnalyticsConsentGateway implements AnalyticsConsentGateway {
  final values = <bool>[];

  @override
  void closeTelemetryGate() {}

  @override
  Future<void> setAnalyticsCollectionEnabled({required bool enabled}) async {
    values.add(enabled);
  }
}
