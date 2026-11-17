// ignore_for_file: avoid_relative_lib_imports
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generator/lib/src/check/check.dart';
import '../../../tool/generator/lib/src/check/files.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/generate.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'task_signature_test.dart' show readType;

void main() {
  test('independent checker rejects source interleaved doubling ambiguity', () {
    final t = readType('series-interleaved-count');
    final list = generateVariants(t, count: 1);
    final sources = readSourceQuestions(
      '.',
      'origin/content/bite-sized-cse-algebra-r1',
      t.mergedQuestions.map((m) => m.id).toSet(),
    );
    expect(
      checkVariants(t, list.variants, questions: sources)
          .where((f) => f.check == 'correctness'),
      isNotEmpty,
    );
  });
  test('new interleaved draws exclude the doubling reading', () {
    final t = readType('series-interleaved-count');
    final doubling = figureSolvers['series-interleaved-count-doubling']!;
    for (var i = 1; i <= 100; i++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(i), i).variant;
      for (final c in v.choices.where((c) => !c.correct)) {
        expect(doubling.fits(v.figureSpec!, c.figure!, v.slots), isFalse);
      }
    }
  });
  test('independent corner solver rejects outlines without four corners', () {
    final t = readType('series-size-corner-ray');
    final v = ruleRegistry[t.rule]!.generate(t, Random(1), 0).variant;
    Map<String, Object?> triangle(Map<String, Object?> item) =>
        {...item, 'form': 'triangle'};
    expect(
      figureSolvers[t.rule]!.fits(
        {
          ...v.figureSpec!,
          'items': (v.figureSpec!['items']! as List)
              .cast<Map<String, Object?>>()
              .map(triangle)
              .toList(),
        },
        triangle(v.choices.first.figure!),
        v.slots,
      ),
      isFalse,
    );
  });
  test('corner walk uses four-cornered figures only', () {
    final t = readType('series-size-corner-ray');
    for (var i = 1; i <= 100; i++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(i), i).variant;
      final items = v.figureSpec!['items']! as List;
      expect(
        items.every(
          (Object? x) => (x! as Map<String, Object?>)['form'] == 'square',
        ),
        isTrue,
        reason: 'seed $i',
      );
    }
  });
  test('ray restart note names what the selected ray does in this variant', () {
    final t = readType('series-ray-step');
    for (var i = 1; i <= 100; i++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(i), i).variant;
      final items =
          (v.figureSpec!['items']! as List).cast<Map<String, Object?>>();
      final repeatsLast = items.first['line'] == items.last['line'];
      final note = fillSlots(
        t.mistakes.singleWhere((m) => m.id == 'early-restart').note,
        v.slots,
      );
      expect(note, contains(repeatsLast ? 'last ray again' : 'first ray'));
      expect(note, isNot(contains('too soon')));
    }
  });
  test('generated medium grouping uses feature mistakes rather than positions',
      () {
    final t = readType('group-side-count-medium');
    for (var i = 2; i <= 100; i++) {
      final v = ruleRegistry[t.rule]!.generate(t, Random(i), i).variant;
      expect(
        v.choices.any((c) => c.mistake?.startsWith('choose-') ?? false),
        isFalse,
        reason: 'seed $i',
      );
    }
  });
  test('dot-relation maximum is unique and the hexagon cue distinguishes it',
      () {
    for (final rule in ['group-side-double-dots', 'group-dot-parity']) {
      final t = readType(rule);
      for (var i = 1; i <= 100; i++) {
        final v = ruleRegistry[rule]!.generate(t, Random(i), i).variant;
        final row =
            (v.figureSpec!['shapes']! as List).cast<Map<String, Object?>>();
        final counts = row.map((x) => x['dots']! as int).toList();
        final maximum = counts.reduce(max);
        expect(
          counts.where((x) => x == maximum).length,
          1,
          reason: '$rule seed $i',
        );
        if (rule == 'group-dot-parity') {
          expect(row.where((x) => x['form'] == 'hexagon').length, 1);
        }
      }
    }
  });
  test('easy side-count and boundary redraw repeated outline diagnoses', () {
    for (final rule in ['group-side-count-easy', 'group-boundary']) {
      final t = readType(rule);
      for (var i = 1; i <= 100; i++) {
        final v = ruleRegistry[rule]!.generate(t, Random(i), i).variant;
        final row =
            (v.figureSpec!['shapes']! as List).cast<Map<String, Object?>>();
        expect(row.map((x) => x['form']).toSet().length, row.length);
      }
    }
  });
  test('symmetry note does not call all symmetric polygons regular', () {
    final t = readType('group-specific-rule');
    expect(
      t.mistakes.singleWhere((m) => m.id == 'common-symmetry').note,
      isNot(contains('regular')),
    );
  });
  test('extrema mistake solver rejects a tied maximum', () {
    final t = readType('group-side-double-dots');
    final v = ruleRegistry[t.rule]!.generate(t, Random(1), 0).variant;
    // Keep a valid majority, but tie the hexagon and triangle at three dots.
    // The largest count cannot distinguish the hexagon.
    final raw = v.toMap();
    final figure = Map<String, Object?>.from(v.figureSpec!);
    figure['shapes'] = [
      for (final x in (figure['shapes']! as List).cast<Map<String, Object?>>())
        <String, Object?>{
          ...x.cast<String, Object?>(),
          'dots': ['hexagon', 'triangle'].contains(x['form']) ? 3 : 2,
        },
    ];
    raw['figureSpec'] = figure;
    final tied = changedVariant(raw);
    expect(
      () => mistakeSolvers[(t.rule, 'most-dots')]!(t, tied),
      throwsFormatException,
    );
  });
}

Variant changedVariant(Map<String, Object?> raw) => parseVariants({
      'variants': [raw],
    }).single;
