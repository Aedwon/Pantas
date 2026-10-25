import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/platform/remote_flags_providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/web_study_seam.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/trial_notice.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

enum HomeNoticeKind { service, trial, welcome, noDate, monthOnly }

class HomeNotice {
  const HomeNotice({
    required this.kind,
    required this.title,
    required this.dismissalToken,
    this.detail,
    this.primaryLabel,
    this.secondaryLabel,
  });
  final HomeNoticeKind kind;
  final String title;
  final String dismissalToken;
  final String? detail;
  final String? primaryLabel;
  final String? secondaryLabel;
}

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
        'You won\u2019t be charged.',
    dismissalToken:
        DateTime(endsAt.year, endsAt.month, endsAt.day).toIso8601String(),
    primaryLabel: 'See Pro',
    secondaryLabel: 'Got It',
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
        detail: "It's $month. Your plan is paced to the end of the month "
            'until you pick the day.',
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
