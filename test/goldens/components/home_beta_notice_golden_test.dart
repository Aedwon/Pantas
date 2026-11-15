import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/presentation/widgets/home_notice_strip.dart';

import '../golden_harness.dart';

final _fourteen = [
  for (var d = 9; d <= 22; d++) '2026-11-${d.toString().padLeft(2, '0')}',
];

/// A Philippine wall-clock time, as the instant it is.
DateTime _ph(int month, int day, [int hour = 12]) =>
    DateTime.utc(2026, month, day, hour).subtract(const Duration(hours: 8));

BetaReward _reward({
  required int counted,
  bool sent = false,
  bool eligible = false,
}) =>
    BetaReward(
      days: _fourteen.take(counted).toList(),
      betaDays: _fourteen,
      surveyOpensAt: _ph(11, 15, 0),
      surveyClosesAt: _ph(11, 24, 0),
      surveySubmitted: sent,
      eligible: eligible,
      activationDeadline: DateTime.utc(2027, 12, 31, 16),
    );

HomeNotice _notice(BetaReward reward, DateTime now) =>
    betaHomeNotice(reward: reward, now: now)!;

/// The real Home strip with the beta notice, opened by tapping its head.
GoldenState _state(
  String label,
  HomeNotice notice, {
  required double width,
  required bool web,
}) =>
    GoldenState(
      label,
      (_) => ProviderScope(
        overrides: [homeNoticeProvider.overrideWith((ref) async => notice)],
        child: HomeNoticeStrip(onDate: (_) {}, onRoute: (_) {}),
      ),
      width: width,
      web: web,
      action: GoldenAction.tap,
      target: () => find.text(notice.title),
    );

void main() {
  final days = _notice(_reward(counted: 2), _ph(11, 16));
  final five = _notice(_reward(counted: 5), _ph(11, 18));
  final last = _notice(_reward(counted: 2), _ph(11, 21));
  final sent = _notice(_reward(counted: 2, sent: true), _ph(11, 16));
  final earned = _notice(
    _reward(counted: 5, sent: true, eligible: true),
    _ph(11, 19),
  );
  goldenSheet(
    'home_beta_notice',
    [
      _state('Phone 390, days', days, width: 390, web: false),
      _state('Phone 390, 5 days', five, width: 390, web: false),
      _state('Phone 390, 5 unreachable', last, width: 390, web: false),
      _state('Phone 390, survey sent', sent, width: 390, web: false),
      _state('Phone 390, earned', earned, width: 390, web: false),
      _state('Web 1440, days', days, width: 1440, web: true),
      _state('Web 1440, earned', earned, width: 1440, web: true),
    ],
    cellWidth: 1440,
    columns: 1,
  );
}
