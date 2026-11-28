// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'task_signature_test.dart' show readType;

void main() {
  final audited = parseVariants(
    loadYaml(
      File('test/tool/generator/fixtures/bad/held2.yaml').readAsStringSync(),
    ) as Map,
  );

  test('index 50 cannot get a full fill by adding quarter and half', () {
    final failures = checkVariants(
      readType('series-fill-ray-dots'),
      [audited[1]],
    );
    expect(
      failures.where((f) => f.check == 'choices').map((f) => f.reason),
      contains('choice differs from mistake accumulate-fill'),
    );
  });

  test('generated accumulate-fill choices add the two shown levels', () {
    final type = readType('series-fill-ray-dots');
    final rule = ruleRegistry[type.rule]!;
    for (var seed = 1; seed <= 100; seed++) {
      final variant = rule.generate(type, Random(seed), seed).variant;
      final shown =
          (variant.figureSpec!['items']! as List).cast<Map<String, Object?>>();
      final choice = variant.choices.singleWhere(
        (c) => c.mistake == 'accumulate-fill',
      );
      final sum = (shown[0]['fill']! as num) + (shown[1]['fill']! as num);
      expect(sum, lessThanOrEqualTo(1), reason: 'seed $seed');
      expect(
        choice.figure!['fill'],
        sum,
        reason: 'seed $seed',
      );
    }
  });

  test('index 43 admits a wrong answer under southwest selection', () {
    final failures = checkVariants(
      readType('matrix-ray-intersection'),
      [audited[0]],
    );
    expect(
      failures.where((f) => f.check == 'correctness').map((f) => f.reason),
      contains('wrong choice completes a library rule'),
    );
  });

  test('index 46 admits a wrong answer by northwest tip projection', () {
    final failures = checkVariants(
      readType('matrix-ray-intersection'),
      [audited[2]],
    );
    expect(
      failures.where((f) => f.check == 'correctness').map((f) => f.reason),
      contains('wrong choice completes a library rule'),
    );
  });

  const directions = [
    'highest',
    'northeast',
    'rightmost',
    'southeast',
    'lowest',
    'southwest',
    'leftmost',
    'northwest',
  ];
  for (var i = 0; i < directions.length; i++) {
    final direction = directions[i];
    test('$direction ray projection fits both rows and rejects ties', () {
      final ray = i * 45;
      Map<String, Object> single(int line, {String form = 'square'}) =>
          {'form': form, 'line': line};
      Map<String, Object> pair(int a, int b, {String form = 'square'}) => {
            'form': form,
            'lines': [a, b],
          };
      final shown = <String, Object?>{
        'kind': 'figure-matrix',
        'rows': 2,
        'cols': 3,
        'cells': [
          pair(ray, (ray + 45) % 360, form: 'circle'),
          pair(ray, (ray + 315) % 360, form: 'circle'),
          single(ray, form: 'circle'),
          pair((ray + 90) % 360, (ray + 315) % 360),
          pair((ray + 90) % 360, (ray + 180) % 360),
          'blank',
        ],
      };
      final solver = figureSolvers['matrix-$direction-ray'];
      expect(solver, isNotNull);
      expect(solver!.fits(shown, single((ray + 315) % 360), {}), isTrue);
      expect(solver.fits(shown, single((ray + 90) % 360), {}), isFalse);

      // The target now has two rays equally close to the chosen direction.
      (shown['cells']! as List<Object>)[4] =
          pair((ray + 90) % 360, (ray + 45) % 360);
      expect(solver.fits(shown, single((ray + 315) % 360), {}), isFalse);
    });
  }
}
