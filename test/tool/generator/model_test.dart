// Tool libraries live outside the root package lib directory.
// ignore_for_file: avoid_relative_lib_imports

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/model.dart';
import 'support.dart';

void main() {
  test('parses the Part 3 problem type including fixed merged indexes', () {
    final t = parseProblemType(
      loadYaml(
        File('test/tool/generator/fixtures/type.yaml').readAsStringSync(),
      ) as Map,
    );
    expect(t.id, 'qt-spatial-abstract-reasoning-turn-step');
    expect(
      t.lesson,
      'lesson-spatial-abstract-reasoning-figure-turns-and-positions',
    );
    expect(t.keyPoint, 1);
    expect(t.exams, ['acet', 'ustet', 'dost-sei', 'cse-pro']);
    expect(t.rule, 'figureSeriesTurnStep');
    expect(t.ruleVersion, 1);
    expect(t.choiceCount, 4);
    expect(t.choiceKind, 'figure');
    expect(t.enabled, isTrue);
    expect(t.params['stepDegrees'], [45, 90]);
    expect(t.mistakes.single.id, 'double-turn');
    expect(t.mergedQuestions.single.index, 0);
  });

  test('figure list round-trips all data and metadata deterministically', () {
    final input = loadYaml(
      File('test/tool/generator/fixtures/variants.yaml').readAsStringSync(),
    ) as Map;
    final doc = parseVariantList(input);
    final text = writeVariantList(doc);
    final parsed = parseVariantList(loadYaml(text) as Map);
    expect(parsed, doc);
    expect(writeVariantList(parsed), text);
    expect(parsed.variants, parseVariants(input));
    expect(parsed.seed, 20261117);
    expect(parsed.variants.single.ruleKey, 'example-rule-key');
    expect(parsed.variants.single.cosmetics, {'fill': 'white'});
    expect(parsed.tool, 1);
    expect(parsed.variants.single.figureSpec!['kind'], 'figure-series');
    expect(parsed.variants.single.choices.last.slots['wrongStep'], 90);
    expect(parsed.variants.single.choices.first.figure!['rotation'], 135);
  });

  test('writer sorts nested maps while preserving choice and list order', () {
    Map<String, Object?> data(Map<String, Object?> slots) => {
          'problemType': 'qt-test-add',
          'generator': {'tool': 1, 'ruleVersion': 1, 'seed': 8},
          'variants': [
            {
              'index': 0,
              'slots': slots,
              'choices': [
                {
                  'correct': true,
                  'text': r'$\dfrac{1}{2}$: yes\nnext',
                  'value': '1/2',
                },
                {'mistake': 'subtract', 'text': 'No', 'value': '-1/2'},
              ],
              'signature': 'test',
              'ruleKey': 'test-rule',
              'cosmetics': {'fill': 'white'},
            },
          ],
        };
    final first = parseVariantList(
      data({
        'b': [2, 1],
        'a': 'yes',
      }),
    );
    final second = parseVariantList(
      data({
        'a': 'yes',
        'b': [2, 1],
      }),
    );
    expect(writeVariantList(first), writeVariantList(second));
    expect(parseVariantList(loadYaml(writeVariantList(first)) as Map), first);
  });

  test('rejects malformed required fields and duplicate merged indexes', () {
    expect(
      () => parseProblemType({...mathTypeData(), 'ruleVersion': '1'}),
      throwsFormatException,
    );
    expect(
      () => parseProblemType({
        ...mathTypeData(),
        'mergedQuestions': [
          {'id': 'q-one', 'index': 0},
          {'id': 'q-two', 'index': 0},
        ],
      }),
      throwsFormatException,
    );
  });

  test('exact rationals normalize signs and avoid machine integer rounding',
      () {
    final huge = Rational.parse('900719925474099312345678901234567890/3');
    expect(
      (huge * Rational.parse('3')).toString(),
      '900719925474099312345678901234567890',
    );
    expect(Rational.parse('2/-4'), Rational.parse('-1/2'));
    expect((Rational.parse('1/3') + Rational.parse('1/6')).toString(), '1/2');
    expect((Rational.parse('1/3') - Rational.parse('1/6')).toString(), '1/6');
    expect((Rational.parse('1/3') / Rational.parse('2/3')).toString(), '1/2');
    expect(() => Rational.parse('1/0'), throwsFormatException);
    expect(() => Rational.parse('0.5'), throwsFormatException);
    expect(
      () => Rational.parse('1') / Rational.parse('0'),
      throwsArgumentError,
    );
  });
}
