import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/beta_feedback/data/firebase_beta_feedback_api.dart';
import 'package:pantas/features/beta_feedback/data/picker_beta_image_source.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';

/// The Firebase implementation; tests override it with a fake.
final betaFeedbackApiProvider = Provider<BetaFeedbackApi>(
  (ref) => FirebaseBetaFeedbackApi(
    uid: () => ref.read(currentUserProvider).valueOrNull?.uid,
    examId: () => ref.read(activeExamFocusProvider).valueOrNull?.exam?.id,
  ),
);

/// The system picker everywhere, plus drops and pastes on web. Tests override
/// it with a fake.
final betaImageSourceProvider = Provider<BetaImageSource>(
  (ref) => PickerBetaImageSource(),
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
