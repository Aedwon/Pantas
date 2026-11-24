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

BetaReward _earnedReward() => BetaReward(
      days: _fourteen.take(5).toList(),
      betaDays: _fourteen,
      surveyOpensAt: _ph(11, 15, 0),
      surveyClosesAt: _ph(11, 24, 0),
      surveySubmitted: true,
      eligible: true,
      activationDeadline: DateTime.utc(2027, 12, 31, 16),
    );

/// The real Home strip with the earned notice, opened by tapping its head.
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
  final earned = betaHomeNotice(reward: _earnedReward())!;
  goldenSheet(
    'home_beta_notice',
    [
      _state('Phone 390, earned', earned, width: 390, web: false),
      _state('Web 1440, earned', earned, width: 1440, web: true),
    ],
    cellWidth: 1440,
    columns: 1,
  );
}
