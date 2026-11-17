// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/model.dart';
import 'check_support.dart';
import 'support.dart';

List<Variant> fixture(String name) => parseVariants(
      loadYaml(
        File('test/tool/generator/fixtures/bad/$name.yaml').readAsStringSync(),
      ) as YamlMap,
    );

void main() {
  setUp(registerTestSolvers);
  tearDown(() {
    mathSolvers.clear();
    figureSolvers.clear();
    mistakeSolvers.clear();
  });
  final cases = {
    'two-correct': 'correctness',
    'wrong-key': 'correctness',
    'mistake-mismatch': 'choices',
    'duplicate-choice': 'choices',
    'duplicate-signature': 'signature',
    'out-of-range': 'ranges-text',
    'unfilled-slot': 'ranges-text',
    'frac': 'ranges-text',
    'oversize': 'size',
    'merged-mismatch': 'merged',
    'choice-count': 'choices',
  };
  for (final entry in cases.entries) {
    test('rejects planted ${entry.key} with context', () {
      final data = mathTypeData();
      if (entry.key == 'merged-mismatch') {
        data['mergedQuestions'] = [
          {'id': 'old', 'index': 0},
        ];
      }
      final failures =
          checkVariants(parseProblemType(data), fixture(entry.key));
      expect(
        failures.map((f) => f.toString()),
        contains(
          matches('^qt-test-add #[0-9]+ ${entry.value}: .+'),
        ),
      );
    });
  }
  test('good math list passes', () {
    final good = fixture('merged-mismatch').single.toMap()..remove('source');
    expect(
      checkVariants(
        parseProblemType(mathTypeData()),
        parseVariants({
          'variants': [good],
        }),
      ),
      isEmpty,
    );
  });
  test('missing solver fails closed', () {
    mathSolvers.clear();
    expect(
      checkVariants(parseProblemType(mathTypeData()), fixture('wrong-key')),
      isNotEmpty,
    );
  });
  test('empty list still rejects an unknown rule', () {
    final type = parseProblemType(mathTypeData()..['rule'] = 'unknown');
    expect(
      checkVariants(type, []).map((f) => f.toString()),
      contains('qt-test-add #0 correctness: no solver for rule unknown'),
    );
  });
  test('merged reproduction compares the rendered stem exactly', () {
    final type = parseProblemType(
      mathTypeData()
        ..['mergedQuestions'] = [
          {'id': 'old', 'index': 0},
        ],
    );
    final variants = fixture('merged-mismatch');
    final source = <String, Object?>{
      'stem': r'What is $5 + 3$?',
      'choices': variants.single.choices
          .map((c) => <String, Object?>{'text': c.text, 'correct': c.correct})
          .toList(),
    };
    expect(checkVariants(type, variants, questions: {'old': source}), isEmpty);
    source['stem'] = r'What is $5 - 3$?';
    expect(
      checkVariants(type, variants, questions: {'old': source})
          .any((f) => f.check == 'merged'),
      isTrue,
    );
  });
  test('TeX arguments remain variables even when slot names collide', () {
    expect(
      fillSlots(r'$\dfrac{x}{y}$ and {x}', {'x': 5, 'y': 3}),
      r'$\dfrac{x}{y}$ and 5',
    );
  });
  test('TeX arguments pass without corresponding slots', () {
    final type = parseProblemType(
      mathTypeData()..['stem'] = r'Evaluate $\dfrac{x}{2}$ when $x = {a}$.',
    );
    final variant = fixture('merged-mismatch').single.toMap()..remove('source');
    expect(
      checkVariants(
        type,
        parseVariants({
          'variants': [variant],
        }),
      ),
      isEmpty,
    );
  });
  test('TeX consumes only its own arguments before a slot', () {
    expect(
      fillSlots(r'$\dfrac{x}{y} {a} + \times {b}$', {'a': 5, 'b': 3}),
      r'$\dfrac{x}{y} 5 + \times 3$',
    );
  });
  test('optional root arguments and scripts preserve variables', () {
    expect(
      fillSlots(r'$\sqrt[3]{x} + z^{x} + z_{x}$', {'x': 5}),
      r'$\sqrt[3]{x} + z^{x} + z_{x}$',
    );
  });
  test('explicit slots inside TeX arguments are filled', () {
    expect(
      fillSlots(r'$\dfrac{{a}}{{b}}$', {'a': 5, 'b': 3}),
      r'$\dfrac{5}{3}$',
    );
  });
  test('math duplicates ignore wording slots and normalize rationals', () {
    final first = fixture('merged-mismatch').single.toMap()..remove('source');
    final second = Map<String, Object?>.of(first)
      ..['index'] = 1
      ..['signature'] = 'different'
      ..['slots'] = {'a': '5/1', 'b': 3, 'answer': 8, 'label': 'other'};
    expect(
      checkVariants(
        parseProblemType(mathTypeData()),
        parseVariants({
          'variants': [first, second],
        }),
      ).any((f) => f.check == 'signature'),
      isTrue,
    );
  });
  test('slot expansion cannot leave another slot unfilled', () {
    final data = fixture('merged-mismatch').single.toMap()
      ..remove('source')
      ..['slots'] = {'a': 5, 'b': 3, 'answer': '{missing}'};
    expect(
      checkVariants(
        parseProblemType(mathTypeData()),
        parseVariants({
          'variants': [data],
        }),
      ).any((f) => f.check == 'ranges-text'),
      isTrue,
    );
  });
  test('checker sources never import rules', () {
    for (final file in Directory('tool/generator/lib/src/check')
        .listSync(recursive: true)
        .whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      expect(
        RegExp(r'''(?:import|export)\s+['"][^'"]*rules/''')
            .hasMatch(file.readAsStringSync()),
        isFalse,
        reason: file.path,
      );
    }
  });
}
