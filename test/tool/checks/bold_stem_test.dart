import 'package:flutter_test/flutter_test.dart';

import '../../../tool/checks/bold_stem.dart';
import '../../../tool/checks/content_snapshot.dart';

QuestionRow stem(String text) =>
    QuestionRow(id: text, topicId: 't', examIds: const {}, stem: text);

void main() {
  test('a stem that mentions the word in bold with none in it fails', () {
    for (final bad in [
      'What does the word in bold mean?\nThe lecture was arduous.',
      'Choose the meaning of the boldfaced word.',
      'Ano ang kahulugan ng salitang naka-bold?',
    ]) {
      expect(findStemsMissingBold([stem(bad)]), hasLength(1), reason: bad);
    }
  });

  test('a stem with a bold word, or bold as an ordinary word, passes', () {
    expect(
      findStemsMissingBold([
        stem('What does the word in bold mean?\nThe **arduous** task.'),
        stem('Which describes a bold move by the mayor?'),
      ]),
      isEmpty,
    );
  });

  test('a strong mark in the export counts as a bold word', () {
    final content = ContentSnapshot.fromExport(const {
      'mockBlueprint': <Object>[],
      'question': [
        {
          '_id': 'q',
          'topic': {'_ref': 't'},
          'examIds': <Object>[],
          'stem': [
            {
              'children': [
                {'text': 'The word in bold: ', 'marks': <Object>[]},
                {
                  'text': 'arduous',
                  'marks': ['strong'],
                },
              ],
            },
          ],
        },
      ],
    });
    expect(findStemsMissingBold(content.questions), isEmpty);
  });
}
