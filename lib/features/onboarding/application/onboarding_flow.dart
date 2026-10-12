import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

enum OnboardingStep {
  launch,
  welcome,
  age,
  terms,
  picker,
  customName,
  customSubjects,
  examDate,
  studyDays,
  name,
  reminders;

  // O_Flow: six segments count Age through Name. The custom branch keeps
  // the picker's third segment. Launch, Welcome and Reminders have no bar.
  int? get segment => switch (this) {
        age => 1,
        terms => 2,
        picker || customName || customSubjects => 3,
        examDate => 4,
        studyDays => 5,
        name => 6,
        launch || welcome || reminders => null,
      };

  String get telemetryName => switch (this) {
        age => 'age_gate',
        terms => 'consent',
        customName => 'custom_name',
        customSubjects => 'custom_subjects',
        examDate => 'exam_date',
        studyDays => 'study_days',
        launch => 'launch',
        welcome => 'welcome',
        picker => 'picker',
        name => 'name',
        reminders => 'reminders',
      };
}

class OnboardingProgress {
  OnboardingProgress({
    this.agePassed = false,
    this.policyAccepted = false,
    this.examPicked = false,
    this.dateAnswered = false,
    this.daysAnswered = false,
    this.nameAnswered = false,
    this.remindersShown = false,
  });

  final bool agePassed;
  final bool policyAccepted;
  final bool examPicked;
  final bool dateAnswered;
  final bool daysAnswered;
  final bool nameAnswered;
  final bool remindersShown;

  OnboardingStep get resumeStep {
    if (!agePassed) return OnboardingStep.welcome;
    if (!policyAccepted) return OnboardingStep.terms;
    if (!examPicked) return OnboardingStep.picker;
    if (!dateAnswered) return OnboardingStep.examDate;
    if (!daysAnswered) return OnboardingStep.studyDays;
    if (!nameAnswered) return OnboardingStep.name;
    return OnboardingStep.reminders;
  }

  bool get complete =>
      agePassed &&
      policyAccepted &&
      examPicked &&
      dateAnswered &&
      daysAnswered &&
      nameAnswered &&
      remindersShown;
}

/// Keeps the chosen branch so Back from a custom track returns through it.
class OnboardingFlow {
  OnboardingFlow(this.step);

  OnboardingStep step;
  final List<OnboardingStep> _history = [];

  void reach(OnboardingStep next) {
    if (next == step) return;
    _history.add(step);
    step = next;
  }

  OnboardingStep? back() {
    if (step == OnboardingStep.customName ||
        step == OnboardingStep.customSubjects) {
      final picker = _history.lastIndexOf(OnboardingStep.picker);
      if (picker >= 0) {
        _history.removeRange(picker, _history.length);
      } else {
        _history.clear();
      }
      return step = OnboardingStep.picker;
    }
    final previous = _history.isNotEmpty
        ? _history.removeLast()
        : switch (step) {
            OnboardingStep.launch || OnboardingStep.welcome => null,
            OnboardingStep.age => OnboardingStep.welcome,
            OnboardingStep.terms => OnboardingStep.age,
            OnboardingStep.picker => OnboardingStep.terms,
            OnboardingStep.customName => OnboardingStep.picker,
            OnboardingStep.customSubjects => OnboardingStep.customName,
            OnboardingStep.examDate => OnboardingStep.picker,
            OnboardingStep.studyDays => OnboardingStep.examDate,
            OnboardingStep.name => OnboardingStep.studyDays,
            OnboardingStep.reminders => OnboardingStep.name,
          };
    if (previous != null) step = previous;
    return previous;
  }
}

// Device-local because answering "I don't know" is a completed onboarding
// answer even though it deliberately stores no exam date.
const onboardingDateAnsweredKey = 'onboarding.date_answered';

final onboardingProgressProvider =
    FutureProvider<OnboardingProgress>((ref) async {
  final preferences = ref.watch(appPreferencesRepositoryProvider);
  final settings =
      await ref.watch(settingsRepositoryProvider).readUserSettings();
  final db = ref.watch(appDatabaseProvider);
  final savedDays = await (db.select(db.accountPrefs)
        ..where((pref) => pref.key.equals(SettingsPrefKeys.studyDays)))
      .getSingleOrNull();
  return OnboardingProgress(
    agePassed: await ref.watch(passedAgeGateProvider.future),
    policyAccepted: settings.acceptedTermsAt != null,
    examPicked: await preferences.selectedExamId() != null,
    dateAnswered: settings.examDate != null ||
        await preferences.deviceValue(onboardingDateAnsweredKey) == 'true',
    daysAnswered: savedDays != null && savedDays.value.isNotEmpty,
    nameAnswered: settings.name != null,
    remindersShown: await ref.watch(notificationRationaleShownProvider.future),
  );
});
