import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'committed token classes match design/system/tokens.json',
    () async {
      final result = await Process.run('dart', [
        'tool/design_system/generate_tokens.dart',
        '--check',
      ]);
      expect(
        result.exitCode,
        0,
        reason: '${result.stdout}\n${result.stderr}\n'
            'Run: dart run tool/design_system/generate_tokens.dart',
      );
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test('every generated file says it is generated', () {
    final dir = Directory('lib/core/ui/theme/tokens');
    final files = dir.listSync().whereType<File>().toList();
    expect(files, isNotEmpty);
    for (final file in files) {
      expect(
        file.readAsStringSync(),
        startsWith('// GENERATED, do not edit.'),
        reason: file.path,
      );
    }
  });
}
