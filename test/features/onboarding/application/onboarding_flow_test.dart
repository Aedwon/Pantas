import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  test('resume stops at the first unanswered storage preference', () {
    expect(OnboardingProgress().resumeStep, OnboardingStep.welcome);
    expect(
      OnboardingProgress(agePassed: true).resumeStep,
      OnboardingStep.terms,
    );
    expect(
      OnboardingProgress(agePassed: true, policyAccepted: true).resumeStep,
      OnboardingStep.picker,
    );
    expect(
      OnboardingProgress(
        agePassed: true,
        policyAccepted: true,
        examPicked: true,
      ).resumeStep,
      OnboardingStep.examDate,
    );
    expect(
      OnboardingProgress(
        agePassed: true,
        policyAccepted: true,
        examPicked: true,
        dateAnswered: true,
      ).resumeStep,
      OnboardingStep.studyDays,
    );
    expect(
      OnboardingProgress(
        agePassed: true,
        policyAccepted: true,
        examPicked: true,
        dateAnswered: true,
        daysAnswered: true,
      ).resumeStep,
      OnboardingStep.name,
    );
    expect(
      OnboardingProgress(
        agePassed: true,
        policyAccepted: true,
        examPicked: true,
        dateAnswered: true,
        daysAnswered: true,
        nameAnswered: true,
      ).resumeStep,
      OnboardingStep.reminders,
    );
  });

  test('a saved name does not complete onboarding without reminders', () {
    expect(
      OnboardingProgress(
        agePassed: true,
        policyAccepted: true,
        examPicked: true,
        dateAnswered: true,
        daysAnswered: true,
        nameAnswered: true,
      ).complete,
      isFalse,
    );
    expect(
      OnboardingProgress(
        agePassed: true,
        policyAccepted: true,
        examPicked: true,
        dateAnswered: true,
        daysAnswered: true,
        nameAnswered: true,
        remindersShown: true,
      ).complete,
      isTrue,
    );
    // A reminder flag never bypasses an unfinished legal step.
    expect(OnboardingProgress(remindersShown: true).complete, isFalse);
  });

  test('a minor who has not been cleared resumes at the guardian step', () {
    expect(
      OnboardingProgress(minorAwaitingGuardian: true).resumeStep,
      OnboardingStep.guardian,
    );
    expect(
      OnboardingProgress(agePassed: true, minorAwaitingGuardian: true)
          .resumeStep,
      OnboardingStep.terms,
      reason: 'once cleared, the flow moves on',
    );
  });

  test('a stored age block requires guardian setup even after another age', () {
    expect(
      OnboardingProgress(needsGuardianSetup: true, agePassed: true).resumeStep,
      OnboardingStep.age,
    );
    expect(
      OnboardingProgress(needsGuardianSetup: true, agePassed: true).complete,
      isFalse,
    );
  });

  test('the guardian step shares the first segment and backs to the age step',
      () {
    expect(OnboardingStep.guardian.segment, 1);
    expect(OnboardingFlow(OnboardingStep.guardian).back(), OnboardingStep.age);
    expect(OnboardingStep.guardian.telemetryName, 'guardian');
  });

  test('the six board segments cover age, terms, picker, date, days and name',
      () {
    expect(OnboardingStep.launch.segment, isNull);
    expect(OnboardingStep.welcome.segment, isNull);
    expect(OnboardingStep.age.segment, 1);
    expect(OnboardingStep.terms.segment, 2);
    expect(OnboardingStep.picker.segment, 3);
    expect(OnboardingStep.customName.segment, 3);
    expect(OnboardingStep.customSubjects.segment, 3);
    expect(OnboardingStep.examDate.segment, 4);
    expect(OnboardingStep.studyDays.segment, 5);
    expect(OnboardingStep.name.segment, 6);
    expect(OnboardingStep.reminders.segment, isNull);
  });

  test('back walks the selected path and welcome lets the route pop', () {
    final normal = OnboardingFlow(OnboardingStep.welcome)
      ..reach(OnboardingStep.age)
      ..reach(OnboardingStep.terms)
      ..reach(OnboardingStep.picker)
      ..reach(OnboardingStep.examDate)
      ..reach(OnboardingStep.studyDays)
      ..reach(OnboardingStep.name)
      ..reach(OnboardingStep.reminders);
    for (final previous in [
      OnboardingStep.name,
      OnboardingStep.studyDays,
      OnboardingStep.examDate,
      OnboardingStep.picker,
      OnboardingStep.terms,
      OnboardingStep.age,
      OnboardingStep.welcome,
    ]) {
      expect(normal.back(), previous);
    }
    expect(normal.back(), isNull);
    final custom = OnboardingFlow(OnboardingStep.picker)
      ..reach(OnboardingStep.customName)
      ..reach(OnboardingStep.customSubjects)
      ..reach(OnboardingStep.examDate);
    expect(custom.back(), OnboardingStep.customSubjects);
    expect(custom.back(), OnboardingStep.picker);
    expect(custom.back(), OnboardingStep.terms);
  });

  test('a resumed step still has the same preceding back step', () {
    expect(OnboardingFlow(OnboardingStep.age).back(), OnboardingStep.welcome);
    expect(OnboardingFlow(OnboardingStep.terms).back(), OnboardingStep.age);
    expect(OnboardingFlow(OnboardingStep.picker).back(), OnboardingStep.terms);
    expect(
      OnboardingFlow(OnboardingStep.examDate).back(),
      OnboardingStep.picker,
    );
    expect(
      OnboardingFlow(OnboardingStep.studyDays).back(),
      OnboardingStep.examDate,
    );
    expect(
      OnboardingFlow(OnboardingStep.name).back(),
      OnboardingStep.studyDays,
    );
    expect(
      OnboardingFlow(OnboardingStep.reminders).back(),
      OnboardingStep.name,
    );
  });

  group('the age group on the device decides the teen guardian step', () {
    Future<bool> awaiting(String group) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await AppPreferencesRepository(db).setAgeGroup(group);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      return (await container.read(onboardingProgressProvider.future))
          .minorAwaitingGuardian;
    }

    test('a minor and an unrecognized group wait for a guardian', () async {
      expect(await awaiting('minor'), isTrue);
      expect(await awaiting('teen'), isTrue);
    });

    test('a child and an adult do not take the teen guardian step', () async {
      expect(await awaiting('child'), isFalse);
      expect(await awaiting('adult'), isFalse);
    });
  });
}
