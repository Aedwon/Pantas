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
  for (final pattern in ['ray-turn', 'dot-sum']) {
    test('checker rejects re-audit $pattern counterexample', () {
      final type = readType('matrix-$pattern');
      final fixture = File(
        'test/tool/generator/fixtures/bad/reaudit-$pattern.yaml',
      ).readAsStringSync();
      final bad = parseVariants(loadYaml(fixture) as Map).single;
      expect(bad.index, pattern == 'ray-turn' ? 57 : 56);
      expect(
        checkVariants(type, [bad]).any(
          (f) =>
              f.check == 'correctness' &&
              f.reason == 'wrong choice completes a library rule',
        ),
        isTrue,
      );
    });
    test('$pattern draws rule out the re-audit competitor', () {
      final type = readType('matrix-$pattern');
      for (var i = 1; i <= 200; i++) {
        final v = ruleRegistry[type.rule]!.generate(type, Random(i), i).variant;
        final cells = v.figureSpec!['cells']! as List;
        if (pattern == 'ray-turn') {
          final a = (cells[0] as Map)['line']! as int;
          final b = (cells[1] as Map)['line']! as int;
          expect((180 - a) % 360, isNot(b), reason: 'draw $i');
        } else {
          for (var y = 0; y < 2; y++) {
            final a = (cells[y * 3] as Map)['dots']! as int;
            final b = (cells[y * 3 + 1] as Map)['dots']! as int;
            expect(a + b, isNot(2 * b - a), reason: 'draw $i row $y');
          }
        }
      }
    });
  }
  test('highest-ray competitor rejects ambiguous intersection source', () {
    final type = readType('matrix-ray-intersection');
    final base = ruleRegistry[type.rule]!.generate(type, Random(0), 0).variant;
    final v = parseVariants({
      'variants': [
        {
          ...base.toMap(),
          'choices': [
            ...base.choices.take(2).map((c) => c.toMap()),
            {
              'text': 'Square with only the upper-right ray',
              'mistake': 'first-exclusive',
              'figure': {'form': 'square', 'line': 45},
            },
            base.choices.last.toMap(),
          ],
        }
      ],
    }).single;
    expect(
      checkVariants(type, [v]).any(
        (f) =>
            f.check == 'correctness' &&
            f.reason == 'wrong choice completes a library rule',
      ),
      isTrue,
    );
  });
  test('corner-step draws use square and can key bottom-right', () {
    final type = readType('matrix-corner-step');
    final positions = <Object?>{};
    for (var i = 1; i <= 100; i++) {
      final v = ruleRegistry[type.rule]!.generate(type, Random(i), i).variant;
      final figures = [
        ...(v.figureSpec!['cells']! as List).whereType<Map<String, Object?>>(),
        ...v.choices.map((c) => c.figure!),
      ];
      expect(figures.every((f) => f['form'] == 'square'), isTrue);
      positions.add(v.choices.singleWhere((c) => c.correct).figure!['dot']);
    }
    expect(positions, contains('bottom-right'));
  });
  test('corner-step solver rejects non-four-corner source outline', () {
    final type = readType('matrix-corner-step');
    final v = ruleRegistry[type.rule]!.generate(type, Random(0), 0).variant;
    expect(
      figureSolvers[type.rule]!.fits(
        v.figureSpec!,
        v.choices.first.figure!,
        v.slots,
      ),
      isFalse,
    );
  });
}
