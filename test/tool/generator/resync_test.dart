// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/files.dart';
import '../../../tool/generator/lib/src/check/series_signature.dart';
import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/generate.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';

ProblemType _type(String name) => parseProblemType(
      loadYaml(
        [
          for (final root in ['content/types', 'content/types-held'])
            ...Directory(root).listSync(recursive: true).whereType<File>(),
        ]
            .singleWhere((f) => f.path.endsWith('reasoning-$name.yaml'))
            .readAsStringSync(),
      ) as Map,
    );

void main() {
  for (final name in [
    'matrix-ray-intersection',
    'series-interleaved-count',
    'matrix-corner-grid',
  ]) {
    test('$name reproduces fixed source and rejects competing choices', () {
      final type = _type(name);
      final v = generateVariants(type, count: 1).variants.single;
      final sources = readSourceQuestions('.', '646326517', {v.source!});
      expect(checkVariants(type, [v], questions: sources), isEmpty);
      for (final choice in v.choices.skip(1)) {
        expect(
          figureSolvers.values
              .any((s) => s.fits(v.figureSpec!, choice.figure!, v.slots)),
          isFalse,
        );
      }
    });
    test('$name new draws pass grown solver library and named mistakes', () {
      final type = _type(name);
      for (var i = 1; i <= 100; i++) {
        final result = ruleRegistry[type.rule]!.generate(type, Random(i), i);
        final draw = result.variant;
        for (final choice in draw.choices.skip(1)) {
          expect(
            figureSolvers.values.any(
              (s) => s.fits(draw.figureSpec!, choice.figure!, draw.slots),
            ),
            isFalse,
            reason: '$name draw $i',
          );
          expect(
            mistakeSolvers[(type.rule, choice.mistake)]!(type, draw),
            choice.figure,
          );
        }
      }
    });
  }
  for (final name in ['matrix-ray-intersection', 'series-interleaved-count']) {
    test('$name active list passes full checker and R6', () {
      final type = _type(name);
      final file = Directory('content/types')
          .listSync(recursive: true)
          .whereType<File>()
          .singleWhere((f) => f.path.endsWith('reasoning-$name.variants.yaml'));
      final list = parseVariantList(loadYaml(file.readAsStringSync()) as Map);
      final sources = readSourceQuestions(
        '.',
        '646326517',
        type.mergedQuestions.map((m) => m.id).toSet(),
      );
      expect(list.variants, hasLength(100));
      expect(checkVariants(type, list.variants, questions: sources), isEmpty);
      final counts = <String, int>{};
      for (final v in list.variants) {
        final key = dataKey(
          canonicalSeriesItem(
            v.choices.singleWhere((c) => c.correct).figure!,
            0,
            mirror: false,
          ),
        );
        counts.update(key, (count) => count + 1, ifAbsent: () => 1);
      }
      expect(
        counts.values.every((count) => count * 2 <= list.variants.length),
        isTrue,
        reason: '$counts',
      );
    });
  }
  test('corner-grid notes describe actual copying without fixed positions', () {
    final type = _type('matrix-corner-grid');
    expect(type.mistakes.last.note, contains('directly above'));
    expect(
      type.mistakes.map((m) => m.note).join(),
      isNot(contains('Top-right')),
    );
    expect(type.params['forms'], ['square']);
  });
}
