import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/features/beta_feedback/application/beta_feedback_providers.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';

/// Nov 9 to 15, as the server returns them.
const betaDays = [
  '2026-11-09',
  '2026-11-10',
  '2026-11-11',
  '2026-11-12',
  '2026-11-13',
  '2026-11-14',
  '2026-11-15',
];

/// The instant of a Philippine wall-clock time (UTC+8, no daylight time).
DateTime ph(
  int month,
  int day, [
  int hour = 12,
  int minute = 0,
  int year = 2026,
]) =>
    DateTime.utc(year, month, day, hour, minute)
        .subtract(const Duration(hours: 8));

BetaReward fakeReward({
  List<String> days = const ['2026-11-09', '2026-11-10', '2026-11-11'],
  bool surveySubmitted = false,
  bool eligible = false,
  DateTime? activatedAt,
  DateTime? rewardStartsAt,
  DateTime? rewardEndsAt,
}) =>
    BetaReward(
      days: days,
      betaDays: betaDays,
      surveyOpensAt: ph(11, 15, 0),
      surveyClosesAt: ph(11, 23, 0),
      surveySubmitted: surveySubmitted,
      eligible: eligible,
      activationDeadline: ph(1, 1, 0, 0, 2028),
      activatedAt: activatedAt,
      rewardStartsAt: rewardStartsAt,
      rewardEndsAt: rewardEndsAt,
    );

class FakeBetaFeedbackApi implements BetaFeedbackApi {
  FakeBetaFeedbackApi({BetaReward? reward, this.rewardGate})
      : rewardValue = reward ?? fakeReward();

  BetaReward rewardValue;
  Completer<void>? rewardGate;
  int activations = 0;

  /// How many times the status was asked of the server.
  int rewardReads = 0;
  Completer<BetaRewardActivation>? activateGate;
  Exception? activateError;

  @override
  Future<BetaReward> reward() async {
    rewardReads++;
    final gate = rewardGate;
    if (gate != null) await gate.future;
    return rewardValue;
  }

  @override
  Future<BetaRewardActivation> activate() async {
    activations++;
    final gate = activateGate;
    if (gate != null) return gate.future;
    final error = activateError;
    if (error != null) throw error;
    return BetaRewardActivation(
      startsAt: ph(11, 20),
      endsAt: ph(11, 20, 12, 0, 2027),
    );
  }
}

/// Counts entitlement reads, so a test can check Pro is read again.
class CountingGateway extends DisabledRevenueCatGateway {
  CountingGateway();

  int restores = 0;

  @override
  Future<PaymentOperationResult> restorePurchases() {
    restores++;
    return super.restorePurchases();
  }
}

/// The overrides every reward test needs. [now] is the beta clock.
List<Override> betaOverrides({
  required FakeBetaFeedbackApi api,
  required DateTime now,
  bool tester = true,
}) =>
    [
      betaAccessProvider.overrideWith(
        (ref) async => tester ? BetaAccess.open : BetaAccess.denied,
      ),
      betaFeedbackApiProvider.overrideWithValue(api),
      betaFeedbackClockProvider.overrideWithValue(() => now),
    ];
