import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sample = Attempt(
    id: 'a_1',
    examId: 'exam_cse_pro',
    startedAt: DateTime.utc(2026, 5, 9, 12),
    completedAt: DateTime.utc(2026, 5, 9, 12, 5),
    items: const [
      AttemptItem(
        questionId: 'q_1',
        questionVersion: 1,
        chosenChoiceId: 'c_b',
        correctChoiceId: 'c_b',
        responseMs: 1800,
      ),
      AttemptItem(
        questionId: 'q_2',
        questionVersion: 1,
        chosenChoiceId: 'c_a',
        correctChoiceId: 'c_c',
        responseMs: 4200,
      ),
    ],
  );

  test('round-trips JSON', () {
    expect(Attempt.fromJson(sample.toJson()), equals(sample));
  });

  test('score returns correct count over total', () {
    expect(sample.score, equals((1, 2)));
  });

  test('isCompleted reflects completedAt presence', () {
    expect(sample.isCompleted, isTrue);
    expect(sample.copyWith(completedAt: null).isCompleted, isFalse);
  });
}
