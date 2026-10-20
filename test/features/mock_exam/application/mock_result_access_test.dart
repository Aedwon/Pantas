import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/application/mock_results_providers.dart';

void main() {
  test('native Free review ends exactly when its next mock opens', () {
    final submitted = DateTime.utc(2026, 10);
    final open = nativeMockReviewAccess(
      examId: 'exam_upcat',
      submittedAt: submitted,
      pro: false,
      now: submitted.add(const Duration(days: 14)),
    );
    expect(open.canReview, isFalse);
    expect(open.reviewUntil, submitted.add(const Duration(days: 14)));
    expect(
      nativeMockReviewAccess(
        examId: 'exam_upcat',
        submittedAt: submitted,
        pro: false,
        now: submitted.add(const Duration(days: 13)),
      ).canReview,
      isTrue,
    );
    expect(
      nativeMockReviewAccess(
        examId: 'exam_upcat',
        submittedAt: submitted,
        pro: true,
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
        pro: false,
        now: DateTime.utc(2026),
      ).canReview,
      isFalse,
    );
  });
}
