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
  'opposite-easy',
  'overlap-medium',
  'strip-first-overlap',
  'adjacent-relation',
  'validity-test',
  'opposite-medium',
  'all-opposites',
  'top-and-shadow',
  'opposite-hard',
  'three-at-corner',
  'nonadjacent',
];

void main() {
  const hardPath = 'content/types/reasoning/spatial-abstract-reasoning/'
      'folding-and-checking-cube-nets/'
      'qt-spatial-abstract-reasoning-net-opposite-hard.yaml';
  final hardFile = File(hardPath).existsSync()
      ? File(hardPath)
      : File(hardPath.replaceFirst('content/types/', 'content/types-held/'));
  final hardType =
      parseProblemType(loadYaml(hardFile.readAsStringSync()) as Map);
  final hardSource = generateVariants(hardType, count: 2).variants[1];
  final hardSolver = figureSolvers['net-opposite-hard']!;
  final back = hardSource.choices.singleWhere((c) => c.correct).text;
  for (final entry in <String, Object?>{
    'missing': null,
    'unknown': 'Z',
    'same as front': hardSource.slots['face'],
    'opposite front': back,
    'not a label': 1,
  }.entries) {
    test('hard profile 1 rejects upFace ${entry.key}', () {
      final slots = {...hardSource.slots}..remove('upFace');
      if (entry.value != null) slots['upFace'] = entry.value;
      final corrupt = parseVariants({
        'variants': [
          {...hardSource.toMap(), 'slots': slots},
        ],
      }).single;
      expect(
        hardSolver.fits(corrupt.figureSpec!, {'text': back}, corrupt.slots),
        isFalse,
      );
      expect(hardSolver.validateRanges(hardType, corrupt), isNotEmpty);
    });
  }
  test('hard profile 1 accepts every perpendicular upFace', () {
    final labels = (hardSource.figureSpec!['labels']! as List).cast<String>();
    for (final up in labels.where(
      (label) => label != hardSource.slots['face'] && label != back,
    )) {
      final slots = {...hardSource.slots, 'upFace': up};
      final variant = parseVariants({
        'variants': [
          {...hardSource.toMap(), 'slots': slots},
        ],
      }).single;
      expect(
        hardSolver.fits(variant.figureSpec!, {'text': back}, slots),
        isTrue,
      );
      expect(hardSolver.validateRanges(hardType, variant), isEmpty);
    }
  });

  for (final pattern in patterns) {
    test('$pattern reproduces sources and independently checks fresh draws',
        () {
      final name = 'net-$pattern';
      expect(ruleRegistry, contains(name));
      expect(figureSolvers, contains(name));
      final files = [
        for (final root in ['content/types', 'content/types-held'])
          ...Directory(root).listSync(recursive: true).whereType<File>(),
      ].where(
        (f) => f.path.endsWith('qt-spatial-abstract-reasoning-$name.yaml'),
      );
      final type =
          parseProblemType(loadYaml(files.single.readAsStringSync()) as Map);
      final sources = readSourceQuestions(
        '.',
        'origin/content/bite-sized-cse-algebra-r1',
        type.mergedQuestions.map((m) => m.id).toSet(),
      );
      final fixed =
          generateVariants(type, count: type.mergedQuestions.length).variants;
      expect(checkVariants(type, fixed, questions: sources), isEmpty);
      final random = Random(13579);
      for (var i = 20; i < 60; i++) {
        final v = ruleRegistry[name]!.generate(type, random, i).variant;
        // No merged-source checks on an individual random draw.
        final unmerged =
            parseProblemType({...type.toMap(), 'mergedQuestions': <Object>[]});
        expect(checkVariants(unmerged, [v]), isEmpty, reason: '$name draw $i');
        if (pattern == 'adjacent-relation') {
          expect(v.slots['explanationText'], isNot(contains('free edges')));
          expect(v.slots['explanationText'], contains('share an edge'));

          for (final c in v.choices.where((c) => !c.correct)) {
            expect(c.slots['noteText'], isNot(contains('flat corner contact')));
            expect(c.slots['noteText'], isNot(contains('look apart on paper')));
          }
        }
        final solver = figureSolvers[name]!;
        final corrupt = parseVariants({
          'variants': [
            {
              ...v.toMap(),
              'figureSpec': {
                ...v.figureSpec!,
                'cells': [
                  [0, 0],
                  [0, 0],
                  [0, 1],
                  [0, 2],
                  [0, 3],
                  [0, 4],
                ],
              },
            }
          ],
        }).single;
        expect(solver.validateRanges(type, corrupt), isNotEmpty);
        if (pattern == 'three-at-corner') {
          final labels = (v.figureSpec!['labels']! as List).cast<String>();
          final validTriples = <String>[];
          for (var a = 0; a < 4; a++) {
            for (var b = a + 1; b < 5; b++) {
              for (var c = b + 1; c < 6; c++) {
                final text = '${labels[a]}, ${labels[b]}, ${labels[c]}';
                if (solver.fits(v.figureSpec!, {'text': text}, v.slots)) {
                  validTriples.add(text);
                }
              }
            }
          }
          expect(validTriples, hasLength(8));
        }
        final wrong = v.choices.firstWhere((c) => !c.correct);
        expect(
          solver.fits(v.figureSpec!, {'text': wrong.text}, v.slots),
          isFalse,
        );
      }
    });
  }
}
