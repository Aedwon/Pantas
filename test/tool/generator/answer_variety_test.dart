// ignore_for_file: avoid_relative_lib_imports
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generator/lib/src/check/files.dart';
import 'support.dart';

void main() {
  List<String> check(
    List<Map<String, Object?>> keys, {
    bool math = false,
    bool enabled = true,
  }) {
    final dir = Directory.systemTemp.createTempSync('r6-');
    addTearDown(() => dir.deleteSync(recursive: true));
    File('${dir.path}/type.yaml').writeAsStringSync(
      jsonEncode({
        ...mathTypeData(),
        'enabled': enabled,
        if (!math) 'rule': 'testFigure',
        if (!math)
          'choiceKind': keys.first.containsKey('figure') ? 'figure' : 'text',
      }),
    );
    File('${dir.path}/type.variants.yaml').writeAsStringSync(
      jsonEncode({
        'problemType': 'qt-test-add',
        'generator': {'tool': 1, 'ruleVersion': 1, 'seed': 1},
        'variants': [
          for (var i = 0; i < keys.length; i++)
            {
              'index': i,
              'slots': {'a': 1, 'b': i + 1, 'answer': 'shared'},
              if (!math)
                'figureSpec': {
                  'kind': 'figure-series',
                  'items': [
                    {'form': 'square', 'dots': i},
                  ],
                },
              'choices': [
                {...keys[i], 'correct': true},
              ],
              'signature': 'unique-$i',
              'ruleKey': 'unique-$i',
              'cosmetics': <String, Object?>{},
            },
        ],
      }),
    );
    return checkTypeFiles(root: '.', typesPath: dir.path)
        .where((f) => f.check == 'answer-variety')
        .map((f) => f.toString())
        .toList();
  }

  test('R6 rejects a majority of rendered text keys regardless of value', () {
    expect(
      check([
        {'text': '{answer}', 'value': '1'},
        {'text': 'shared', 'value': '2'},
        {'text': 'different', 'value': '3'},
      ]),
      contains(matches('^qt-test-add #0 answer-variety: .*2.*3')),
    );
  });
  test('R6 compares exact math values rather than text spelling', () {
    expect(
      check(
        [
          {'text': 'one half', 'value': '1/2'},
          {'text': 'two fourths', 'value': '2/4'},
          {'text': 'three', 'value': '3'},
        ],
        math: true,
      ),
      hasLength(1),
    );
  });
  test('R6 canonicalizes answer figures independently of shown figures', () {
    expect(
      check([
        {
          'text': 'up',
          'figure': {'form': 'square', 'line': 0},
        },
        {
          'text': 'right',
          'figure': {'form': 'square', 'line': 90},
        },
        {
          'text': 'dot',
          'figure': {'form': 'square', 'dots': 1},
        },
      ]),
      hasLength(1),
    );
  });
  test('R6 permits exactly half and disabled lists', () {
    final keys = [
      {'text': 'same'},
      {'text': 'same'},
      {'text': 'other'},
      {'text': 'last'},
    ];
    expect(check(keys), isEmpty);
    expect(check(keys.take(3).toList(), enabled: false), isEmpty);
  });
  test('R6 catches a constant key and permits an empty list', () {
    expect(
      check([
        {'text': 'same'},
        {'text': 'same'},
      ]),
      hasLength(1),
    );
    expect(check([], math: true), isEmpty);
  });
}
