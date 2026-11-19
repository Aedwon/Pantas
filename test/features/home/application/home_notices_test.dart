import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/screen_counts_providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/screen_counts_notice.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/web_study_seam.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

HomeNotice notice(HomeNoticeKind kind, {String token = 'yes'}) =>
    HomeNotice(kind: kind, title: kind.name, dismissalToken: token);
void main() {
  test('web welcome follows server coverage even when native Pro is active',
      () async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final scope = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        userSettingsProvider.overrideWith((_) async => UserSettings.defaults()),
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        entitlementProvider
            .overrideWith((_) => Stream.value(const Entitlement.free())),
        proForActiveExamProvider.overrideWith((_) async => true),
        studyUsesServerProvider.overrideWithValue(true),
        currentStudyCoverageProvider.overrideWithValue(false),
        webTrialEndsAtProvider.overrideWith((_) async => null),
        betaRewardProvider.overrideWith((_) async => null),
      ],
    );
    addTearDown(scope.dispose);
    // Home keeps this provider watched; hold it too, so it is not disposed
    // while the beta status loads.
    scope.listen(homeNoticeProvider, (_, __) {});
    final notice = await scope.read(homeNoticeProvider.future);
    expect(notice?.kind, isNot(HomeNoticeKind.welcome));
  });

  test(
      'notice priority is service, screen counts, beta, trial, welcome, '
      'no date, month only', () {
    expect(HomeNoticeKind.values, [
      HomeNoticeKind.service,
      HomeNoticeKind.screenCounts,
      HomeNoticeKind.beta,
      HomeNoticeKind.trial,
      HomeNoticeKind.welcome,
      HomeNoticeKind.noDate,
      HomeNoticeKind.monthOnly,
    ]);
    final candidates = [
      for (final kind in HomeNoticeKind.values.reversed) notice(kind),
    ];
    final dismissed = <HomeNoticeKind, String>{};
    for (final kind in HomeNoticeKind.values) {
      expect(selectHomeNotice(candidates, dismissed)?.kind, kind);
      dismissed[kind] = 'yes';
    }
    expect(selectHomeNotice(candidates, dismissed), isNull);
  });
  test(
      'changed service text returns '
      'while unchanged dismissed text stays closed', () {
    expect(
      selectHomeNotice(
        [notice(HomeNoticeKind.service, token: 'old')],
        {HomeNoticeKind.service: 'old'},
      ),
      isNull,
    );
    expect(
      selectHomeNotice(
        [notice(HomeNoticeKind.service, token: 'new')],
        {HomeNoticeKind.service: 'old'},
      )?.dismissalToken,
      'new',
    );
  });

  group('web trial notice', () {
    final now = DateTime(2026, 9, 30, 21);

    test('shows the approved prepaid wording with the actual end date', () {
      final result = webTrialHomeNotice(
        endsAt: DateTime(2026, 10, 2, 12),
        now: now,
      );
      expect(result?.kind, HomeNoticeKind.trial);
      expect(result?.title, 'Pro trial ends in 2 days');
      expect(
        result?.detail,
        "Your free trial ends on Oct 2. You won't be charged.",
      );
      expect(result?.primaryLabel, 'See Pro');
      expect(result?.secondaryLabel, 'Got It');
    });

    test('never prints a store charge, price or auto-renew claim', () {
      final detail = webTrialHomeNotice(
        endsAt: DateTime(2026, 10, 2),
        now: now,
      )!
          .detail!;
      expect(detail, isNot(contains('Google Play')));
      expect(detail, isNot(contains('\u20b1')));
      expect(detail, isNot(contains('Cancel')));
    });

    test('counts the actual days left', () {
      expect(
        webTrialHomeNotice(endsAt: DateTime(2026, 10), now: now)?.title,
        'Pro trial ends in 1 day',
      );
      expect(
        webTrialHomeNotice(endsAt: DateTime(2026, 9, 30, 23), now: now)?.title,
        'Pro trial ends today',
      );
    });

    test('is absent before the last two days and after it ended', () {
      expect(
        webTrialHomeNotice(endsAt: DateTime(2026, 10, 3), now: now),
        isNull,
      );
      expect(
        webTrialHomeNotice(endsAt: DateTime(2026, 9, 29), now: now),
        isNull,
      );
    });

    test('missing trial evidence means no notice', () {
      expect(webTrialHomeNotice(endsAt: null, now: now), isNull);
    });

    test('dismissal is bound to this trial end', () {
      final first = webTrialHomeNotice(
        endsAt: DateTime(2026, 10, 2),
        now: now,
      )!;
      final next = webTrialHomeNotice(
        endsAt: DateTime(2026, 10),
        now: now,
      )!;
      expect(first.dismissalToken, isNot(next.dismissalToken));
    });
  });

  group('screen counts notice', () {
    const title = 'Screen counts in speed reports';
    const detail = 'Our speed and error reports now also count how often you '
        'open each screen, to see which screens are used. Screen counts have '
        'no account ID. You can turn these reports off in Settings, then '
        'About.';

    Future<ProviderContainer> open({
      bool flag = true,
      bool web = true,
      bool speedReports = true,
      String? uid = 'learner-a',
      bool minor = false,
      String? ageGroup,
      List<String> dismissedFor = const [],
    }) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final prefs = AppPreferencesRepository(db);
      if (minor) await prefs.setAgeGroup('minor');
      if (ageGroup != null) await prefs.setAgeGroup(ageGroup);
      final store = ScreenCountsNoticeStore(prefs);
      for (final id in dismissedFor) {
        await store.markDismissed(id);
      }
      final defaults = UserSettings.defaults();
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          screenCountsFlagProvider.overrideWithValue(flag),
          screenCountsAccountIdProvider.overrideWith((_) async => uid),
          userSettingsProvider.overrideWith(
            (_) async => UserSettings(
              name: defaults.name,
              dailyReminderTime: defaults.dailyReminderTime,
              studyDays: defaults.studyDays,
              examDate: defaults.examDate,
              strictMockMode: defaults.strictMockMode,
              helpImproveApp: defaults.helpImproveApp,
              carryOverProgress: defaults.carryOverProgress,
              sessionOrdering: defaults.sessionOrdering,
              retainTableOrder: defaults.retainTableOrder,
              updatedAt: defaults.updatedAt,
              speedReportsEnabled: speedReports,
            ),
          ),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          entitlementProvider
              .overrideWith((_) => Stream.value(const Entitlement.free())),
          proForActiveExamProvider.overrideWith((_) async => false),
          studyUsesServerProvider.overrideWithValue(web),
          currentStudyCoverageProvider.overrideWithValue(false),
          webTrialEndsAtProvider.overrideWith((_) async => null),
          betaRewardProvider.overrideWith((_) async => null),
        ],
      );
      addTearDown(container.dispose);
      // Home's notice waits on the beta reward too; a listener keeps the
      // auto-dispose provider alive while it loads.
      container.listen(homeNoticeProvider, (_, __) {});
      return container;
    }

    test('shows the approved words, buttons and Privacy Notice link', () async {
      final notice = await (await open()).read(homeNoticeProvider.future);
      expect(notice?.kind, HomeNoticeKind.screenCounts);
      expect(notice?.title, title);
      expect(notice?.detail, detail);
      // Got It is the main button (right), Learn More the secondary (left).
      expect(notice?.primaryLabel, 'Got It');
      expect(notice?.secondaryLabel, 'Learn More');
      expect(notice?.route, '/legal/privacy');
    });

    test('an under-18 account opens the Teen Notice', () async {
      final notice =
          await (await open(minor: true)).read(homeNoticeProvider.future);
      expect(notice?.kind, HomeNoticeKind.screenCounts);
      expect(notice?.route, '/legal/teens');
    });

    test('a child has no screen counts notice with a saved opt-in', () async {
      final notice =
          await (await open(ageGroup: 'child')).read(homeNoticeProvider.future);
      expect(notice?.kind, isNot(HomeNoticeKind.screenCounts));
    });

    test('is absent while the flag is off', () async {
      final notice =
          await (await open(flag: false)).read(homeNoticeProvider.future);
      expect(notice?.kind, isNot(HomeNoticeKind.screenCounts));
    });

    test('is absent when the speed reports switch is off', () async {
      final notice = await (await open(speedReports: false))
          .read(homeNoticeProvider.future);
      expect(notice?.kind, isNot(HomeNoticeKind.screenCounts));
    });

    test('is absent outside the web app', () async {
      final notice =
          await (await open(web: false)).read(homeNoticeProvider.future);
      expect(notice?.kind, isNot(HomeNoticeKind.screenCounts));
    });

    test('is absent when nobody is signed in', () async {
      final notice =
          await (await open(uid: null)).read(homeNoticeProvider.future);
      expect(notice?.kind, isNot(HomeNoticeKind.screenCounts));
    });

    test('closed by one learner, it still shows for another', () async {
      final closed = await (await open(dismissedFor: ['learner-a']))
          .read(homeNoticeProvider.future);
      expect(closed?.kind, isNot(HomeNoticeKind.screenCounts));
      final other = await (await open(
        uid: 'learner-b',
        dismissedFor: ['learner-a'],
      ))
          .read(homeNoticeProvider.future);
      expect(other?.kind, HomeNoticeKind.screenCounts);
    });

    test('ranks after a service message and ahead of the others', () {
      expect(
        HomeNoticeKind.values.take(2),
        [HomeNoticeKind.service, HomeNoticeKind.screenCounts],
      );
    });
  });
}
