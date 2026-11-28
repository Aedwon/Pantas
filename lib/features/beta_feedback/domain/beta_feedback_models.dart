import 'package:meta/meta.dart';

/// The tester's reward status, as `getBetaReward` returns it.
@immutable
class BetaReward {
  const BetaReward({
    required this.days,
    required this.betaDays,
    required this.surveyOpensAt,
    required this.surveyClosesAt,
    required this.surveySubmitted,
    required this.eligible,
    required this.activationDeadline,
    this.activatedAt,
    this.rewardStartsAt,
    this.rewardEndsAt,
  });

  /// Counted Philippine dates, `YYYY-MM-DD`.
  final List<String> days;

  /// The fourteen beta dates, Nov 9 to 22, `YYYY-MM-DD`.
  final List<String> betaDays;
  final DateTime surveyOpensAt;
  final DateTime surveyClosesAt;
  final bool surveySubmitted;

  /// 5 days, a sent survey and the deadline not passed.
  final bool eligible;
  final DateTime activationDeadline;
  final DateTime? activatedAt;
  final DateTime? rewardStartsAt;
  final DateTime? rewardEndsAt;

  bool get activated => activatedAt != null;
}

/// What `activateBetaReward` returns.
@immutable
class BetaRewardActivation {
  const BetaRewardActivation({required this.startsAt, required this.endsAt});
  final DateTime startsAt;
  final DateTime endsAt;
}

/// A callable error the screens show differently from a network failure.
enum BetaFeedbackFailure {
  /// `failed-precondition`: a reward condition is unmet or the deadline
  /// passed.
  notAllowed,

  /// Anything else, including no connection.
  other,
}

class BetaFeedbackException implements Exception {
  const BetaFeedbackException(this.failure, [this.message = '']);
  final BetaFeedbackFailure failure;
  final String message;
  @override
  String toString() => 'BetaFeedbackException($failure, $message)';
}

/// The server seam for the earned reward.
abstract interface class BetaFeedbackApi {
  Future<BetaReward> reward();

  Future<BetaRewardActivation> activate();
}
