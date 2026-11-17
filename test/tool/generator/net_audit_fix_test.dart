// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/files.dart';
import '../../../tool/generator/lib/src/check/solvers/mental_rotation/net_solver.dart';
import '../../../tool/generator/lib/src/generate.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';

const directory = 'reasoning/spatial-abstract-reasoning/'
    'folding-and-checking-cube-nets';
ProblemType netType(String pattern) {
  final suffix = '$directory/qt-spatial-abstract-reasoning-net-$pattern.yaml';
  final active = File('content/types/$suffix');
  return parseProblemType(
    loadYaml(
      (active.existsSync() ? active : File('content/types-held/$suffix'))
          .readAsStringSync(),
    ) as Map,
  );
}

void main() {
  for (final item in [
    ('nonadjacent', 5),
    ('opposite-easy', 20),
    ('opposite-easy', 5),
    ('opposite-medium', 15),
    ('top-and-shadow', 41),
  ]) {
    test('solver rejects audited false premise ${item.$1} ${item.$2}', () {
      final bad = parseVariants(
        loadYaml(
          File('test/tool/generator/fixtures/net_false_premises.json')
              .readAsStringSync(),
        ) as Map,
      );
      final v = bad.singleWhere(
        (v) => v.slots['operation'] == 'net-${item.$1}' && v.index == item.$2,
      );
      final wrong = v.choices.firstWhere((c) => !c.correct);
      expect(
        () => NetSolver(item.$1).mistake(v, wrong.mistake!),
        throwsFormatException,
      );
    });
  }
  test('regenerated held lists pass the independent checker', () {
    for (final pattern in [
      'nonadjacent',
      'opposite-easy',
      'opposite-medium',
      'top-and-shadow',
      'adjacent-relation',
      'validity-test',
    ]) {
      final t = netType(pattern);
      final list = parseVariantList(
        loadYaml(
          File('content/types-held/'
                  '$directory/${t.id}.variants.yaml')
              .readAsStringSync(),
        ) as Map,
      );
      final sources = readSourceQuestions(
        '.',
        '646326517',
        t.mergedQuestions.map((m) => m.id).toSet(),
      );
      expect(
        checkVariants(t, list.variants, questions: sources),
        isEmpty,
        reason: pattern,
      );
      stdout.writeln(
        '$pattern: ${list.variants.length} variants, checker failures: 0',
      );
    }
  });
  test('all six types reproduce prod root 646326517 exactly', () {
    for (final pattern in [
      'nonadjacent',
      'opposite-easy',
      'opposite-medium',
      'top-and-shadow',
      'adjacent-relation',
      'validity-test',
    ]) {
      final t = netType(pattern);
      final sources = readSourceQuestions(
        '.',
        '646326517',
        t.mergedQuestions.map((m) => m.id).toSet(),
      );
      final fixed =
          generateVariants(t, count: t.mergedQuestions.length).variants;
      expect(checkVariants(t, fixed, questions: sources), isEmpty);
    }
  });
  for (final pattern in ['nonadjacent', 'opposite-easy', 'top-and-shadow']) {
    test('$pattern named neighbors have their actual direction', () {
      final t = netType(pattern);
      final random = Random(13579);
      for (var i = 0; i < 100; i++) {
        final v = ruleRegistry[t.rule]!.generate(t, random, i).variant;
        final n = FoldedNet(v.figureSpec!);
        if (pattern == 'opposite-easy' && v.slots['profile'] == 1) continue;
        final target = n.cells[n.index(v.slots['face'])];
        final directions = switch (pattern) {
          'nonadjacent' => [(-1, 0), (0, 1), (1, 0)],
          'opposite-easy' => [(-1, 0), (0, -1), (1, 0)],
          _ => [(0, 1), (-1, 0), (1, 0)],
        };
        final wrong = v.choices.where((c) => !c.correct).toList();
        for (var k = 0; k < 3; k++) {
          final cell =
              n.cells[n.labels.indexOf(wrong[k].text.split(';').first)];
          expect(
            cell,
            (target.$1 + directions[k].$1, target.$2 + directions[k].$2),
            reason: '$pattern index $i $k',
          );
        }
        expect(wrong.map((c) => c.slots['noteText']).toSet(), hasLength(3));
      }
    });
  }
  test('medium column-end mistake uses a different end of the same column', () {
    final t = netType('opposite-medium');
    final random = Random(13579);
    for (var i = 0; i < 100; i++) {
      final v = ruleRegistry[t.rule]!.generate(t, random, i).variant;
      final n = FoldedNet(v.figureSpec!);
      final target = n.cells[n.index(v.slots['face'])];
      final wrong = v.choices.where((c) => !c.correct).toList();
      final end = n.cells[n.labels.indexOf(wrong.first.text)];
      expect(end.$2, target.$2, reason: 'index $i');
      final rows = n.cells.where((p) => p.$2 == target.$2).map((p) => p.$1);
      expect(
        {rows.reduce(min), rows.reduce(max)},
        containsAll([target.$1, end.$1]),
      );
      final near = n.cells[n.labels.indexOf(wrong.last.text)];
      expect((near.$1 - target.$1).abs() + (near.$2 - target.$2).abs(), 1);
      expect(wrong.map((c) => c.slots['noteText']).toSet(), hasLength(3));
    }
  });
  for (final pattern in ['adjacent-relation', 'validity-test']) {
    test('R6 holds $pattern until its answers vary', () {
      expect(
        File('content/types/$directory/'
                'qt-spatial-abstract-reasoning-net-$pattern.yaml')
            .existsSync(),
        isFalse,
      );
      expect(
        File('content/types-held/$directory/'
                'qt-spatial-abstract-reasoning-net-$pattern.yaml')
            .existsSync(),
        isTrue,
      );
    });
  }
}
