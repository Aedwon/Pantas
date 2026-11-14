import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/content/question_hash.dart';

void main() {
  final meta = <String, Object?>{
    'topic': 't',
    'subtopic': 's',
    'exams': ['b', 'a'],
  };
  final question = <String, Object?>{
    'stem': 'What is this?',
    'choices': [
      {'text': 'One', 'correct': true, 'rationale': 'Because one'},
      {'text': 'Two'},
    ],
    'explanation': 'It is one.',
    'passage': 'p',
    'figure': 'f',
    'figureSpec': {
      'z': 'some text',
      'a': [1, 2],
    },
  };
  test('hash is SHA-256 and resolves the exporter lesson', () {
    expect(questionHash(question, meta), matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(questionLesson(question, meta), 'lesson-t-s');
  });
  test('normalizes YAML quoting, blocks, whitespace, keys and exam order', () {
    final a = loadYaml('''
stem: |
  Hello
  world
choices: [{text: ' A ', correct: false}]
figureSpec: {b: 'two words', a: 1}
''') as YamlMap;
    final b = loadYaml('''
figureSpec: {a: 1, b: ' two   words '}
choices: [{correct: false, text: A}]
stem: >
  Hello
  world
''') as YamlMap;
    expect(
      questionHash(a, meta),
      questionHash(b, {
        ...meta,
        'exams': ['a', 'b'],
      }),
    );
  });
  test('every hashed field affects the hash', () {
    final original = questionHash(question, meta);
    for (final key in [
      'stem',
      'explanation',
      'passage',
      'figure',
      'figureSpec',
      'lesson',
    ]) {
      expect(
        questionHash({...question, key: 'changed'}, meta),
        isNot(original),
        reason: key,
      );
    }
    for (final key in ['text', 'correct', 'rationale']) {
      final choices = [
        {
          ...(question['choices']! as List<Map<String, Object?>>).first,
          key: key == 'correct' ? false : 'changed',
        },
        {'text': 'Two'},
      ];
      expect(
        questionHash({...question, 'choices': choices}, meta),
        isNot(original),
        reason: key,
      );
    }
    expect(
      questionHash(question, {
        ...meta,
        'exams': ['c'],
      }),
      isNot(original),
    );
  });
  test('keyPoint and approved are display metadata only', () {
    expect(
      questionHash({...question, 'keyPoint': 2, 'approved': true}, meta),
      questionHash(question, meta),
    );
  });
}
