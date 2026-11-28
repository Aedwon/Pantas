// Tool libraries live outside the root package lib directory.
// ignore_for_file: avoid_relative_lib_imports

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/generate.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'support.dart';

void main() {
  final type = parseProblemType(mathTypeData());
  final rules = <String, Rule>{'testAdd': AddRule()};

  test('fixed seed produces identical YAML and a different seed changes it',
      () {
    final a = generateVariants(type, count: 100, seed: 17, rules: rules);
    final b = generateVariants(type, count: 100, seed: 17, rules: rules);
    final c = generateVariants(type, count: 100, seed: 18, rules: rules);
    expect(writeVariantList(a), writeVariantList(b));
    expect(writeVariantList(a), isNot(writeVariantList(c)));
    expect(a.variants.map((v) => v.signature).toSet(), hasLength(100));
    expect(parseVariantList(loadYaml(writeVariantList(a)) as Map), a);
  });

  test('refill preserves the first 100 byte-for-byte and appends 100 to 119',
      () {
    final original = generateVariants(type, count: 100, seed: 17, rules: rules);
    final saved = writeVariantList(original);
    final refill = generateVariants(
      type,
      count: 120,
      existing: parseVariantList(loadYaml(saved) as Map),
      rules: rules,
    );
    final text = writeVariantList(refill);
    expect(text.startsWith(saved), isTrue);
    expect(refill.variants.take(100).toList(), original.variants);
    expect(
      refill.variants.skip(100).map((v) => v.index),
      List.generate(20, (i) => i + 100),
    );
    expect(refill, generateVariants(type, count: 120, seed: 17, rules: rules));
    expect(
      generateVariants(type, count: 80, existing: refill, rules: rules),
      refill,
    );
  });

  test('merged questions remain at reserved indexes on generation and refill',
      () {
    final merged = parseProblemType({
      ...mathTypeData(),
      'mergedQuestions': [
        {'id': 'q-first', 'index': 0},
        {'id': 'q-second', 'index': 2},
      ],
    });
    final original = generateVariants(merged, count: 3, seed: 17, rules: rules);
    final refill =
        generateVariants(merged, count: 8, existing: original, rules: rules);
    expect(refill.variants[0].source, 'q-first');
    expect(refill.variants[1].source, isNull);
    expect(refill.variants[2].source, 'q-second');
    expect(refill.variants.take(3).toList(), original.variants);
    expect(
      () => generateVariants(merged, count: 2, seed: 17, rules: rules),
      throwsArgumentError,
    );
  });

  test('duplicate signatures consume the next random draw before retry', () {
    final collisionType = parseProblemType({
      ...mathTypeData(),
      'params': {'max': 3},
    });
    final generated =
        generateVariants(collisionType, count: 9, seed: 9, rules: rules);
    final random = Random(9);
    final expected = <String>[];
    final seen = <String>{};
    var draws = 0;
    while (expected.length < 9) {
      final a = random.nextInt(3) + 1;
      final b = random.nextInt(3) + 1;
      draws++;
      if (seen.add('$a,$b')) expected.add('$a,$b');
    }
    expect(draws, greaterThan(9));
    expect(
      generated.variants.map((v) => '${v.slots['a']},${v.slots['b']}'),
      expected,
    );
    final first =
        generateVariants(collisionType, count: 4, seed: 9, rules: rules);
    expect(
      generateVariants(
        collisionType,
        count: 9,
        existing: first,
        rules: rules,
      ),
      generated,
    );
  });

  test('fails after exactly 1000 failed draws for the next index', () {
    final rule = CountingConstantRule();
    expect(
      () => generateVariants(type, count: 2, seed: 1, rules: {'testAdd': rule}),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          allOf(contains(type.id), contains('index 1'), contains('1000')),
        ),
      ),
    );
    expect(rule.draws, 1001);
  });

  test('rejects unknown or mismatched rule versions before drawing', () {
    expect(
      () => generateVariants(type, count: 1, seed: 1, rules: {}),
      throwsArgumentError,
    );
    final changed = parseProblemType({...mathTypeData(), 'ruleVersion': 2});
    expect(
      () => generateVariants(changed, count: 1, seed: 1, rules: rules),
      throwsArgumentError,
    );
  });

  test('refill rejects mismatched metadata, changed seed and corrupt indexes',
      () {
    final original = generateVariants(type, count: 3, seed: 17, rules: rules);
    expect(
      () => generateVariants(
        type,
        count: 4,
        seed: 18,
        existing: original,
        rules: rules,
      ),
      throwsArgumentError,
    );
    for (final field in ['problemType', 'generator', 'variants']) {
      final data = original.toMap();
      if (field == 'problemType') data[field] = 'qt-other';
      if (field == 'generator') {
        data[field] = {'tool': 99, 'ruleVersion': 1, 'seed': 17};
      }
      if (field == 'variants') {
        data[field] = original.variants.reversed.map((v) => v.toMap()).toList();
      }
      expect(
        () => generateVariants(
          type,
          count: 4,
          existing: parseVariantList(data),
          rules: rules,
        ),
        throwsArgumentError,
      );
    }
  });

  test('does not accept a rule that omits a reserved merged source', () {
    final merged = parseProblemType({
      ...mathTypeData(),
      'mergedQuestions': [
        {'id': 'q-first', 'index': 0},
      ],
    });
    expect(
      () => generateVariants(
        merged,
        count: 1,
        seed: 1,
        rules: {'testAdd': CountingConstantRule()},
      ),
      throwsStateError,
    );
  });
}

class CountingConstantRule extends AddRule {
  int draws = 0;
  @override
  RuleResult generate(ProblemType t, Random r, int index) {
    draws++;
    r.nextInt(10);
    final variant = parseVariants({
      'variants': [
        {
          'index': index,
          'slots': <String, Object?>{},
          'choices': [
            {'correct': true, 'text': '2', 'value': '2'},
          ],
          'signature': 'constant',
          'ruleKey': 'pending',
          'cosmetics': <String, Object?>{},
        },
      ],
    }).single;
    return RuleResult(variant: variant, ruleParams: {}, cosmetics: {});
  }
}
