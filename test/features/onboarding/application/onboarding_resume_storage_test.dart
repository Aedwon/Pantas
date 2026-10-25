import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('storage resumes terms before picker and remembers an unknown date',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final prefs = AppPreferencesRepository(db);
    final settings = DriftSettingsRepository(db);
    Future<OnboardingProgress> read() async {
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          settingsRepositoryProvider.overrideWithValue(settings),
        ],
      );
      try {
        return await container.read(onboardingProgressProvider.future);
      } finally {
        container.dispose();
      }
    }

    expect((await read()).resumeStep, OnboardingStep.welcome);
    await prefs.setPassedAgeGate(value: true);
    expect((await read()).resumeStep, OnboardingStep.terms);
    await prefs.setSelectedExamId('cse');
    // Even a selected exam cannot bypass legal acceptance.
    expect((await read()).resumeStep, OnboardingStep.terms);
    await settings.recordPolicyAcceptance();
    expect((await read()).resumeStep, OnboardingStep.examDate);
    await prefs.setDeviceValue(onboardingDateAnsweredKey, 'true');
    expect((await read()).resumeStep, OnboardingStep.studyDays);
    await settings.updateStudyDays(StudyDays.all);
    expect((await read()).resumeStep, OnboardingStep.name);
    await settings.updateName('Aerol');
    expect((await read()).resumeStep, OnboardingStep.reminders);
    expect((await read()).complete, isFalse);
    await NotificationRationaleRepository(db).markShown();
    expect((await read()).complete, isTrue);
  });
}
