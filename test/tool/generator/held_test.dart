// ignore_for_file: avoid_relative_lib_imports
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generator/lib/src/check/files.dart';
import 'check_support.dart';

void main() {
  for (final count in [0, 19, 20]) {
    test('active list floor at $count variants', () {
      final dir = Directory.systemTemp.createTempSync('active-floor-');
      addTearDown(() => dir.deleteSync(recursive: true));
      final typeText = File('test/tool/generator/fixtures/type.yaml')
          .readAsStringSync()
          .replaceFirst('rule: figureSeriesTurnStep', 'rule: testFigure')
          .split('mergedQuestions:')
          .first;
      File('${dir.path}/type.yaml').writeAsStringSync(
        '${typeText}mergedQuestions: []\n',
      );
      File('${dir.path}/type.variants.yaml').writeAsStringSync(
        jsonEncode({
          'problemType': 'qt-spatial-abstract-reasoning-turn-step',
          'generator': {'tool': 1, 'ruleVersion': 1, 'seed': 20261117},
          'variants': [
            for (var i = 0; i < count; i++)
              {
                'index': i,
                'slots': <String, Object?>{},
                'cosmetics': <String, Object?>{},
                'choices': <Object?>[],
                'ruleKey': 'key-$i',
                'signature': 'signature-$i',
              },
          ],
        }),
      );
      final errors = checkTypeFiles(root: '.', typesPath: dir.path);
      expect(
        errors.where((e) => e.check == 'list-floor').map((e) => e.reason),
        count < 20
            ? contains('active list holds $count variants; minimum is 20')
            : isEmpty,
        reason: errors.join('\n'),
      );
    });
  }

  setUp(registerTestSolvers);
  test('held type without a list passes schema and solver checks', () {
    final dir = Directory.systemTemp.createTempSync('types-held-');
    addTearDown(() => dir.deleteSync(recursive: true));
    File('${dir.path}/type.yaml').writeAsStringSync(
      File('test/tool/generator/fixtures/type.yaml')
          .readAsStringSync()
          .replaceFirst('rule: figureSeriesTurnStep', 'rule: testFigure'),
    );
    expect(checkTypeFiles(root: '.', typesPath: dir.path, held: true), isEmpty);
  });
  test('held type with an unknown solver fails without requiring a list', () {
    final dir = Directory.systemTemp.createTempSync('types-held-');
    addTearDown(() => dir.deleteSync(recursive: true));
    File('${dir.path}/type.yaml').writeAsStringSync(
      File('test/tool/generator/fixtures/type.yaml').readAsStringSync(),
    );
    final errors = checkTypeFiles(root: '.', typesPath: dir.path, held: true);
    expect(errors.single.check, 'correctness');
    expect(errors.single.reason, contains('no solver'));
  });
  test('CLI checks held types when the active directory is absent', () async {
    final dir = Directory.systemTemp.createTempSync('held-cli-');
    addTearDown(() => dir.deleteSync(recursive: true));
    final type = File('${dir.path}/type.yaml');
    final fixture =
        File('test/tool/generator/fixtures/type.yaml').readAsStringSync();
    type.writeAsStringSync(
      fixture.replaceFirst(
        'rule: figureSeriesTurnStep',
        'rule: series-ray-step',
      ),
    );
    final good = await Process.run('dart', [
      'run',
      'tool/generator/bin/check.dart',
      '--types',
      '${dir.path}/absent',
      '--held-types',
      dir.path,
    ]);
    expect(good.exitCode, 0, reason: '${good.stderr}');
    type.writeAsStringSync(fixture);
    final bad = await Process.run('dart', [
      'run',
      'tool/generator/bin/check.dart',
      '--types',
      '${dir.path}/absent',
      '--held-types',
      dir.path,
    ]);
    expect(bad.exitCode, 1);
    expect(bad.stderr, contains('no solver'));
  });
}
