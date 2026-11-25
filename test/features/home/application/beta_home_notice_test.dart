import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/platform/remote_flags.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/web_study_seam.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/domain/user_settings.dart';

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

void main() {
  group('betaHomeNotice', () {
    test('5 days and a sent survey, not turned on: earned', () {
      final reward = _reward(counted: 5, sent: true, eligible: true);
      final n = betaHomeNotice(reward: reward);
      expect(n?.kind, HomeNoticeKind.beta);
      expect(n?.title, 'You earned 1 year of Pro');
      expect(
        n?.detail,
        'Thank you for testing Pantas. Turn it on whenever you are ready.',
      );
      expect(n?.primaryLabel, 'See Your Reward');
      expect(n?.secondaryLabel, 'Later');
      expect(n?.route, '/settings/beta-feedback');
      expect(n?.proIcon, isTrue);
      expect(n?.dismissalToken, 'earned');
    });

    test('a reward already turned on is hidden', () {
      final reward = _reward(counted: 5, sent: true, activatedAt: ph(11, 20));
      expect(betaHomeNotice(reward: reward), isNull);
    });

    test('a tester with no earned reward sees no beta notice, any state', () {
      final states = [
        _reward(),
        _reward(counted: 0),
        _reward(counted: 5),
        _reward(counted: 4, sent: true),
        _reward(sent: true),
        // 5 days and a sent survey, but the activation deadline has passed.
        _reward(counted: 5, sent: true),
      ];
      for (final reward in states) {
        expect(
          betaHomeNotice(reward: reward),
          isNull,
          reason: '${reward.days.length} days, sent ${reward.surveySubmitted}',
        );
      }
    });

    test('no reply means no notice', () {
      expect(betaHomeNotice(reward: null), isNull);
    });
  });

  group('homeNoticeProvider', () {
    late DateTime clock;
    late Future<BetaReward?> Function() loadReward;

    setUp(() {
      clock = ph(11, 16);
      loadReward = () async => _reward();
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
          remoteFlagsProvider.overrideWithValue(RemoteFlags.parse(0, null)),
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

    test('a tester with no earned reward sees no beta notice', () async {
      final notice = await read(make());
      expect(notice?.kind, isNot(HomeNoticeKind.beta));
    });

    test('a tester with an earned, unturned reward sees the earned notice',
        () async {
      loadReward = () async => _reward(counted: 5, sent: true, eligible: true);
      final notice = await read(make());
      expect(notice?.kind, HomeNoticeKind.beta);
      expect(notice?.title, 'You earned 1 year of Pro');
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

    test('the earned notice is dismissed for good', () async {
      loadReward = () async => _reward(counted: 5, sent: true, eligible: true);
      final scope = make();
      final notice = (await read(scope))!;
      await scope.read(appPreferencesRepositoryProvider).setDeviceValue(
            'home_notice_dismissed_${notice.kind.name}',
            notice.dismissalToken,
          );
      for (final at in [ph(11, 17), ph(11, 30), ph(12, 20)]) {
        clock = at;
        scope.invalidate(homeNoticeProvider);
        expect(
          (await scope.read(homeNoticeProvider.future))?.kind,
          isNot(HomeNoticeKind.beta),
        );
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

    test('Home reads the status once, even after it lets go', () async {
      await scope.read(betaAccessProvider.future);
      final home = scope.listen(betaRewardProvider, (_, __) {});
      await scope.read(betaRewardProvider.future);
      home.close();
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
