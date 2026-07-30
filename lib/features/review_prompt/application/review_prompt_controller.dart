import 'package:pantas/features/review_prompt/data/review_prompt_store.dart';
import 'package:pantas/features/review_prompt/domain/app_review_gateway.dart';
import 'package:pantas/features/review_prompt/domain/review_eligibility.dart';

typedef ReviewClock = DateTime Function();

/// Decides whether to ask, then asks.
///
/// The policy lives in [ReviewEligibility] and is tested on its own. This
/// class is the part that reads the record and talks to the store.
class ReviewPromptController {
  ReviewPromptController({
    required ReviewPromptStore store,
    required AppReviewGateway gateway,
    ReviewClock? clock,
  })  : _store = store,
        _gateway = gateway,
        _clock = clock ?? DateTime.now;

  final ReviewPromptStore _store;
  final AppReviewGateway _gateway;
  final ReviewClock _clock;

  /// Called when a student finishes something. Asks at most once, ever.
  Future<void> maybeAsk({required bool justFinishedWell}) async {
    final record = await _store.read();
    final now = _clock();
    final seenAt = record.paywallSeenAt;

    final eligible = ReviewEligibility.shouldAsk(
      hasAskedBefore: record.askedAt != null,
      justFinishedWell: justFinishedWell,
      sawPaywallRecently:
          seenAt != null && now.difference(seenAt) < reviewPaywallCoolOff,
    );
    if (!eligible) return;

    if (!await _gateway.isAvailable()) return;

    // Recorded before the popup, not after. Play can decline to draw
    // anything and tells us nothing either way, so a student who was
    // offered the popup counts as asked. The alternative is asking again
    // on the next good result, which is the thing this must never do.
    await _store.recordAsked(now);
    await _gateway.requestReview();
  }

  /// The paywall calls this. It starts the quiet period.
  Future<void> recordPaywallSeen() => _store.recordPaywallSeen(_clock());
}
