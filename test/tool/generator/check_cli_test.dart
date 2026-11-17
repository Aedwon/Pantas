// ignore_for_file: avoid_relative_lib_imports
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CLI skips absent types with a note', () async {
    final result = await Process.run('dart', [
      'run',
      'tool/generator/bin/check.dart',
      '--types',
      'missing-types-for-test',
    ]);
    expect(result.exitCode, 0);
    expect(result.stdout, contains('no content/types/'));
  });
  test('CLI rejects unknown arguments', () async {
    final result = await Process.run(
      'dart',
      ['run', 'tool/generator/bin/check.dart', '--unknown'],
    );
    expect(result.exitCode, 1);
  });
  test('CLI fails with contextual diagnostics for an unknown rule', () async {
    final dir = await Directory.systemTemp.createTemp('qg-check-');
    addTearDown(() => dir.delete(recursive: true));
    await File('${dir.path}/type.yaml').writeAsString(
      File('test/tool/generator/fixtures/type.yaml').readAsStringSync(),
    );
    await File('${dir.path}/type.variants.yaml').writeAsString(
      File('test/tool/generator/fixtures/variants.yaml').readAsStringSync(),
    );
    final result = await Process.run('dart', [
      'run',
      'tool/generator/bin/check.dart',
      '--types',
      dir.path,
      '--questions-ref',
      'origin/content/bite-sized-cse-algebra-r1',
    ]);
    expect(result.exitCode, 1);
    expect(
      result.stderr,
      contains('qt-spatial-abstract-reasoning-turn-step #0 correctness:'),
    );
  });
}
