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

const groupingPatterns = [
  'side-count-easy',
  'outline-symmetry',
  'center-cuts',
  'dot-count',
  'boundary',
  'side-count-medium',
  'line-count',
  'specific-rule',
  'region-parity',
  'side-parity',
  'dot-parity',
  'polygon-replacement',
  'side-double-dots',
];
void main() {
  test('generated grouping notes avoid source-only shape and position claims',
      () {
    const root = 'content/types/reasoning/spatial-abstract-reasoning/'
        'grouping-outlines-and-symmetry';
    final medium = parseProblemType(
      loadYaml(
        File(
          '$root/qt-spatial-abstract-reasoning-group-side-count-medium.yaml',
        ).readAsStringSync(),
      ) as Map,
    );
    final parity = parseProblemType(
      loadYaml(
        File(
          '$root/qt-spatial-abstract-reasoning-group-side-parity.yaml',
        ).readAsStringSync(),
      ) as Map,
    );
    final center = medium.mistakes.singleWhere((m) => m.id == 'choose-center');
    expect(center.note, isNot(contains('pentagon')));
    expect(center.note, isNot(contains('five sides')));
    final four =
        parity.mistakes.singleWhere((m) => m.id == 'exactly-four-not-even');
    expect(four.note, isNot(contains('first two')));
  });
  const booleanRows = <String, List<Map<String, Object?>>>{
    'outline-symmetry': [
      {'form': 'square'},
      {'form': 'blob'},
    ],
    'center-cuts': [
      {'form': 'circle', 'lines': 2},
      {'form': 'circle', 'lines': 2, 'through': 'off'},
    ],
    'boundary': [
      {'form': 'square'},
      {'form': 'circle'},
    ],
    'region-parity': [
      {'form': 'circle', 'lines': 2},
      {'form': 'circle', 'lines': 0},
    ],
    'side-parity': [
      {'form': 'hexagon'},
      {'form': 'triangle'},
    ],
    'dot-parity': [
      {'form': 'square', 'dots': 2},
      {'form': 'square', 'dots': 3},
    ],
    'side-double-dots': [
      {'form': 'square', 'dots': 2},
      {'form': 'square', 'dots': 3},
    ],
  };
  for (final entry in booleanRows.entries) {
    test('${entry.key} enforces the documented majority direction', () {
      final solver = figureSolvers['group-${entry.key}']!;
      for (var exception = 0; exception < 4; exception++) {
        for (final inverted in [false, true]) {
          final shown = <String, Object?>{
            'kind': 'shape-row',
            'shapes': [
              for (var i = 0; i < 4; i++)
                entry.value[(i == exception) != inverted ? 1 : 0],
            ],
          };
          for (var candidate = 0; candidate < 4; candidate++) {
            expect(
              solver.fits(
                shown,
                {'value': '${candidate + 1}'},
                {'operation': entry.key},
              ),
              !inverted && candidate == exception,
              reason: 'inverted=$inverted, exception=$exception',
            );
          }
        }
      }
    });
  }
  test('shape-row canonicalizer is registered', () {
    expect(figureCanonicalizers, contains('shape-row'));
  });
  for (final pattern in groupingPatterns) {
    test('$pattern reproduces production and passes independent checking', () {
      final name = 'group-$pattern';
      expect(ruleRegistry, contains(name));
      expect(figureSolvers, contains(name));
      final files = [
        for (final path in ['content/types', 'content/types-held'])
          if (Directory(path).existsSync())
            ...Directory(path).listSync(recursive: true),
      ].whereType<File>().where(
            (f) => f.path.endsWith('qt-spatial-abstract-reasoning-$name.yaml'),
          );
      final type =
          parseProblemType(loadYaml(files.single.readAsStringSync()) as Map);
      final list = generateVariants(type, count: type.mergedQuestions.length);
      final questions = readSourceQuestions(
        '.',
        'origin/content/bite-sized-cse-algebra-r1',
        type.mergedQuestions.map((m) => m.id).toSet(),
      );
      expect(checkVariants(type, list.variants, questions: questions), isEmpty);
      final base = list.variants.first;
      for (var i = 20; i < 40; i++) {
        final draw = ruleRegistry[name]!.generate(type, Random(i), i).variant;
        final row =
            (draw.figureSpec!['shapes']! as List).cast<Map<String, Object?>>();
        for (final choice in draw.choices) {
          final id = choice.mistake;
          if (id == 'choose-endpoint' || id == 'choose-first') {
            expect(choice.value, '1');
          }
          if (id == 'choose-center' || id == 'choose-central') {
            expect(choice.value, '2');
          }
          if (id == 'choose-last') expect(choice.value, '4');

          if (!['fewest-dots', 'most-dots', 'fewest-lines', 'most-regions']
              .contains(id)) {
            continue;
          }
          final field = id!.contains('dots') ? 'dots' : 'lines';
          final counts = row.map((x) => (x[field] as int?) ?? 0).toList();
          final expected =
              id.startsWith('fewest') ? counts.reduce(min) : counts.reduce(max);
          expect(
            counts[int.parse(choice.value!) - 1],
            expected,
            reason: '$pattern $id must select the full-row extremum',
          );
        }
      }
      final extraMark = parseVariants({
        'variants': [
          {
            ...base.toMap(),
            'figureSpec': {
              ...base.figureSpec!,
              'shapes': [
                {
                  ...(base.figureSpec!['shapes']! as List).first
                      as Map<String, Object?>,
                  'rotation': 17,
                },
                ...(base.figureSpec!['shapes']! as List).skip(1),
              ],
            },
          }
        ],
      }).single;
      expect(figureSolvers[name]!.validateRanges(type, extraMark), isNotEmpty);

      final rowLength = (base.figureSpec!['shapes']! as List).length;
      final reversed = parseVariants({
        'variants': [
          {
            ...base.toMap(),
            'figureSpec': {
              ...base.figureSpec!,
              'shapes': (base.figureSpec!['shapes']! as List).reversed.toList(),
            },
            'choices': base.choices
                .map(
                  (c) => {
                    ...c.toMap(),
                    if (base.slots['operation'] != 'specific-rule' &&
                        c.value != null &&
                        int.tryParse(c.value!) != null)
                      'value': '${rowLength + 1 - int.parse(c.value!)}',
                  },
                )
                .toList(),
          }
        ],
      }).single;
      expect(canonicalSignature(base), canonicalSignature(reversed));
    });
  }
}
