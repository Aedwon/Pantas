// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'task_signature_test.dart' show changed, readType;

Variant audited(String pattern, int index) {
  final file = File('test/tool/generator/fixtures/bad/reaudit-c-$pattern.yaml');
  return parseVariants(loadYaml(file.readAsStringSync()) as Map)
      .singleWhere((v) => v.index == index);
}

void main() {
  for (final example in [
    ('ray-turn', 6, 'matrix-ray-diagonal-270'),
    ('ray-turn', 59, 'matrix-ray-diagonal-90'),
    ('dot-sum', 53, 'matrix-dot-product-row'),
    ('dot-sum', 68, 'matrix-dot-difference-column'),
    ('dot-sum', 79, 'matrix-dot-quotient-column'),
    ('dot-sum', 10, 'matrix-dot-maximum-column'),
    ('dot-sum', 69, 'matrix-dot-minimum-column'),
  ]) {
    test('re-audit C ${example.$1} index ${example.$2} ${example.$3}', () {
      final v = audited(example.$1, example.$2);
      final solver = figureSolvers[example.$3];
      expect(solver, isNotNull);
      expect(
        v.choices
            .where((c) => !c.correct)
            .any((c) => solver!.fits(v.figureSpec!, c.figure!, v.slots)),
        isTrue,
      );
      expect(
        checkVariants(readType('matrix-${example.$1}'), [v])
            .any((f) => f.check == 'correctness'),
        isTrue,
      );
    });
  }
  test('column difference preserves each column outline', () {
    final shown = <String, Object?>{
      'kind': 'figure-matrix',
      'rows': 3,
      'cols': 3,
      'cells': [
        for (final counts in [
          [1, 4, 5],
          [2, 1, 3],
          [1, 3],
        ])
          for (var x = 0; x < counts.length; x++)
            {
              'form': ['square', 'circle', 'triangle'][x],
              'dots': counts[x],
            },
        'blank',
      ],
    };
    final solver = figureSolvers['matrix-dot-difference-column']!;
    expect(
      solver.fits(shown, {'form': 'triangle', 'dots': 2}, {}),
      isTrue,
    );
    expect(
      solver.fits(shown, {'form': 'square', 'dots': 2}, {}),
      isFalse,
    );
    expect(
      solver.fits(shown, {'form': 'triangle', 'dots': 3}, {}),
      isFalse,
    );
  });
  test('agreement on the same choice is acceptable', () {
    final base = audited('dot-sum', 0);
    final v = changed(base, {
      'figureSpec': {
        ...base.figureSpec!,
        'cells': [
          for (var i = 0; i < 9; i++)
            if (i == 8)
              'blank'
            else
              {
                'form': base.choices.first.figure!['form'],
                'dots': i % 3 == 2 ? 4 : 2,
              },
        ],
      },
    });
    final solver = figureSolvers['matrix-dot-product-row'];
    expect(solver, isNotNull);
    expect(
      solver!.fits(v.figureSpec!, v.choices.first.figure!, v.slots),
      isTrue,
    );
    expect(
      checkVariants(readType('matrix-dot-sum'), [v])
          .where((f) => f.check == 'correctness'),
      isEmpty,
    );
  });
  for (final pattern in ['ray-turn', 'dot-sum']) {
    test('new $pattern draws have no competing offered answer', () {
      final t = readType('matrix-$pattern');
      for (var i = 1; i <= 200; i++) {
        final v = ruleRegistry[t.rule]!.generate(t, Random(i), i).variant;
        expect(
          checkVariants(t, [v]).where((f) => f.check == 'correctness'),
          isEmpty,
          reason: 'draw $i',
        );
      }
    });
  }
}
