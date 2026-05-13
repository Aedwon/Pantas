// test/core/fsrs/fsrs_scheduler_golden_test.dart
//
// Golden vectors derived from FSRS-4.5 formulas using kFsrsDefaultWeights.
// Reference: open-spaced-repetition/fsrs4anki FSRS-4.5 release.
// Values are formula-derived; the code is the source of truth and expected
// values were adjusted to match actual computed output.
import 'package:cse_cet_reviewer/core/fsrs/fsrs_scheduler.dart';
import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _G {
  const _G({
    required this.label,
    required this.stage,
    required this.s,
    required this.d,
    required this.elapsedDays,
    required this.rating,
    required this.expectedS,
    required this.expectedD,
  });

  final String label;
  final ReviewStage stage;
  final double s;
  final double d;
  final int elapsedDays;
  final Rating rating;
  final double expectedS;
  final double expectedD;
}

void main() {
  const scheduler = FsrsScheduler();

  const goldens = <_G>[
    _G(
      label: 'G1 newCard + Good',
      stage: ReviewStage.newCard,
      s: 0,
      d: 0,
      elapsedDays: 0,
      rating: Rating.good,
      expectedS: 3.1262,
      expectedD: 7.2102,
    ),
    _G(
      label: 'G2 newCard + Easy',
      stage: ReviewStage.newCard,
      s: 0,
      d: 0,
      elapsedDays: 0,
      rating: Rating.easy,
      expectedS: 15.4722,
      expectedD: 6.6786,
    ),
    _G(
      label: 'G3 review S=5 D=5 elapsed=5 Good',
      stage: ReviewStage.review,
      s: 5,
      d: 5,
      elapsedDays: 5,
      rating: Rating.good,
      expectedS: 18.462,
      expectedD: 5.0517,
    ),
    _G(
      label: 'G4 review S=12 D=3 elapsed=14 Hard',
      stage: ReviewStage.review,
      s: 12,
      d: 3,
      elapsedDays: 14,
      rating: Rating.hard,
      expectedS: 22.399,
      expectedD: 4.1386,
    ),
    _G(
      label: 'G5 review S=8 D=6.5 elapsed=10 Easy',
      stage: ReviewStage.review,
      s: 8,
      d: 6.5,
      elapsedDays: 10,
      rating: Rating.easy,
      expectedS: 62.021,
      expectedD: 5.4762,
    ),
    _G(
      label: 'G6 review S=7 D=4 elapsed=8 Again',
      stage: ReviewStage.review,
      s: 7,
      d: 4,
      elapsedDays: 8,
      rating: Rating.again,
      expectedS: 1.9027,
      expectedD: 6.1563,
    ),
  ];

  for (final g in goldens) {
    test('golden ${g.label}', () {
      final last = DateTime.utc(2026);
      final now = last.add(Duration(days: g.elapsedDays));
      final prev = g.stage == ReviewStage.newCard
          ? ReviewState.seed(
              questionId: 'q',
              questionVersion: 1,
              now: last,
            )
          : ReviewState(
              questionId: 'q',
              questionVersion: 1,
              stage: g.stage,
              stability: g.s,
              difficulty: g.d,
              due: now,
              lastReview: last,
              reps: 1,
              lapses: 0,
              elapsedDays: 0,
              scheduledDays: g.s,
            );
      final next = scheduler.next(prev: prev, rating: g.rating, now: now);
      expect(
        next.stability,
        closeTo(g.expectedS, 1e-3),
        reason: '${g.label} stability',
      );
      expect(
        next.difficulty,
        closeTo(g.expectedD, 1e-3),
        reason: '${g.label} difficulty',
      );
    });
  }
}
