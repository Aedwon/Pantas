// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/files.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'task_signature_test.dart' show changed, readType;

void main() {
  test('corner-edge generator and solver require square outlines', () {
    final t = readType('series-corner-edge-count');
    for (var i = 1; i <= 100; i++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(i), i).variant;
      expect(
        (v.figureSpec!['items']! as List).every(
          (Object? x) => (x! as Map)['form'] == 'square',
        ),
        isTrue,
        reason: 'seed $i',
      );
    }
    final v = ruleRegistry[t.rule]!.generate(t, Random(1), 0).variant;
    expect(
      figureSolvers[t.rule]!.fits(
        {
          ...v.figureSpec!,
          'items': [
            for (final x in v.figureSpec!['items']! as List)
              {...x as Map<String, Object?>, 'form': 'circle'},
          ],
        },
        {
          ...v.choices.first.figure!,
          'form': 'circle',
        },
        v.slots,
      ),
      isFalse,
    );
  });

  test('center-cut mistakes require unique extrema across the entire row', () {
    final t = readType('group-center-cuts');
    for (var i = 1; i <= 100; i++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(i), i).variant;
      final counts = (v.figureSpec!['shapes']! as List)
          .map((Object? x) => (x! as Map)['lines']! as int)
          .toList();
      expect(counts.where((x) => x == counts.reduce(min)).length, 1);
      expect(counts.where((x) => x == counts.reduce(max)).length, 1);
    }
    final v = ruleRegistry[t.rule]!.generate(t, Random(1), 0).variant;
    for (final counts in [
      [1, 1, 4, 2],
      [1, 2, 4, 4],
    ]) {
      final tied = changed(v, {
        'figureSpec': {
          ...v.figureSpec!,
          'shapes': [
            for (var i = 0; i < 4; i++)
              {
                'form': 'circle',
                'lines': counts[i],
                if (i == 3) 'through': 'off',
              },
          ],
        },
      });
      expect(
        () => mistakeSolvers[(t.rule, 'fewest-lines')]!(t, tied),
        throwsFormatException,
      );
    }
  });

  test('held line-count notes describe each actual line count', () {
    final t = readType('group-line-count');
    for (var i = 0; i < 30; i++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(i), i).variant;
      final row = v.figureSpec!['shapes']! as List;
      for (final c in v.choices.where((c) => !c.correct)) {
        final note = fillSlots(
          t.mistakes.singleWhere((m) => m.id == c.mistake).note,
          {...v.slots, ...c.slots},
        );
        final count = (row[int.parse(c.value!) - 1] as Map)['lines'];
        if (c.mistake != 'choose-first') expect(note, contains('$count'));
      }
    }
  });

  test('regenerated held lists pass all variants and reproduce prod 646326517',
      () {
    const counts = {
      'series-corner-edge-count': 8,
      'group-center-cuts': 3,
      'group-line-count': 20,
      'group-specific-rule': 45,
    };
    final types = counts.keys.map(readType).toList();
    final sources = readSourceQuestions(
      '.',
      '646326517',
      types.expand((t) => t.mergedQuestions.map((m) => m.id)).toSet(),
    );
    for (final t in types) {
      final file = Directory('content/types-held')
          .listSync(recursive: true)
          .whereType<File>()
          .singleWhere((f) => f.path.endsWith('/${t.id}.variants.yaml'));
      final list = parseVariantList(loadYaml(file.readAsStringSync()) as Map);
      expect(list.variants, hasLength(counts[t.rule]));
      expect(checkVariants(t, list.variants, questions: sources), isEmpty);
    }
  });

  test('assigned unresolved types cannot remain active', () {
    for (final suffix in [
      'series-corner-edge-count',
      'group-center-cuts',
      'group-line-count',
      'group-specific-rule',
    ]) {
      final active = Directory('content/types')
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('/qt-spatial-abstract-reasoning-$suffix.yaml'),
          );
      expect(active, isEmpty, reason: suffix);
      final held = Directory('content/types-held')
          .listSync(recursive: true)
          .whereType<File>()
          .singleWhere(
            (f) =>
                f.path.endsWith('/qt-spatial-abstract-reasoning-$suffix.yaml'),
          );
      expect(
        parseProblemType(loadYaml(held.readAsStringSync()) as Map).enabled,
        isFalse,
      );
    }
  });
}
