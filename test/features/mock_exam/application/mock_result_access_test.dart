import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

void main() {
  test('native Free review ends exactly when its next mock opens', () {
    final submitted = DateTime.utc(2026, 10);
    final open = nativeMockReviewAccess(
      examId: 'exam_upcat',
      submittedAt: submitted,
      entitlement: const Entitlement.free(),
      now: submitted.add(const Duration(days: 14)),
    );
    expect(open.canReview, isFalse);
    expect(open.reviewUntil, submitted.add(const Duration(days: 14)));
    expect(
      nativeMockReviewAccess(
        examId: 'exam_upcat',
        submittedAt: submitted,
        entitlement: const Entitlement.free(),
        now: submitted.add(const Duration(days: 13)),
      ).canReview,
      isTrue,
    );
    expect(
      nativeMockReviewAccess(
        examId: 'exam_upcat',
        submittedAt: submitted,
        entitlement: const Entitlement.free().withPasses({
          'exam_upcat': submitted.add(const Duration(days: 120)),
        }),
        now: submitted.add(const Duration(days: 90)),
      ).canReview,
      isTrue,
    );
  });
  test('missing submission time grants no invented review window', () {
    expect(
      nativeMockReviewAccess(
        examId: 'exam_upcat',
        submittedAt: null,
        entitlement: const Entitlement.free(),
        now: DateTime.utc(2026),
      ).canReview,
      isFalse,
    );
  });
  test('review Pro coverage belongs to the stored attempt exam', () {
    final now = DateTime.utc(2026, 10, 20);
    final entitlement = const Entitlement.free().withPasses({
      'exam_cse_pro': now.add(const Duration(days: 30)),
    });

    expect(
      nativeMockReviewAccess(
        examId: 'exam_upcat',
        submittedAt: now.subtract(const Duration(days: 90)),
        entitlement: entitlement,
        now: now,
      ).canReview,
      isFalse,
    );
    expect(
      nativeMockReviewAccess(
        examId: 'exam_cse_pro',
        submittedAt: now.subtract(const Duration(days: 90)),
        entitlement: entitlement,
        now: now,
      ).canReview,
      isTrue,
    );
  });
}
