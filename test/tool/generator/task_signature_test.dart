// ignore_for_file: avoid_relative_lib_imports
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/capacity.dart';
import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/generate.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';

Variant changed(Variant v, Map<String, Object?> changes) => parseVariants({
      'variants': [
        {...v.toMap(), ...changes},
      ],
    }).single;

ProblemType readType(String rule) {
  final files = [
    for (final root in ['content/types', 'content/types-held'])
      ...Directory(root).listSync(recursive: true).whereType<File>(),
  ].where(
    (f) => f.path.endsWith('.yaml') && !f.path.endsWith('.variants.yaml'),
  );
  return files
      .map((f) => parseProblemType(loadYaml(f.readAsStringSync()) as Map))
      .singleWhere((t) => t.rule == rule);
}

void main() {
  for (final rule in [
    'series-ray-step',
    'matrix-ray-turn',
    'net-opposite-hard',
    'group-side-count-easy',
  ]) {
    test('$rule signature excludes wrong choices and retains the key', () {
      final type = readType(rule);
      final v = ruleRegistry[rule]!.generate(type, Random(1), 0).variant;
      final onlyKey = changed(v, {
        'choices': [
          v.choices.singleWhere((c) => c.correct).toMap(),
        ],
      });
      expect(canonicalSignature(v), canonicalSignature(onlyKey));
      final wrongKey = changed(v, {
        'choices': [
          {...v.choices.last.toMap()..remove('mistake'), 'correct': true},
        ],
      });
      expect(canonicalSignature(v), isNot(canonicalSignature(wrongKey)));
    });
  }
  test('grouping task ignores arbitrary row permutations and marks key figure',
      () {
    final type = readType('group-side-count-easy');
    final v = ruleRegistry[type.rule]!.generate(type, Random(1), 0).variant;
    final row = v.figureSpec!['shapes']! as List;
    const order = [2, 0, 3, 1];
    final permuted = changed(v, {
      'figureSpec': {
        ...v.figureSpec!,
        'shapes': [for (final i in order) row[i]],
      },
      'choices': v.choices
          .map(
            (c) => {
              ...c.toMap(),
              'value': '${order.indexOf(int.parse(c.value!) - 1) + 1}',
            },
          )
          .toList(),
    });
    expect(canonicalSignature(v), canonicalSignature(permuted));
    final duplicate = changed(permuted, {'index': 1});
    expect(
      checkVariants(type, [v, duplicate]).any(
        (f) =>
            f.index == 1 &&
            f.check == 'signature' &&
            f.reason.contains('duplicate'),
      ),
      isTrue,
    );
    expect(
      figureSolvers[type.rule]!.ruleParams(type, v),
      figureSolvers[type.rule]!.ruleParams(type, permuted),
    );
  });
  test('distractor-only extraForm does not define a series ruleKey', () {
    final type = readType('series-double-fill');
    final v = ruleRegistry[type.rule]!.generate(type, Random(1), 0).variant;
    final other = changed(v, {
      'slots': {...v.slots, 'extraForm': 'star'},
    });
    expect(
      figureSolvers[type.rule]!.ruleParams(type, v),
      figureSolvers[type.rule]!.ruleParams(type, other),
    );
  });
  for (final rule in ['matrix-outline-latin', 'net-opposite-hard']) {
    test('$rule ruleKey excludes distractor metadata', () {
      final type = readType(rule);
      final v = generateVariants(type, count: type.mergedQuestions.length)
          .variants
          .first;
      final params = figureSolvers[rule]!.ruleParams(type, v)
        ..remove('extraForm')
        ..remove('profile');
      expect(
        v.ruleKey,
        sha256.convert(utf8.encode(canonicalJson(params))).toString(),
      );
    });
  }
  test('number task signature includes the correct answer', () {
    final v = parseVariants({
      'variants': [
        {
          'index': 0,
          'slots': {'a': 2, 'b': 3},
          'choices': [
            {'text': '5', 'value': '5', 'correct': true},
          ],
          'ruleKey': 'test',
          'signature': 'test',
          'cosmetics': <String, Object?>{},
        }
      ],
    }).single;
    final other = changed(v, {
      'choices': [
        {'text': '6', 'value': '6', 'correct': true},
      ],
    });
    expect(canonicalSignature(v), isNot(canonicalSignature(other)));
  });
  test('checker rejects a planted distractor-only duplicate list', () {
    final type = readType('series-ray-step');
    final base = generateVariants(type, count: 1).variants.single;
    final duplicate = changed(base, {
      'index': 1,
      'source': 'irrelevant',
      'choices': [
        base.choices.first.toMap(),
        {
          ...base.choices.last.toMap(),
          'figure': {'form': 'star'},
        },
      ],
    });
    final failures = checkVariants(type, [base, duplicate]);
    expect(
      failures.any(
        (f) =>
            f.index == 1 &&
            f.check == 'signature' &&
            f.reason.contains('duplicate'),
      ),
      isTrue,
    );
  });
  test('capacity counts tasks rather than distractor sets', () {
    final type = readType('series-ray-step');
    final v = ruleRegistry[type.rule]!.generate(type, Random(1), 0).variant;
    final report = measureCapacity(
      type,
      ceiling: 20,
      rules: {type.rule: _DistractorRule(type.rule, v)},
    );
    expect(report.signatures, 1);
    expect(report.ruleKeys, 1);
  });
}

class _DistractorRule implements Rule {
  _DistractorRule(this.name, this.base);
  @override
  final String name;
  final Variant base;
  @override
  int get version => 1;
  @override
  RuleResult generate(ProblemType type, Random random, int index) => RuleResult(
        variant: changed(base, {
          'choices': [
            base.choices.first.toMap(),
            {
              ...base.choices.last.toMap(),
              'figure': {'form': 'circle', 'dots': index},
            },
          ],
        }),
        ruleParams: {'extraForm': '$index'},
        cosmetics: {},
      );
}
