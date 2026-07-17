import 'package:cse_cet_reviewer/features/review_prompt/domain/review_eligibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewEligibility', () {
    test('returns true after a good result when never asked and no recent paywall', () {
      expect(
        ReviewEligibility.shouldAsk(
          hasAskedBefore: false,
          justFinishedWell: true,
          sawPaywallRecently: false,
        ),
        isTrue,
      );
    });

    test('returns false if asked before (never twice)', () {
      expect(
        ReviewEligibility.shouldAsk(
          hasAskedBefore: true,
          justFinishedWell: true,
          sawPaywallRecently: false,
        ),
        isFalse,
      );
    });

    test('returns false if saw paywall recently', () {
      expect(
        ReviewEligibility.shouldAsk(
          hasAskedBefore: false,
          justFinishedWell: true,
          sawPaywallRecently: true,
        ),
        isFalse,
      );
    });

    test('returns false if result was not good (failure/poor result)', () {
      expect(
        ReviewEligibility.shouldAsk(
          hasAskedBefore: false,
          justFinishedWell: false,
          sawPaywallRecently: false,
        ),
        isFalse,
      );
    });
  });
}
