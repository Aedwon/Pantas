import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/first_run/domain/first_run_lesson_blocks.dart';

Map<String, Object?> _b(String style, String text) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
    };

String _text(Map<String, Object?> b) =>
    ((b['children']! as List).single as Map)['text']! as String;

void main() {
  final body = [
    _b('h2', 'Core Concept'),
    _b('normal', 'core text'),
    _b('h2', 'Mnemonics & Memory Aids'),
    _b('normal', 'D before P'),
    _b('h2', 'Examples'),
    _b('h3', '#1: Basic Conversion'),
    _b('normal', 'Express 0.125'),
    _b('normal', 'Solution:'),
    _b('normal', 'step'),
    _b('h3', '#2: Mixed Operations'),
    _b('normal', 'Evaluate'),
    _b('h2', 'Practice'),
    _b('normal', 'later'),
  ];

  test('keeps the three sections and stops after Example 1', () {
    final kept = firstRunLessonBlocks(body).map(_text).toList();
    expect(kept, [
      'Core Concept',
      'core text',
      'Mnemonics & Memory Aids',
      'D before P',
      'Examples',
      '#1: Basic Conversion',
      'Express 0.125',
      'Solution:',
      'step',
    ]);
  });

  test('a lesson without a second example is kept to its Examples end', () {
    final short = body.sublist(0, 9);
    expect(firstRunLessonBlocks(short).length, 9);
  });
}
