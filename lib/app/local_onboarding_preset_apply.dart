import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/dev/local_onboarding_presets.dart';
import 'package:pantas/core/dev/local_panel_bridge.dart';
import 'package:pantas/core/platform/local_firebase.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// The exam every onboarding preset picks.
const _presetExamId = 'exam_cse_pro';

/// Hands the onboarding presets to the local test panel's bridge. Does nothing
/// in a build that is not a local run in a browser.
void registerLocalOnboardingPresets() {
  // Both are compile-time constants: normal builds drop everything below.
  if (!localEmulators || !kIsWeb) return;
  applyLocalPreset = applyOnboardingPreset;
}

/// How far an answer has to be written before the target step, in the order
/// the onboarding flow asks them.
enum _Through { nothing, age, terms, exam, date, days }

class _Plan {
  const _Plan(
    this.through, {
    this.seed,
    this.route = '/onboarding',
    this.dateDaysAhead,
    this.studyDays,
  });

  final _Through through;
  final LocalPresetSeed? seed;
  final String route;

  /// Writes an exam date this many days from today instead of the catalog's.
  final int? dateDaysAhead;

  /// Study days written when the plan goes through [_Through.days].
  final Set<int>? studyDays;
}

const _monToSat = {1, 2, 3, 4, 5, 6};

/// The plan for one panel card id, or null for an id with nothing to do.
_Plan? _planFor(String id, DateTime now) {
  LocalPresetSeed date({int? year, int? month, int? day}) => LocalPresetSeed(
        differentDate: true,
        year: year,
        month: month,
        day: day,
      );
  // Three days ahead, as the Study days cards say. Which weekdays leave no
  // study day before the exam depends on today's weekday, so the days are
  // counted from today. The card text (Sun to Tue, Wed to Fri) holds on a
  // Wednesday, the weekday the board was drawn on.
  Set<int> weekdays(List<int> offsets) => {
        for (final offset in offsets) _daysAhead(now, offset).weekday,
      };
  return switch (id) {
    'birthYear' => const _Plan(_Through.nothing),
    'under13' => const _Plan(
        _Through.nothing,
        seed: LocalPresetSeed(birthYearText: '2020', submit: true),
      ),
    'terms' => const _Plan(_Through.age),
    'picker' => const _Plan(_Through.terms),
    'dateKnown' => const _Plan(_Through.exam),
    'days' => const _Plan(
        _Through.date,
        seed: LocalPresetSeed(studyDays: _monToSat),
      ),
    'name' => const _Plan(_Through.days, studyDays: _monToSat),
    'customName' =>
      const _Plan(_Through.terms, route: '/onboarding/custom/name'),
    'customSubjects' => const _Plan(
        _Through.terms,
        route: '/onboarding/custom/name',
        seed: LocalPresetSeed(customName: 'Nursing Board', submit: true),
      ),
    'dateNone' => _Plan(_Through.exam, seed: date()),
    'dateMonth' => _Plan(_Through.exam, seed: date(year: now.year, month: 12)),
    'dateDay' =>
      _Plan(_Through.exam, seed: date(year: now.year, month: 12, day: 15)),
    'dateNextYear' =>
      _Plan(_Through.exam, seed: date(year: now.year + 1, month: 2)),
    'dateThisMonth' =>
      _Plan(_Through.exam, seed: date(year: now.year, month: now.month)),
    'dateToday' => _Plan(
        _Through.exam,
        seed: date(year: now.year, month: now.month, day: now.day),
      ),
    'daysNone' => const _Plan(_Through.date, dateDaysAhead: 3),
    'daysTooLate' => _Plan(
        _Through.date,
        dateDaysAhead: 3,
        seed: LocalPresetSeed(studyDays: weekdays([4, 5, 6])),
      ),
    'daysSoon' => _Plan(
        _Through.date,
        dateDaysAhead: 3,
        seed: LocalPresetSeed(studyDays: weekdays([0, 1, 2])),
      ),
    _ => null,
  };
}

/// Opens onboarding at the step a panel card names.
///
/// Earlier answers are written through the same actions the steps call. The
/// onboarding page is then rebuilt so its flow resumes at the target step, and
/// the step reads its seed. Throws if the app does not become ready within
/// [wait]; the bridge logs that and the app stays where it was.
Future<void> applyOnboardingPreset(
  ProviderContainer container,
  String id, {
  DateTime? now,
  Duration wait = const Duration(seconds: 20),
}) async {
  final today = DateUtils.dateOnly(now ?? DateTime.now());
  final plan = _planFor(id, today);
  if (plan == null) return;

  // The same providers the first onboarding screen waits on.
  await container.read(onboardingProgressProvider.future).timeout(wait);

  final through = plan.through.index;
  if (through >= _Through.age.index) await _answerAge(container);
  if (through >= _Through.terms.index) await _answerTerms(container);
  if (through >= _Through.exam.index) await _answerExam(container);
  if (through >= _Through.date.index) {
    await _answerDate(container, today, plan.dateDaysAhead, wait);
  }
  if (through >= _Through.days.index) {
    await container
        .read(settingsActionsProvider)
        .updateStudyDays(StudyDays(plan.studyDays!));
  }
  container
    ..invalidate(onboardingProgressProvider)
    ..invalidate(activeExamFocusProvider);
  // Open only on settled answers, so the first build is the right step.
  await container.read(onboardingProgressProvider.future).timeout(wait);
  await container.read(activeExamFocusProvider.future).timeout(wait);
  await _open(container, plan);
}

Future<void> _answerAge(ProviderContainer container) async {
  await container
      .read(appPreferencesRepositoryProvider)
      .setPassedAgeGate(value: true);
  container.invalidate(appPreferencesRepositoryProvider);
}

Future<void> _answerTerms(ProviderContainer container) async {
  final repo = container.read(settingsRepositoryProvider);
  await repo.updateHelpImproveApp(enabled: false);
  await repo.recordPolicyAcceptance();
  container
    ..invalidate(settingsRepositoryProvider)
    ..invalidate(userSettingsProvider);
}

Future<void> _answerExam(ProviderContainer container) async {
  final prefs = container.read(appPreferencesRepositoryProvider);
  await prefs.setCompletedOnboarding(value: false);
  await prefs.setSelectedExamId(_presetExamId);
  container.invalidate(appPreferencesRepositoryProvider);
}

/// Answers the date step the way "That's Right" does when the catalog has a
/// date, and with a date [daysAhead] from today when asked. A catalog without
/// an upcoming sitting falls back to 30 days ahead: it is a test fixture, not
/// a figure shown as fact.
Future<void> _answerDate(
  ProviderContainer container,
  DateTime today,
  int? daysAhead,
  Duration wait,
) async {
  var day = daysAhead == null ? null : _daysAhead(today, daysAhead);
  if (day == null) {
    try {
      final catalog =
          await container.read(examPickerCatalogProvider.future).timeout(wait);
      final upcoming = [
        for (final entry in catalog)
          if (entry.id == _presetExamId)
            for (final sitting in entry.publishedSittings)
              if (!DateUtils.dateOnly(sitting.firstDay).isBefore(today))
                DateUtils.dateOnly(sitting.firstDay),
      ]..sort();
      day = upcoming.firstOrNull;
    } on Object catch (error) {
      debugPrint('Local preset: no catalog exam date, using a fixture: $error');
    }
    day ??= _daysAhead(today, 30);
  }
  await container
      .read(settingsRepositoryProvider)
      .updateExamDate(ExamDate.onDay(day), today: today);
  await container
      .read(appPreferencesRepositoryProvider)
      .setDeviceValue(onboardingDateAnsweredKey, 'true');
  container.invalidate(userSettingsProvider);
}

DateTime _daysAhead(DateTime today, int days) =>
    DateTime(today.year, today.month, today.day + days);

/// Rebuilds the onboarding page, then lets the target step read its seed. The
/// page keeps its flow while it stays on the same address, so it is left for a
/// neighbouring onboarding screen first.
Future<void> _open(ProviderContainer container, _Plan plan) async {
  final router = container.read(routerProvider);
  if (plan.route == '/onboarding') {
    const stopover = '/onboarding/custom/name';
    router.go(stopover);
    await _settle(router, stopover);
  }
  localPresetSeed.value = plan.seed;
  router.go(plan.route);
  await _settle(router, plan.route);
  // Long enough for a rebuild caused by the refreshed answers to read it too.
  await Future<void>.delayed(const Duration(seconds: 2));
  localPresetSeed.value = null;
}

/// Waits until the router shows [path], then a moment for the screen to build.
Future<void> _settle(GoRouter router, String path) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (router.routerDelegate.currentConfiguration.uri.path != path) {
    if (DateTime.now().isAfter(deadline)) {
      localPresetSeed.value = null;
      throw TimeoutException('The router did not open $path.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  await Future<void>.delayed(const Duration(milliseconds: 100));
}
