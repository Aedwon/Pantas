import 'package:cse_cet_reviewer/core/notifications/notification_service.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam_date.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_providers.dart';
import 'package:cse_cet_reviewer/features/settings/data/settings_repository.dart';
import 'package:cse_cet_reviewer/features/settings/domain/session_ordering.dart';
import 'package:cse_cet_reviewer/features/settings/domain/theme_preference.dart';
import 'package:cse_cet_reviewer/features/settings/domain/user_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReminderSaveResult { scheduled }

// ignore: one_member_abstracts
abstract interface class StudyPlanRebalanceGateway {
  Future<void> onSettingsExamDateChanged(
    DateTime date, {
    required DateTime today,
  });
}

class NoopStudyPlanRebalanceGateway implements StudyPlanRebalanceGateway {
  const NoopStudyPlanRebalanceGateway();

  @override
  Future<void> onSettingsExamDateChanged(
    DateTime date, {
    required DateTime today,
  }) async {}
}

final studyPlanRebalanceGatewayProvider = Provider<StudyPlanRebalanceGateway>(
  (ref) => const NoopStudyPlanRebalanceGateway(),
);

final analyticsConsentGatewayProvider = Provider<AnalyticsConsentGateway>(
  (ref) => const NoopAnalyticsConsentGateway(),
);

final settingsRepositoryProvider = Provider<DriftSettingsRepository>((ref) {
  return DriftSettingsRepository(
    ref.watch(appDatabaseProvider),
    analytics: ref.watch(analyticsConsentGatewayProvider),
  );
});

final userSettingsProvider = FutureProvider<UserSettings>((ref) async {
  return ref.watch(settingsRepositoryProvider).readUserSettings();
});

final themePreferenceProvider = FutureProvider<ThemePreference>((ref) async {
  return ref.watch(settingsRepositoryProvider).readThemePreference();
});

final themePreferenceControllerProvider = StateNotifierProvider<
    ThemePreferenceController, AsyncValue<ThemePreference>>((ref) {
  return ThemePreferenceController(ref);
});

class ThemePreferenceController
    extends StateNotifier<AsyncValue<ThemePreference>> {
  ThemePreferenceController(this._ref)
      : super(const AsyncValue.data(ThemePreference.system));

  final Ref _ref;

  Future<void> setThemePreference(ThemePreference preference) async {
    state = AsyncValue.data(preference);
    await _ref
        .read(settingsRepositoryProvider)
        .updateThemePreference(preference);
    _ref.invalidate(themePreferenceProvider);
  }
}

final settingsActionsProvider = Provider<SettingsActions>((ref) {
  return SettingsActions(ref);
});

class SettingsActions {
  SettingsActions(this._ref);

  final Ref _ref;

  Future<void> setName(String? name) async {
    await _ref.read(settingsRepositoryProvider).updateName(name);
    _ref.invalidate(userSettingsProvider);
  }

  Future<void> setHelpImproveApp({required bool enabled}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateHelpImproveApp(enabled: enabled);
    _ref.invalidate(userSettingsProvider);
  }

  Future<void> setStrictMockMode({required bool enabled}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateStrictMockMode(enabled: enabled);
    _ref.invalidate(userSettingsProvider);
  }

  Future<void> setReminderTime(SettingsTime time) async {
    await _ref.read(settingsRepositoryProvider).updateReminderTime(time);
    _ref.invalidate(userSettingsProvider);
  }

  Future<void> setExamDate(ExamDate date, {required DateTime today}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateExamDate(date, today: today);
    _ref.invalidate(userSettingsProvider);
  }

  Future<String> saveExamDate(ExamDate date, {required DateTime today}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateExamDate(date, today: today);
    final day = date.day;
    if (day != null) {
      await _ref
          .read(studyPlanRebalanceGatewayProvider)
          .onSettingsExamDateChanged(
            day,
            today: today,
          );
    }
    _ref.invalidate(userSettingsProvider);
    return 'Your study plan is being rebalanced.';
  }

  Future<void> setCarryOverProgress({required bool enabled}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateCarryOverProgress(enabled: enabled);
    _ref.invalidate(userSettingsProvider);
  }

  Future<void> setSessionOrdering(SessionOrdering ordering) async {
    await _ref.read(settingsRepositoryProvider).updateSessionOrdering(ordering);
    _ref.invalidate(userSettingsProvider);
  }

  Future<void> setRetainTableOrder({required bool enabled}) async {
    await _ref
        .read(settingsRepositoryProvider)
        .updateRetainTableOrder(enabled: enabled);
    _ref.invalidate(userSettingsProvider);
  }

  Future<ReminderSaveResult> saveReminderTime(SettingsTime time) async {
    await _ref.read(settingsRepositoryProvider).updateReminderTime(time);
    await _ref.read(notificationServiceProvider).scheduleDailyReminder(
          NotificationTime(hour: time.hour, minute: time.minute),
        );
    _ref.invalidate(userSettingsProvider);
    return ReminderSaveResult.scheduled;
  }
}

/// The active exam's short name, for the Exam row's value column.
final activeExamShortNameProvider = Provider<String>((ref) {
  final focus = ref.watch(activeExamFocusProvider).valueOrNull;
  return focus?.exam?.shortName ?? 'Not set';
});

/// The Pro row's value. Free students see "Free" and every other row on the
/// screen is unchanged: no row is hidden, disabled or badged by entitlement.
final proRowValueProvider = Provider<String>((ref) {
  final entitlement = ref.watch(entitlementProvider).valueOrNull;
  return entitlement != null && entitlement.proIsActive ? 'Pro' : 'Free';
});
