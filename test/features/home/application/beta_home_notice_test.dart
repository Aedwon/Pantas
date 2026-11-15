import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/platform/remote_flags.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/beta_feedback/presentation/days_card.dart';
import 'package:pantas/features/beta_feedback/presentation/exit_survey_page.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/web_study_seam.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import '../../beta_feedback/presentation/beta_feedback_fakes.dart';

/// The fourteen beta dates the server returns.
final _fourteen = [
  for (var d = 9; d <= 22; d++) '2026-11-${d.toString().padLeft(2, '0')}',
];

List<String> _counted(int n) => _fourteen.take(n).toList();

/// A server reply as it stands in the beta: the survey closes Nov 24 00:00
/// Manila time.
BetaReward _reward({
  int counted = 2,
  List<String>? days,
  bool sent = false,
  bool eligible = false,
  DateTime? activatedAt,
  List<String>? betaDays,
  DateTime? closes,
}) =>
    BetaReward(
      days: days ?? _counted(counted),
      betaDays: betaDays ?? _fourteen,
      surveyOpensAt: ph(11, 15, 0),
      surveyClosesAt: closes ?? ph(11, 24, 0),
      surveySubmitted: sent,
      eligible: eligible,
      activationDeadline: ph(1, 1, 0, 0, 2028),
      activatedAt: activatedAt,
    );

const _progressDetail = 'A day counts when you finish your whole Today plan. '
    'Reach 5 by Nov 22 and send the exit survey to earn 1 year of Pro.';

void main() {
  group('betaHomeNotice states', () {
    test('under 5 and 5 reachable: the count, the end and the survey', () {
      final n = betaHomeNotice(reward: _reward(), now: ph(11, 16));
      expect(n?.kind, HomeNoticeKind.beta);
      expect(n?.title, '2 of 5 beta days. Ends Nov 22.');
      expect(n?.detail, _progressDetail);
      expect(n?.primaryLabel, 'Take the Survey');
      expect(n?.secondaryLabel, 'Later');
      expect(n?.route, surveyPath);
      expect(n?.proIcon, isFalse);
    });

    test('zero days still shows the count', () {
      final n = betaHomeNotice(reward: _reward(counted: 0), now: ph(11, 16));
      expect(n?.title, '0 of 5 beta days. Ends Nov 22.');
    });

    test('5 days, survey not sent: send it to earn the year', () {
      final n = betaHomeNotice(reward: _reward(counted: 5), now: ph(11, 18));
      expect(n?.title, 'Send the exit survey by Nov 23');
      expect(
        n?.detail,
        'It has 7 short questions. Send it to earn 1 year of Pro.',
      );
      expect(n?.primaryLabel, 'Take the Survey');
      expect(n?.secondaryLabel, 'Later');
      expect(n?.route, surveyPath);
    });

    test('5 unreachable: same title, no reward promise', () {
      // 2 days counted, 2 beta days left (Nov 21 and 22): at most 4.
      final n = betaHomeNotice(reward: _reward(), now: ph(11, 21));
      expect(n?.title, 'Send the exit survey by Nov 23');
      expect(
        n?.detail,
        'It has 7 short questions. Tell us what worked and what to fix.',
      );
      expect(n?.primaryLabel, 'Take the Survey');
      expect(n?.route, surveyPath);
    });

    test('5 is still reachable when every remaining day is needed', () {
      // 2 counted, Nov 20, 21 and 22 left: exactly 5.
      final n = betaHomeNotice(reward: _reward(), now: ph(11, 20));
      expect(n?.title, '2 of 5 beta days. Ends Nov 22.');
    });

    test('a day already counted today is not counted twice', () {
      // Nov 9, 10 and 21 counted; only Nov 22 is left: at most 4.
      final n = betaHomeNotice(
        reward: _reward(days: ['2026-11-09', '2026-11-10', '2026-11-21']),
        now: ph(11, 21),
      );
      expect(n?.title, 'Send the exit survey by Nov 23');
    });

    test('on Nov 23 with under 5 days: the unreachable wording', () {
      final n = betaHomeNotice(reward: _reward(counted: 4), now: ph(11, 23));
      expect(n?.title, 'Send the exit survey by Nov 23');
      expect(
        n?.detail,
        'It has 7 short questions. Tell us what worked and what to fix.',
      );
    });

    test('on Nov 23 with 5 days the reward is still on offer', () {
      final n =
          betaHomeNotice(reward: _reward(counted: 5), now: ph(11, 23, 23));
      expect(
        n?.detail,
        'It has 7 short questions. Send it to earn 1 year of Pro.',
      );
    });

    test('survey sent, under 5, reachable: no survey clause', () {
      final n = betaHomeNotice(
        reward: _reward(sent: true),
        now: ph(11, 16),
      );
      expect(n?.title, '2 of 5 beta days. Ends Nov 22.');
      expect(
        n?.detail,
        'A day counts when you finish your whole Today plan. '
        'Reach 5 by Nov 22 to earn 1 year of Pro.',
      );
      expect(n?.primaryLabel, 'See Your Days');
      expect(n?.secondaryLabel, 'Later');
      expect(n?.route, feedbackPath);
    });

    test('survey sent, under 5, unreachable: nothing left to say', () {
      expect(
        betaHomeNotice(reward: _reward(sent: true), now: ph(11, 22)),
        isNull,
      );
    });

    test('survey sent and 5 days, not turned on: earned', () {
      final n = betaHomeNotice(
        reward: _reward(counted: 5, sent: true, eligible: true),
        now: ph(11, 19),
      );
      expect(n?.title, 'You earned 1 year of Pro');
      expect(
        n?.detail,
        'Thank you for testing Pantas. Turn it on whenever you are ready.',
      );
      expect(n?.primaryLabel, 'See Your Reward');
      expect(n?.secondaryLabel, 'Later');
      expect(n?.route, feedbackPath);
      expect(n?.proIcon, isTrue);
    });

    test('earned outlives the survey close and every other state', () {
      final n = betaHomeNotice(
        reward: _reward(counted: 5, sent: true, eligible: true),
        now: ph(12, 5),
      );
      expect(n?.title, 'You earned 1 year of Pro');
    });

    test('a reward already turned on is hidden', () {
      expect(
        betaHomeNotice(
          reward: _reward(
            counted: 5,
            sent: true,
            activatedAt: ph(11, 20),
          ),
          now: ph(11, 21),
        ),
        isNull,
      );
    });

    test('every state except earned ends Nov 24 00:00 Manila', () {
      final reward = _reward();
      expect(
        betaHomeNotice(reward: reward, now: ph(11, 23, 23, 59)),
        isNotNull,
      );
      expect(betaHomeNotice(reward: reward, now: ph(11, 24, 0)), isNull);
      expect(
        betaHomeNotice(reward: _reward(counted: 5), now: ph(11, 24, 0, 1)),
        isNull,
      );
    });

    test('hidden before the survey opens, when its button would bounce', () {
      expect(betaHomeNotice(reward: _reward(), now: ph(11, 14, 23)), isNull);
    });

    test('no reply means no notice', () {
      expect(betaHomeNotice(reward: null, now: ph(11, 16)), isNull);
    });

    test('every date comes from the server reply', () {
      final shifted = [
        for (var d = 12; d <= 25; d++) '2026-11-$d',
      ];
      final n = betaHomeNotice(
        reward: _reward(
          days: const [],
          betaDays: shifted,
          closes: ph(11, 27, 0),
        ),
        now: ph(11, 16),
      );
      expect(n?.title, '0 of 5 beta days. Ends Nov 25.');
      expect(n?.detail, contains('Reach 5 by Nov 25 and'));
      final five = betaHomeNotice(
        reward: _reward(
          counted: 5,
          betaDays: shifted,
          closes: ph(11, 27, 0),
        ),
        now: ph(11, 16),
      );
      expect(five?.title, 'Send the exit survey by Nov 26');
    });

    test('the day is the Manila day, not the device day', () {
      // 22:00 UTC on Nov 20 is already Nov 21 in Manila: 2 + 2 days left.
      final n = betaHomeNotice(
        reward: _reward(),
        now: DateTime.utc(2026, 11, 20, 22),
      );
      expect(n?.title, 'Send the exit survey by Nov 23');
    });

    test('the token holds the state and the Manila day', () {
      String? token(BetaReward r, DateTime at) =>
          betaHomeNotice(reward: r, now: at)?.dismissalToken;
      final base = token(_reward(), ph(11, 16, 9));
      expect(token(_reward(), ph(11, 16, 21)), base);
      expect(token(_reward(), ph(11, 17, 9)), isNot(base));
      expect(token(_reward(counted: 3), ph(11, 16, 9)), isNot(base));
      expect(token(_reward(sent: true), ph(11, 16, 9)), isNot(base));
      expect(token(_reward(counted: 5), ph(11, 16, 9)), isNot(base));
    });

    test('the earned token never changes', () {
      String? token(DateTime at) => betaHomeNotice(
            reward: _reward(counted: 5, sent: true, eligible: true),
            now: at,
          )?.dismissalToken;
      expect(token(ph(11, 16)), token(ph(11, 22)));
      expect(token(ph(11, 16)), token(ph(12, 3)));
    });
  });

  // Screen counts goes first when both apply (DS4 lead, Nov 16): it is a
  // one-time privacy notice; the beta notice comes back the next day.
  test('the beta notice comes after the service and screen counts notices', () {
    expect(
      HomeNoticeKind.values.indexOf(HomeNoticeKind.beta),
      HomeNoticeKind.values.indexOf(HomeNoticeKind.screenCounts) + 1,
    );
  });

  group('homeNoticeProvider', () {
    late DateTime clock;
    late Future<BetaReward?> Function() loadReward;
    late String? service;

    setUp(() {
      clock = ph(11, 16);
      loadReward = () async => _reward();
      service = null;
    });

    ProviderContainer make() {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final scope = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          userSettingsProvider
              .overrideWith((_) async => UserSettings.defaults()),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          entitlementProvider
              .overrideWith((_) => Stream.value(const Entitlement.free())),
          proForActiveExamProvider.overrideWith((_) async => false),
          studyUsesServerProvider.overrideWithValue(true),
          currentStudyCoverageProvider.overrideWithValue(false),
          webTrialEndsAtProvider.overrideWith((_) async => null),
          remoteFlagsProvider.overrideWithValue(RemoteFlags.parse(0, service)),
          betaRewardProvider.overrideWith((_) => loadReward()),
          betaFeedbackClockProvider.overrideWithValue(() => clock),
        ],
      );
      addTearDown(scope.dispose);
      return scope;
    }

    Future<HomeNotice?> read(ProviderContainer scope) async {
      scope.listen(homeNoticeProvider, (_, __) {});
      await scope.read(betaRewardProvider.future).catchError((_) => null);
      return scope.read(homeNoticeProvider.future);
    }

    test('a tester sees the beta notice', () async {
      final notice = await read(make());
      expect(notice?.kind, HomeNoticeKind.beta);
      expect(notice?.title, '2 of 5 beta days. Ends Nov 22.');
    });

    test('a non-tester sees none', () async {
      loadReward = () async => null;
      final notice = await read(make());
      expect(notice?.kind, isNot(HomeNoticeKind.beta));
    });

    test('a failed status load shows none', () async {
      loadReward = () async => throw const BetaFeedbackException(
            BetaFeedbackFailure.other,
          );
      final notice = await read(make());
      expect(notice?.kind, isNot(HomeNoticeKind.beta));
    });

    test('the service message goes first, then the beta notice', () async {
      service = 'Maintenance tonight';
      final scope = make();
      expect((await read(scope))?.kind, HomeNoticeKind.service);
      await scope.read(appPreferencesRepositoryProvider).setDeviceValue(
            'home_notice_dismissed_service',
            'Maintenance tonight',
          );
      scope.invalidate(homeNoticeProvider);
      expect(
        (await scope.read(homeNoticeProvider.future))?.kind,
        HomeNoticeKind.beta,
      );
    });

    // Other notices (the missing exam date) may still show.
    Future<void> noBeta(ProviderContainer scope) async => expect(
          (await scope.read(homeNoticeProvider.future))?.kind,
          isNot(HomeNoticeKind.beta),
        );

    Future<void> later(ProviderContainer scope, HomeNotice notice) async {
      await scope.read(appPreferencesRepositoryProvider).setDeviceValue(
            'home_notice_dismissed_${notice.kind.name}',
            notice.dismissalToken,
          );
      scope.invalidate(homeNoticeProvider);
    }

    test('Later hides it until the next Manila day', () async {
      final scope = make();
      final notice = (await read(scope))!;
      await later(scope, notice);
      expect(
        (await scope.read(homeNoticeProvider.future))?.kind,
        isNot(HomeNoticeKind.beta),
      );
      // Same Manila day, hours later: still hidden.
      clock = ph(11, 16, 23, 59);
      scope.invalidate(homeNoticeProvider);
      await noBeta(scope);
      clock = ph(11, 17, 0, 1);
      scope.invalidate(homeNoticeProvider);
      expect(
        (await scope.read(homeNoticeProvider.future))?.kind,
        HomeNoticeKind.beta,
      );
    });

    test('a state change shows it again on the same day', () async {
      final scope = make();
      await later(scope, (await read(scope))!);
      await noBeta(scope);
      loadReward = () async => _reward(counted: 3);
      scope.invalidate(betaRewardProvider);
      await scope.read(betaRewardProvider.future);
      final next = await scope.read(homeNoticeProvider.future);
      expect(next?.title, '3 of 5 beta days. Ends Nov 22.');
    });

    test('the earned notice is dismissed for good', () async {
      loadReward = () async => _reward(counted: 5, sent: true, eligible: true);
      final scope = make();
      final notice = (await read(scope))!;
      expect(notice.title, 'You earned 1 year of Pro');
      await later(scope, notice);
      await noBeta(scope);
      for (final at in [ph(11, 17), ph(11, 30), ph(12, 20)]) {
        clock = at;
        scope.invalidate(homeNoticeProvider);
        await noBeta(scope);
      }
    });
  });

  group('one status call per session', () {
    late _CountingApi api;
    late ProviderContainer scope;

    setUp(() {
      api = _CountingApi(_reward());
      final db = inMemoryDatabase();
      addTearDown(db.close);
      scope = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          betaAccessProvider.overrideWith((_) async => BetaAccess.open),
          betaFeedbackApiProvider.overrideWithValue(api),
        ],
      );
      addTearDown(scope.dispose);
      scope.listen(betaAccessProvider, (_, __) {});
    });

    test('Home and Settings share one call, even after both let go', () async {
      await scope.read(betaAccessProvider.future);
      final home = scope.listen(betaRewardProvider, (_, __) {});
      await scope.read(betaRewardProvider.future);
      final row = scope.listen(feedbackRowValueProvider, (_, __) {});
      await Future<void>.delayed(Duration.zero);
      expect(row.read(), '2 of 5 days');
      home.close();
      row.close();
      await Future<void>.delayed(Duration.zero);
      await scope.read(betaRewardProvider.future);
      scope.listen(betaRewardProvider, (_, __) {});
      await scope.read(betaRewardProvider.future);
      expect(api.reads, 1);
    });

    test('an invalidation asks the server again, once', () async {
      await scope.read(betaAccessProvider.future);
      scope.listen(betaRewardProvider, (_, __) {});
      await scope.read(betaRewardProvider.future);
      api.reply = _reward(counted: 3);
      scope.invalidate(betaRewardProvider);
      final next = await scope.read(betaRewardProvider.future);
      expect(next?.days, hasLength(3));
      expect(api.reads, 2);
    });
  });
}

class _CountingApi extends FakeBetaFeedbackApi {
  _CountingApi(this.reply);
  BetaReward reply;
  int reads = 0;

  @override
  Future<BetaReward> reward() async {
    reads++;
    return reply;
  }
}
