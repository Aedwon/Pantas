// test/features/quiz/domain/models/session_origin_test.dart
import 'package:pantas/core/storage/domain/attempt_origins.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assessment round-trips through storage', () {
    expect(SessionOrigin.assessment.storageValue, 'assessment');
    expect(
      SessionOrigin.fromStorage('assessment'),
      SessionOrigin.assessment,
    );
  });

  test('the assessment earns no streak', () {
    expect(SessionOrigin.assessment.isStreakEligible, isFalse);
  });

  test('every existing origin still round-trips', () {
    for (final origin in SessionOrigin.values) {
      expect(SessionOrigin.fromStorage(origin.storageValue), origin);
    }
  });

  test('the untimed list names a real origin', () {
    for (final value in AttemptOrigins.untimed) {
      expect(
        SessionOrigin.values.map((o) => o.storageValue),
        contains(value),
      );
    }
  });
}
