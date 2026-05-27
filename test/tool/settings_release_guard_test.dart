import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DEBUG_SETTINGS appears only in guarded settings debug code', () {
    final offenders = <String>[];
    var foundGuardedFlag = false;
    for (final file in _dartFiles('lib')) {
      final source = file.readAsStringSync();
      if (!source.contains('DEBUG_SETTINGS')) continue;
      final allowed = file.path.endsWith(
            'lib/features/settings/presentation/pages/debug_settings_page.dart',
          ) &&
          source.contains('kDebugMode') &&
          source.contains("bool.fromEnvironment('DEBUG_SETTINGS')");
      if (allowed) foundGuardedFlag = true;
      if (!allowed) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
    expect(foundGuardedFlag, isTrue);
  });
}

Iterable<File> _dartFiles(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
