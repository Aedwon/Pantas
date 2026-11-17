// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/files.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/generate.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';

const patterns = [
  'ray-step',
  'binary-fill',
  'size-fill',
  'two-arrow-turns',
  'dots-size',
  'arrow-alternation',
  'two-fill-steps',
  'outline-triple',
  'four-tracks',
  'corner-edge-count',
  'double-fill',
  'transfer-count',
  'interleaved-count',
  'fill-ray-dots',
  'size-corner-ray',
];
void main() {
  for (final pattern in patterns) {
    test('$pattern registers independent solver and reproduces source', () {
      final name = 'series-$pattern';
      expect(ruleRegistry, contains(name));
      expect(figureSolvers, contains(name));
      final files = [
        for (final path in ['content/types-held', 'content/types'])
          if (Directory(path).existsSync())
            ...Directory(path).listSync(recursive: true),
      ].whereType<File>().where(
            (f) => f.path
                .endsWith('qt-spatial-abstract-reasoning-series-$pattern.yaml'),
          );
      final type =
          parseProblemType(loadYaml(files.single.readAsStringSync()) as Map);
      final list = generateVariants(type, count: 1);
      final base = list.variants.single;
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

      final sources = readSourceQuestions(
        '.',
        'origin/content/bite-sized-cse-algebra-r1',
        type.mergedQuestions.map((m) => m.id).toSet(),
      );
      expect(checkVariants(type, list.variants, questions: sources), isEmpty);
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
