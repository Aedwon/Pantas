import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';

void main() {
  test('attempt items preserve index zero and read legacy answers', () {
    final legacy = <String, dynamic>{
      'questionId': 'qt-example',
      'questionVersion': 1,
      'chosenChoiceId': 'a',
      'correctChoiceId': 'a',
      'responseMs': 400,
    };
    expect(AttemptItem.fromJson(legacy).variantIndex, isNull);
    final item = AttemptItem.fromJson({...legacy, 'variantIndex': 0});
    expect(item.toJson()['variantIndex'], 0);
  });

  test('quiz outcomes encode the exact variant', () {
    const outcome = AnswerOutcome(
      questionId: 'qt-example',
      questionVersion: 1,
      chosenChoiceId: 'a',
      correctChoiceId: 'a',
      responseMs: 400,
      variantIndex: 2,
    );
    expect(encodeOutcome(outcome)['variantIndex'], 2);
  });
}
