import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';

/// Replaced by the Firebase implementation; tests override it with a fake.
final betaFeedbackApiProvider = Provider<BetaFeedbackApi>(
  (ref) => throw UnimplementedError('betaFeedbackApiProvider'),
);

final betaImageSourceProvider = Provider<BetaImageSource>(
  (ref) => throw UnimplementedError('betaImageSourceProvider'),
);

/// The Feedback (Beta) row and page exist only for selected testers,
/// including after the beta week.
final betaFeedbackVisibleProvider = Provider<bool>(
  (ref) => ref.watch(betaAccessProvider).valueOrNull?.selected ?? false,
);

final betaRewardProvider = FutureProvider.autoDispose<BetaReward?>((ref) async {
  if (!ref.watch(betaFeedbackVisibleProvider)) return null;
  return ref.watch(betaFeedbackApiProvider).reward();
});

final sentFeedbackProvider =
    StreamProvider.autoDispose<List<SentFeedback>>((ref) {
  if (!ref.watch(betaFeedbackVisibleProvider)) return Stream.value(const []);
  return ref.watch(betaFeedbackApiProvider).sent();
});

/// The same clock as the beta gate, so tests set one time for both.
final betaFeedbackClockProvider =
    Provider<DateTime Function()>((ref) => ref.watch(betaClockProvider));
