import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/screen_counts_providers.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/web_study_seam.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/trial_notice.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

/// In priority order: Home shows the first one that applies and is not
/// dismissed. Screen counts comes before beta (DS4 lead, Nov 16): it is a
/// one-time privacy notice, while the beta notice comes back each day, so it
/// loses at most one day's showing.
enum HomeNoticeKind {
  service,
  screenCounts,
  beta,
  trial,
  welcome,
  noDate,
  monthOnly,
}

class HomeNotice {
  const HomeNotice({
    required this.kind,
    required this.title,
    required this.dismissalToken,
    this.detail,
    this.primaryLabel,
    this.secondaryLabel,
    this.route,
    this.proIcon = false,
  });
  final HomeNoticeKind kind;
  final String title;
  final String dismissalToken;
  final String? detail;
  final String? primaryLabel;
  final String? secondaryLabel;

  /// The page the notice's link opens, pushed outside the tab shell. The
  /// beta notice's main button opens it; the screen counts notice's Learn
  /// More (its secondary button) opens it.
  final String? route;

  /// Draws the Pro mark in the accent color instead of the kind's own icon.
  final bool proIcon;
}

/// The approved words, `step2-launch-texts.md` section 1.
const screenCountsNoticeTitle = 'Screen counts in speed reports';
const screenCountsNoticeText =
    'Our speed and error reports now also count how often you open each '
    'screen, to see which screens are used. Screen counts have no account ID. '
    'You can turn these reports off in Settings, then About.';

String _trialTitle(int days) => days == 0
    ? 'Pro trial ends today'
    : 'Pro trial ends in $days ${days == 1 ? "day" : "days"}';

/// The web trial is a prepaid server grant with no automatic charge, so the
/// notice keeps HP_Trial's strip but never states a store charge or a price
/// (approved wording, proposal v1, 24 October 2026). Same two-day window as
/// the native notice. Missing trial evidence means no notice.
HomeNotice? webTrialHomeNotice({
  required DateTime? endsAt,
  required DateTime now,
}) {
  if (endsAt == null) return null;
  final days = DateTime.utc(endsAt.year, endsAt.month, endsAt.day)
      .difference(DateTime.utc(now.year, now.month, now.day))
      .inDays;
  if (days < 0 || days > 2) return null;
  return HomeNotice(
    kind: HomeNoticeKind.trial,
    title: _trialTitle(days),
    detail: 'Your free trial ends on ${PantasDates.short(endsAt, now: now)}. '
        "You won't be charged.",
    dismissalToken:
        DateTime(endsAt.year, endsAt.month, endsAt.day).toIso8601String(),
    primaryLabel: 'See Pro',
    secondaryLabel: 'Got It',
  );
}

/// The survey page and the Feedback (Beta) page, where the reward is turned
/// on.
const betaNoticeSurveyRoute = '/settings/beta-feedback/survey';
const betaNoticeFeedbackRoute = '/settings/beta-feedback';

const _betaNeedSurvey = 'Send the exit survey by';

/// The tester's Philippine wall clock, as a UTC `DateTime`.
DateTime _manila(DateTime instant) =>
    instant.toUtc().add(const Duration(hours: 8));

String _manilaKey(DateTime manila) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${manila.year}-${two(manila.month)}-${two(manila.day)}';
}

String _monthDay(DateTime manila) =>
    DateFormat('MMM d', 'en_US').format(manila);

/// The Home notice for a beta tester, or null when there is nothing to say.
///
/// Every count and date is the server's: the counted days, the beta dates
/// (the end is the last one) and when the survey closes (the last day to send
/// it is the day before). Whether 5 days can still be reached is not in the
/// reply, so it is the counted days plus the uncounted beta dates from today
/// in Manila on. The token holds the state and the Manila day, so Later hides
/// it until either changes. The earned notice has one token for good.
HomeNotice? betaHomeNotice({
  required BetaReward? reward,
  required DateTime now,
}) {
  if (reward == null || reward.activated) return null;
  final counted = reward.days.length;
  if (reward.eligible && reward.surveySubmitted) {
    return const HomeNotice(
      kind: HomeNoticeKind.beta,
      title: 'You earned 1 year of Pro',
      detail: 'Thank you for testing Pantas. '
          'Turn it on whenever you are ready.',
      dismissalToken: 'earned',
      primaryLabel: 'See Your Reward',
      secondaryLabel: 'Later',
      route: betaNoticeFeedbackRoute,
      proIcon: true,
    );
  }
  if (reward.betaDays.isEmpty) return null;
  if (now.isBefore(reward.surveyOpensAt) ||
      !now.isBefore(reward.surveyClosesAt)) {
    return null;
  }
  final today = _manilaKey(_manila(now));
  final lastBetaDay =
      reward.betaDays.reduce((a, b) => a.compareTo(b) >= 0 ? a : b);
  final ends = _monthDay(DateTime.parse('${lastBetaDay}T00:00:00Z'));
  final by = _monthDay(
    _manila(reward.surveyClosesAt.subtract(const Duration(milliseconds: 1))),
  );
  final left = reward.betaDays
      .where((d) => d.compareTo(today) >= 0 && !reward.days.contains(d))
      .length;
  final reachable = counted >= 5 || counted + left >= 5;

  final String key;
  final String title;
  final String detail;
  final String primary;
  final String route;
  if (reward.surveySubmitted) {
    if (counted >= 5 || !reachable) return null;
    key = 'sent:$counted';
    title = '$counted of 5 beta days. Ends $ends.';
    detail = 'A day counts when you finish your whole Today plan. '
        'Reach 5 by $ends to earn 1 year of Pro.';
    primary = 'See Your Days';
    route = betaNoticeFeedbackRoute;
  } else {
    primary = 'Take the Survey';
    route = betaNoticeSurveyRoute;
    if (counted >= 5) {
      key = 'five';
      title = '$_betaNeedSurvey $by';
      detail = 'It has 7 short questions. Send it to earn 1 year of Pro.';
    } else if (reachable) {
      key = 'days:$counted';
      title = '$counted of 5 beta days. Ends $ends.';
      detail = 'A day counts when you finish your whole Today plan. '
          'Reach 5 by $ends and send the exit survey to earn 1 year of Pro.';
    } else {
      key = 'last';
      title = '$_betaNeedSurvey $by';
      detail = 'It has 7 short questions. '
          'Tell us what worked and what to fix.';
    }
  }
  return HomeNotice(
    kind: HomeNoticeKind.beta,
    title: title,
    detail: detail,
    dismissalToken: '$key|$today',
    primaryLabel: primary,
    secondaryLabel: 'Later',
    route: route,
  );
}

HomeNotice? selectHomeNotice(
  List<HomeNotice> candidates,
  Map<HomeNoticeKind, String> dismissed,
) {
  for (final kind in HomeNoticeKind.values) {
    final notice = candidates.firstWhereOrNull((n) => n.kind == kind);
    if (notice != null && dismissed[kind] != notice.dismissalToken) {
      return notice;
    }
  }
  return null;
}

final homeNoticeProvider = FutureProvider.autoDispose<HomeNotice?>((ref) async {
  final flags = ref.watch(remoteFlagsProvider);
  final settings = await ref.watch(userSettingsProvider.future);
  final focus = await ref.watch(activeExamFocusProvider.future);
  final server = ref.watch(studyUsesServerProvider);
  final entitlement =
      server ? null : await ref.watch(entitlementProvider.future);
  final pro = server
      ? ref.watch(currentStudyCoverageProvider)
      : await ref.watch(proForActiveExamProvider.future);
  final preferences = ref.read(appPreferencesRepositoryProvider);
  final now = ref.read(nowProvider)();
  final candidates = <HomeNotice>[];
  final service = flags.serviceMessage;
  if (service != null) {
    candidates.add(
      HomeNotice(
        kind: HomeNoticeKind.service,
        title: service,
        dismissalToken: service,
      ),
    );
  }
  if (server &&
      ref.watch(screenCountsFlagProvider) &&
      settings.speedReportsEnabled &&
      !(await ref.watch(ageGroupProvider.future)).hasChildLimits) {
    final accountId = await ref.watch(screenCountsAccountIdProvider.future);
    final store = ref.read(screenCountsNoticeStoreProvider);
    if (accountId != null && !await store.isDismissed(accountId)) {
      final teen = ref.watch(resolvedAgeGroupProvider).entersTeenGuardianFlow;
      candidates.add(
        HomeNotice(
          kind: HomeNoticeKind.screenCounts,
          title: screenCountsNoticeTitle,
          detail: screenCountsNoticeText,
          // The account the notice is shown to. It is stored on this device
          // only and never sent anywhere.
          dismissalToken: accountId,
          // Got It is the main button, on the right. Learn More is the
          // secondary, on the left.
          primaryLabel: 'Got It',
          secondaryLabel: 'Learn More',
          // The legal pages have no section anchors, so both open at the top.
          route: teen ? '/legal/teens' : '/legal/privacy',
        ),
      );
    }
  }
  final beta = betaHomeNotice(
    reward: ref.watch(betaRewardProvider).valueOrNull,
    now: ref.read(betaFeedbackClockProvider)(),
  );
  if (beta != null) candidates.add(beta);
  if (server) {
    final webTrial = webTrialHomeNotice(
      endsAt: await ref.watch(webTrialEndsAtProvider.future),
      now: now,
    );
    if (webTrial != null) candidates.add(webTrial);
  }
  final trial =
      server ? null : TrialNotice.fromEntitlement(entitlement!, today: now);
  if (trial != null) {
    final offering = await ref.watch(paywallOfferingProvider.future);
    final package = offering.recognizedPackages
        .firstWhereOrNull((p) => p.productId == entitlement!.productId);
    if (package != null) {
      candidates.add(
        HomeNotice(
          kind: HomeNoticeKind.trial,
          title: _trialTitle(trial.daysRemaining),
          detail: 'Google Play charges ${package.priceString} '
              'on ${PantasDates.short(trial.chargeDate, now: now)} '
              'to keep Pro. Cancel any time before then.',
          dismissalToken: trial.chargeDate.toIso8601String(),
          primaryLabel: 'Manage',
          secondaryLabel: 'Got It',
        ),
      );
    }
  }
  if (pro) {
    candidates.add(
      const HomeNotice(
        kind: HomeNoticeKind.welcome,
        title: "You're in. Welcome to Pro.",
        detail: 'Topics, lessons and your tendencies are open now.',
        dismissalToken: 'yes',
        primaryLabel: "See What's New",
        secondaryLabel: 'Got It',
      ),
    );
  }
  final date = settings.examDate;
  if (date == null) {
    candidates.add(
      const HomeNotice(
        kind: HomeNoticeKind.noDate,
        title: 'Add your exam date',
        detail: 'Your plan paces each day to it. '
            'Until then, today is reviews only.',
        dismissalToken: 'yes',
        primaryLabel: 'Add Exam Date',
        secondaryLabel: 'Later',
      ),
    );
  }
  if (date != null &&
      date.day == null &&
      date.year == now.year &&
      date.month == now.month) {
    final month = DateFormat('MMMM', 'en_US').format(date.monthStart);
    candidates.add(
      HomeNotice(
        kind: HomeNoticeKind.monthOnly,
        title:
            'Do you know the day of your ${focus.exam?.shortName ?? "exam"}?',
        detail: 'Until then, your plan is paced to the end of $month.',
        dismissalToken: date.storageValue,
        primaryLabel: 'Save',
        secondaryLabel: 'Not Yet',
      ),
    );
  }
  final dismissed = <HomeNoticeKind, String>{};
  for (final kind in HomeNoticeKind.values) {
    final token =
        await preferences.deviceValue('home_notice_dismissed_${kind.name}');
    if (token != null) dismissed[kind] = token;
  }
  return selectHomeNotice(candidates, dismissed);
});
