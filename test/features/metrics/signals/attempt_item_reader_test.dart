import 'package:cse_cet_reviewer/features/metrics/signals/attempt_item_reader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses attempt items json with response timing and correctness', () {
    const json = '''
[
  {
    "questionId": "q_1",
    "questionVersion": 2,
    "chosenChoiceId": "a",
    "correctChoiceId": "b",
    "responseMs": 12000
  },
  {
    "questionId": "q_2",
    "questionVersion": 1,
    "chosenChoiceId": "c",
    "correctChoiceId": "c",
    "responseMs": 8000
  }
]
''';

    final items = const AttemptItemReader().read(json);

    expect(items, hasLength(2));
    expect(items.first.questionId, 'q_1');
    expect(items.first.responseMs, 12000);
    expect(items.first.isCorrect, isFalse);
    expect(items.last.isCorrect, isTrue);
  });

  test('returns an empty list for malformed attempt json', () {
    final items = const AttemptItemReader().read('{bad json');

    expect(items, isEmpty);
  });
}
