// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/files.dart';
import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/generate.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';

const patterns = [
  'ray-turn',
  'size-columns',
  'size-fill',
  'ray-union',
  'fill-union',
  'corner-step',
  'size-dots',
  'ray-intersection',
  'corner-reflection',
  'binary-fill-row',
  'arrow-column',
  'form-ray',
  'sized-ray-union',
  'outline-latin',
  'dot-sum',
  'size-latin',
  'growing-turn',
  'corner-grid',
  'size-transfer',
];
void main() {
  test('constant matrix outline is recorded separately from ruleKey', () {
    final file = Directory('content')
        .listSync(recursive: true)
        .whereType<File>()
        .firstWhere(
          (f) => f.path
              .endsWith('qt-spatial-abstract-reasoning-matrix-size-fill.yaml'),
        );
    final type = parseProblemType(loadYaml(file.readAsStringSync()) as Map);
    final v = ruleRegistry[type.rule]!.generate(type, Random(42), 1).variant;
    expect(v.cosmetics.keys, contains('form'));
    final changed = parseVariants({
      'variants': [
        {
          ...v.toMap(),
          'cosmetics': {'form': 'invalid'},
        }
      ],
    }).single;
    expect(
      figureSolvers[type.rule]!.validateCosmetics(type, changed),
      isNotEmpty,
    );
  });
  test('fill union uses every permitted pair of distinct sizes', () {
    final file = Directory('content')
        .listSync(recursive: true)
        .whereType<File>()
        .firstWhere(
          (f) => f.path
              .endsWith('qt-spatial-abstract-reasoning-matrix-fill-union.yaml'),
        );
    final type = parseProblemType(loadYaml(file.readAsStringSync()) as Map);
    final sizes = <Object?>{};
    for (var i = 1; i < 50; i++) {
      final v = ruleRegistry[type.rule]!.generate(type, Random(i), i).variant;
      for (final cell in (v.figureSpec!['cells']! as List)
          .whereType<Map<String, Object?>>()) {
        sizes.add(cell['size']);
        expect(['circle', 'square'], contains(cell['form']));
      }
    }
    expect(sizes, contains('medium'));
  });
  test('sized ray union rejects changed rays in a completed row', () {
    final file = Directory('content/types')
        .listSync(recursive: true)
        .whereType<File>()
        .firstWhere(
          (f) => f.path.endsWith(
            'qt-spatial-abstract-reasoning-matrix-sized-ray-union.yaml',
          ),
        );
    final type = parseProblemType(loadYaml(file.readAsStringSync()) as Map);
    final base = generateVariants(type, count: 1).variants.single;
    final solver = figureSolvers[type.rule]!;
    expect(
      solver.fits(base.figureSpec!, base.choices.first.figure!, base.slots),
      isTrue,
    );
    // Each mutated row still has a valid union. Only its column rays differ.
    for (final row in [0, 1]) {
      for (final rays in [
        [45, 135],
        [0, 90],
      ]) {
        final cells = [...base.figureSpec!['cells']! as List];
        for (var column = 0; column < 3; column++) {
          final cell =
              Map<String, Object?>.from(cells[row * 3 + column]! as Map)
                ..remove('line')
                ..remove('lines');
          if (column == 2) {
            cell['lines'] = rays;
          } else {
            cell['line'] = rays[column];
          }
          cells[row * 3 + column] = cell;
        }
        expect(
          solver.fits(
            {...base.figureSpec!, 'cells': cells},
            base.choices.first.figure!,
            base.slots,
          ),
          isFalse,
          reason: 'row $row changed its corresponding input rays to $rays',
        );
      }
    }
  });
  for (final pattern in patterns) {
    test('$pattern registers independent solver and reproduces source', () {
      final name = 'matrix-$pattern';
      expect(ruleRegistry, contains(name));
      expect(figureSolvers, contains(name));
      final files = [
        for (final path in ['content/types-held', 'content/types'])
          if (Directory(path).existsSync())
            ...Directory(path).listSync(recursive: true),
      ].whereType<File>().where(
            (f) => f.path
                .endsWith('qt-spatial-abstract-reasoning-matrix-$pattern.yaml'),
          );
      final type =
          parseProblemType(loadYaml(files.single.readAsStringSync()) as Map);
      final list = generateVariants(type, count: 1);
      final restricted = parseProblemType({
        ...type.toMap(),
        'params': {...type.params, 'forms': <String>[]},
      });
      expect(
        figureSolvers[name]!.validateRanges(restricted, list.variants.single),
        isNotEmpty,
      );
      final base = list.variants.single;
      if (base.choices.first.figure!.containsKey('size')) {
        final limited = parseProblemType({
          ...type.toMap(),
          'params': {...type.params, 'sizes': <String>[]},
        });
        expect(figureSolvers[name]!.validateRanges(limited, base), isNotEmpty);
      }
      final solver = figureSolvers[name]!;
      expect(
        solver.fits(
          base.figureSpec!,
          {
            ...base.choices.first.figure!,
            'lines': [17],
          },
          base.slots,
        ),
        isFalse,
      );

      for (var i = 0; i < (base.figureSpec!['cells']! as List).length; i++) {
        final cells = [...base.figureSpec!['cells']! as List];
        if (cells[i] == 'blank') continue;
        cells[i] = {
          ...cells[i]! as Map<String, Object?>,
          'unsupportedFeature': 1,
        };
        expect(
          solver.fits(
            {...base.figureSpec!, 'cells': cells},
            base.choices.first.figure!,
            base.slots,
          ),
          isFalse,
          reason: '$pattern ignores a visible feature at $i',
        );
      }
      final sources = readSourceQuestions(
        '.',
        ['ray-intersection', 'corner-grid'].contains(pattern)
            ? '646326517'
            : 'origin/content/bite-sized-cse-algebra-r1',
        type.mergedQuestions.map((m) => m.id).toSet(),
      );
      final failures = checkVariants(type, list.variants, questions: sources);
      // Held sources remain exact, but cannot pass current correctness rules.
      expect(failures.where((f) => f.check == 'merged'), isEmpty);
      if (pattern == 'corner-step') {
        expect(failures.where((f) => f.check == 'correctness'), isNotEmpty);
      } else {
        expect(failures, isEmpty);
      }
      for (var i = 1; i <= 20; i++) {
        final result = ruleRegistry[name]!.generate(type, Random(i), i);
        final solver = figureSolvers[name]!;
        expect(
          solver.fits(
            result.variant.figureSpec!,
            result.variant.choices.first.figure!,
            result.variant.slots,
          ),
          isTrue,
        );
        for (final c in result.variant.choices.skip(1)) {
          expect(
            dataKey(mistakeSolvers[(name, c.mistake)]!(type, result.variant)),
            dataKey(c.figure),
          );
          for (final entry in figureSolvers.entries) {
            final other = entry.value;
            expect(
              other.fits(
                result.variant.figureSpec!,
                c.figure!,
                result.variant.slots,
              ),
              isFalse,
              reason: '$pattern wrong choice fits ${other.runtimeType}',
            );
          }
          expect(
            solver.fits(
              result.variant.figureSpec!,
              c.figure!,
              result.variant.slots,
            ),
            isFalse,
          );
        }
      }
    });
  }
}
