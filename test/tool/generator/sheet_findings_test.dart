// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/figures/figure_series_figure.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'task_signature_test.dart' show readType;

Iterable<Map<String, Object?>> figures(Variant v, String field) sync* {
  yield* (v.figureSpec![field]! as List).whereType<Map<String, Object?>>();
  yield* v.choices.map((c) => c.figure!);
}

void main() {
  test('new fill-ray-dots rays never lie along a dot row or fill edge', () {
    final t = readType('series-fill-ray-dots');
    for (var seed = 1; seed <= 300; seed++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(seed), seed).variant;
      for (final item in figures(v, 'items')) {
        expect([90, 270], isNot(contains(item['line'])), reason: '$seed $item');
      }
    }
  });
  test('new size-dots remain separated and inside their painted outline', () {
    final t = readType('matrix-size-dots');
    for (var seed = 1; seed <= 300; seed++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(seed), seed).variant;
      for (final item in figures(v, 'cells')) {
        final form = item['form']! as String;
        final count = item['dots']! as int;
        expect(
          form == 'triangle' && item['size'] == 'small' && count >= 3,
          isFalse,
          reason: '$seed $item',
        );
        final r = 18 * FigureSeriesFigure.sizes[item['size']]!;
        final row = SeriesGeometry.dotRow(form, Offset.zero, r, count);
        for (var i = 1; i < row.centres.length; i++) {
          expect(
            (row.centres[i] - row.centres[i - 1]).distance,
            greaterThanOrEqualTo(2 * row.radius + 1.2 - 1e-8),
            reason: '$seed $item',
          );
        }
        final path = SeriesGeometry.formPath(form, Offset.zero, r);
        for (final center in row.centres) {
          for (var angle = 0; angle < 360; angle += 15) {
            final a = angle * pi / 180;
            expect(
              path.contains(
                center + Offset(cos(a), sin(a)) * (row.radius + .5),
              ),
              isTrue,
              reason: '$seed $item',
            );
          }
        }
      }
    }
  });
  for (final entry in {'lowest': 2, 'leftmost': 8, 'rightmost': 12}.entries) {
    test('checker rejects audited ${entry.key}-ray alternative', () {
      final f =
          File('test/tool/generator/fixtures/bad/sheet-extreme-rays.yaml');
      final v = parseVariants(loadYaml(f.readAsStringSync()) as Map)
          .singleWhere((v) => v.index == entry.value);
      final solver = figureSolvers['matrix-${entry.key}-ray'];
      expect(solver, isNotNull);
      expect(
        v.choices
            .skip(1)
            .any((c) => solver!.fits(v.figureSpec!, c.figure!, v.slots)),
        isTrue,
      );
      expect(
        checkVariants(readType('matrix-ray-intersection'), [v])
            .any((f) => f.check == 'correctness'),
        isTrue,
      );
    });
  }
  test('new intersections reject every competing offered answer', () {
    final t = readType('matrix-ray-intersection');
    for (var seed = 1; seed <= 300; seed++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(seed), seed).variant;
      expect(
        checkVariants(t, [v]).where((f) => f.check == 'correctness'),
        isEmpty,
        reason: 'seed $seed',
      );
    }
  });
  test('generated choices retain source prose rather than compact codes', () {
    for (final rule in [
      'series-fill-ray-dots',
      'series-dots-size',
      'matrix-size-dots',
      'matrix-ray-intersection',
    ]) {
      final t = readType(rule);
      for (var seed = 1; seed <= 30; seed++) {
        final v = ruleRegistry[rule]!.generate(t, Random(seed), seed).variant;
        for (final c in v.choices) {
          expect(c.text, isNot(contains('%')));
          expect(c.text, isNot(matches(r'\b[0-9]+ dots\b')));
          expect(c.text, isNot(matches(r'\b(?:line|ray) [NESW]{1,2}\b')));
          if (rule == 'series-fill-ray-dots') {
            expect(
              c.text,
              matches(
                '^(Quarter-filled|Half-filled|Three-quarter-filled|'
                'Fully filled) '
                r'\w+; line (up|down|left|right|upper|lower)',
              ),
            );
          } else if (rule.endsWith('dots-size') || rule == 'matrix-size-dots') {
            expect(c.text, contains(' with '));
          }
        }
      }
    }
  });
}
