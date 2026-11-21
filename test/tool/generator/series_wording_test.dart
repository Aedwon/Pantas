// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';

void main() {
  test('generated figures avoid invisible quarter-filled triangles', () {
    for (final root in ['content/types', 'content/types-held']) {
      for (final file
          in Directory(root).listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.yaml') ||
            file.path.endsWith('.variants.yaml')) {
          continue;
        }
        final type = parseProblemType(loadYaml(file.readAsStringSync()) as Map);
        if (!type.rule.startsWith('series-')) continue;
        for (var seed = 1; seed <= 100; seed++) {
          final variant = ruleRegistry[type.rule]!
              .generate(type, Random(seed), seed)
              .variant;
          final figures = [
            ...(variant.figureSpec!['items']! as List)
                .cast<Map<Object?, Object?>>(),
            ...variant.choices.map((choice) => choice.figure!),
          ];
          for (final figure in figures) {
            expect(
              figure['form'] == 'triangle' && figure['fill'] == .25,
              isFalse,
              reason: '${type.id} seed $seed: $figure',
            );
          }
        }
      }
    }
  });

  test('generated count descriptions use singular for one', () {
    for (final root in ['content/types', 'content/types-held']) {
      for (final file
          in Directory(root).listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.yaml') ||
            file.path.endsWith('.variants.yaml')) {
          continue;
        }
        final type = parseProblemType(loadYaml(file.readAsStringSync()) as Map);
        if (!type.rule.startsWith('series-')) continue;
        for (var seed = 1; seed <= 100; seed++) {
          final variant = ruleRegistry[type.rule]!
              .generate(type, Random(seed), seed)
              .variant;
          for (final choice in variant.choices) {
            for (final entry
                in {'dots': 'dot', 'edgeLines': 'edge line'}.entries) {
              // The source template leaves the requested dot count in the stem.
              if (type.rule == 'series-fill-ray-dots') continue;
              final count = choice.figure![entry.key];
              if (count == null) continue;
              const words = ['zero', 'one', 'two', 'three', 'four', 'five'];
              final label = count == 1 ? entry.value : '${entry.value}s';
              expect(
                choice.text.toLowerCase(),
                contains('${words[count as int]} $label'),
                reason: '${type.id} seed $seed',
              );
            }
          }
        }
      }
    }
  });

  test('generated descriptions avoid longest keys except corner positions', () {
    for (final path in ['content/types', 'content/types-held']) {
      for (final file
          in Directory(path).listSync(recursive: true).whereType<File>()) {
        if (file.path.endsWith('.variants.yaml')) {
          continue;
        }
        final type = parseProblemType(loadYaml(file.readAsStringSync()) as Map);
        // Re-audit ruling allows all four corner labels.
        if (type.rule == 'matrix-corner-step') continue;
        for (var seed = 1; seed <= 100; seed++) {
          final v = ruleRegistry[type.rule]!
              .generate(type, Random(seed), seed)
              .variant;
          final correct = v.choices.singleWhere((c) => c.correct).text.length;
          final longestWrong = v.choices
              .where((c) => !c.correct)
              .map((c) => c.text.length)
              .reduce(max);
          expect(
            correct,
            lessThanOrEqualTo(longestWrong),
            reason: '${type.id} seed $seed',
          );
        }
      }
    }
  });
}
