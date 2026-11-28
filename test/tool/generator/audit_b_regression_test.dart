// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/solvers/mental_rotation/net_solver.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';

ProblemType typeFor(String name) => parseProblemType(
      loadYaml(
        [
          for (final root in ['content/types', 'content/types-held'])
            ...Directory(root).listSync(recursive: true).whereType<File>(),
        ]
            .singleWhere(
              (f) =>
                  f.path.endsWith('qt-spatial-abstract-reasoning-$name.yaml'),
            )
            .readAsStringSync(),
      ) as Map,
    );

void main() {
  test('hard net mistakes match path stops or actual directional neighbors',
      () {
    final type = typeFor('net-opposite-hard');
    for (var i = 2; i < 100; i++) {
      final v = ruleRegistry[type.rule]!.generate(type, Random(i), i).variant;
      final n = FoldedNet(v.figureSpec!);
      final front = n.index(v.slots['face']);
      final wrong = v.choices.skip(1).map((c) => n.index(c.text)).toList();
      if (v.slots['profile'] == 0) {
        final distances = n.distances(front);
        expect(wrong.map((i) => distances[i]), [2, 4, 5]);
        expect(distances.toSet(), hasLength(6));
      } else {
        final a = n.cells[front];
        expect(
          wrong.map((i) => (n.cells[i].$1 - a.$1, n.cells[i].$2 - a.$2)),
          [(1, 0), (0, -1), (0, 1)],
        );
      }
      expect(
        v.choices.skip(1).map((c) => c.slots['noteText']).toSet(),
        hasLength(3),
      );
    }
  });
  for (final pattern in ['size-dots', 'form-ray', 'size-transfer']) {
    test('$pattern freeze uses adjacent cell in same row', () {
      final type = typeFor('matrix-$pattern');
      for (var i = 1; i < 200; i++) {
        final v = ruleRegistry[type.rule]!.generate(type, Random(i), i).variant;
        final cells = v.figureSpec!['cells']! as List;
        final cols = v.figureSpec!['cols']! as int;
        final b = cells.indexOf('blank');
        final neighbor = cells[b % cols == 0 ? b + 1 : b - 1] as Map;
        for (final c in v.choices
            .where((c) => c.mistake?.startsWith('freeze-') ?? false)) {
          final key = switch (c.mistake) {
            'freeze-dots' => 'dots',
            'freeze-ray' => 'line',
            _ => 'edgeLines'
          };
          expect(c.figure![key], neighbor[key], reason: 'draw $i');
        }
      }
    });
  }
  test('dot-sum sequence error continues the input difference', () {
    final type = typeFor('matrix-dot-sum');
    for (var i = 1; i < 100; i++) {
      final v = ruleRegistry[type.rule]!.generate(type, Random(i), i).variant;
      final cells = v.figureSpec!['cells']! as List;
      final a = (cells[6] as Map)['dots']! as int;
      final b = (cells[7] as Map)['dots']! as int;
      expect(
        v.choices
            .singleWhere((c) => c.mistake == 'add-sequence-step')
            .figure!['dots'],
        2 * b - a,
      );
    }
  });
  test('library recognizes left-right ray reflection competitor', () {
    final shown = <String, Object?>{
      'kind': 'figure-matrix',
      'rows': 2,
      'cols': 2,
      'cells': [
        {'form': 'pentagon', 'line': 315},
        {'form': 'pentagon', 'line': 45},
        {'form': 'square', 'line': 180},
        'blank',
      ],
    };
    expect(
      figureSolvers.values
          .any((s) => s.fits(shown, {'form': 'square', 'line': 180}, {})),
      isTrue,
    );
  });
  test('checker rejects the audited reflection ambiguity', () {
    final type = typeFor('matrix-ray-turn');
    final base = ruleRegistry[type.rule]!.generate(type, Random(0), 0).variant;
    final bad = parseVariants({
      'variants': [
        {
          ...base.toMap(),
          'figureSpec': {
            'kind': 'figure-matrix',
            'rows': 2,
            'cols': 2,
            'cells': [
              {'form': 'pentagon', 'line': 315},
              {'form': 'pentagon', 'line': 45},
              {'form': 'square', 'line': 180},
              'blank',
            ],
          },
          'choices': [
            {
              'correct': true,
              'text': 'Square; ray W',
              'figure': {'form': 'square', 'line': 270},
            },
            {
              'mistake': 'hold-ray',
              'text': 'Square; ray S',
              'figure': {'form': 'square', 'line': 180},
            },
            {
              'mistake': 'copy-first-row-ray',
              'text': 'Square; ray NE',
              'figure': {'form': 'square', 'line': 45},
            },
            {
              'mistake': 'copy-first-row-form',
              'text': 'Pentagon; ray W',
              'figure': {'form': 'pentagon', 'line': 270},
            },
          ],
        },
      ],
    }).single;
    expect(
      checkVariants(type, [bad]).any(
        (f) =>
            f.check == 'correctness' &&
            f.reason == 'wrong choice completes a library rule',
      ),
      isTrue,
    );
  });
  test('ray-turn draws have no wrong reflection answer', () {
    final type = typeFor('matrix-ray-turn');
    for (var i = 1; i < 200; i++) {
      final v = ruleRegistry[type.rule]!.generate(type, Random(i), i).variant;
      final cells = v.figureSpec!['cells']! as List;
      final a = (cells[0] as Map)['line']! as int;
      final b = (cells[1] as Map)['line']! as int;
      if ((360 - a) % 360 == b) {
        final reflected = (360 - ((cells[2] as Map)['line']! as int)) % 360;
        expect(
          v.choices.skip(1).any(
                (c) =>
                    c.figure!['form'] == (cells[2] as Map)['form'] &&
                    c.figure!['line'] == reflected,
              ),
          isFalse,
          reason: 'draw $i',
        );
      }
    }
  });
  test('adjacent relation offers corner mistake only for flat corners', () {
    final type = typeFor('net-adjacent-relation');
    for (var i = 1; i < 150; i++) {
      final v = ruleRegistry[type.rule]!.generate(type, Random(i), i).variant;
      final n = FoldedNet(v.figureSpec!);
      final refs = (v.slots['faces']! as List).map(n.index).toList();
      final a = n.cells[refs[0]];
      final b = n.cells[refs[1]];
      expect(((a.$1 - b.$1).abs(), (a.$2 - b.$2).abs()), (1, 1));
    }
  });
}
