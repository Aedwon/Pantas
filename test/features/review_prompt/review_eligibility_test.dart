import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/review_prompt/domain/review_eligibility.dart';

void main() {
  group('ReviewEligibility', () {
    test('asks after a good result, when never asked and no recent paywall',
        () {
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

  group('finishedWell', () {
    test('four in five right counts as well', () {
      expect(ReviewEligibility.finishedWell(correct: 8, total: 10), isTrue);
    });

    test('just under does not', () {
      expect(ReviewEligibility.finishedWell(correct: 7, total: 10), isFalse);
    });

    test('an empty session is not a good one', () {
      expect(ReviewEligibility.finishedWell(correct: 0, total: 0), isFalse);
    });
  });
}
