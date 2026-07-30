import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/metrics/signals/mock_payload_reader.dart';

void main() {
  test('parses mock sample, answers, flags, and section results', () {
    const sampleJson = '''
[
  {
    "sectionId": "general",
    "name": "General Ability",
    "questionIds": ["q_1", "q_2"]
  }
]
''';
    const answersJson = '''
{
  "q_1": {"selectedIndex": 1, "atSec": 42},
  "q_2": {"selectedIndex": 0, "atSec": 84}
}
''';
    const flagsJson = '["q_2"]';
    const sectionResultsJson = '''
{
  "sections": [
    {
      "sectionId": "general",
      "name": "General Ability",
      "correct": 1,
      "total": 2,
      "retiredCount": 0,
      "timeSeconds": 84
    }
  ]
}
''';

    final payload = const MockPayloadReader().read(
      sampledQuestionsJson: sampleJson,
      answersJson: answersJson,
      flagsJson: flagsJson,
      sectionResultsJson: sectionResultsJson,
    );

    expect(payload.sections, hasLength(1));
    expect(payload.sections.single.questionIds, ['q_1', 'q_2']);
    expect(payload.answers['q_1']?.selectedIndex, 1);
    expect(payload.answers['q_2']?.atSec, 84);
    expect(payload.flaggedQuestionIds, {'q_2'});
    expect(payload.sectionResults.single.correct, 1);
    expect(payload.sectionResults.single.timeSeconds, 84);
  });

  test('returns empty collections for malformed optional mock json', () {
    final payload = const MockPayloadReader().read(
      sampledQuestionsJson: '{bad',
      answersJson: '{bad',
      flagsJson: '{bad',
      sectionResultsJson: '{bad',
    );

    expect(payload.sections, isEmpty);
    expect(payload.answers, isEmpty);
    expect(payload.flaggedQuestionIds, isEmpty);
    expect(payload.sectionResults, isEmpty);
  });
}
