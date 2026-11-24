import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/features/beta_feedback/data/firebase_beta_feedback_api.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';

/// The Firebase implementation; tests override it with a fake.
final betaFeedbackApiProvider = Provider<BetaFeedbackApi>(
  (ref) => FirebaseBetaFeedbackApi(),
);

/// The reward notice and page exist only for selected testers, including
/// after the beta week.
final betaFeedbackVisibleProvider = Provider<bool>(
  (ref) => ref.watch(betaAccessProvider).valueOrNull?.selected ?? false,
);

/// The tester's reward status, read once per session and shared by Home and
/// the reward page. It stays alive between screens and changes only for
/// another account or when a turned-on reward invalidates it.
final betaRewardProvider = FutureProvider<BetaReward?>((ref) async {
  ref.watch(currentUserProvider.select((user) => user.valueOrNull?.uid));
  if (!ref.watch(betaFeedbackVisibleProvider)) return null;
  return ref.watch(betaFeedbackApiProvider).reward();
});

/// The same clock as the beta gate, so tests set one time for both.
final betaFeedbackClockProvider =
    Provider<DateTime Function()>((ref) => ref.watch(betaClockProvider));

/// Whether Settings shows the Beta Reward row: the reward is earned and not
/// yet turned on. It keeps a way to the reward after the Home notice is
/// dismissed.
final betaRewardRowVisibleProvider = Provider<bool>((ref) {
  final reward = ref.watch(betaRewardProvider).valueOrNull;
  return reward != null &&
      reward.eligible &&
      reward.surveySubmitted &&
      !reward.activated;
});
