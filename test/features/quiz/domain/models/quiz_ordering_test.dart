import 'package:pantas/features/quiz/domain/models/quiz_ordering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each ordering round-trips through storage', () {
    for (final ordering in QuizOrdering.values) {
      expect(QuizOrdering.fromStorage(ordering.storageValue), ordering);
    }
  });

  test('the shipped boolean still reads', () {
    expect(QuizOrdering.fromStorage('true'), QuizOrdering.interleavedTail);
    expect(QuizOrdering.fromStorage('false'), QuizOrdering.blocked);
  });

  test('an absent or unrecognised value falls back to the default', () {
    expect(QuizOrdering.fromStorage(null), QuizOrdering.interleavedTail);
    expect(QuizOrdering.fromStorage(''), QuizOrdering.interleavedTail);
    expect(QuizOrdering.fromStorage('sideways'), QuizOrdering.interleavedTail);
  });

  test('interleaved tail is the recommended default', () {
    expect(QuizOrdering.defaultOrdering, QuizOrdering.interleavedTail);
    expect(QuizOrdering.interleavedTail.isRecommended, isTrue);
    expect(QuizOrdering.blocked.isRecommended, isFalse);
    expect(QuizOrdering.fullyMixed.isRecommended, isFalse);
  });
}
