import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('replaced Settings placeholder is retired', () {
    expect(
      File('lib/features/settings/presentation/pages/not_built_yet_page.dart')
          .existsSync(),
      isFalse,
    );
  });
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

  test('settings files do not contain example.com legal placeholders', () {
    final offenders = <String>[];
    for (final file in _dartFiles('lib/features/settings')) {
      final source = file.readAsStringSync();
      if (source.contains('example.com')) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });

  test('settings UI does not expose export my data row', () {
    final offenders = <String>[];
    final forbidden = RegExp(r'(Export my data|exportData\()');
    for (final file in _dartFiles('lib/features/settings')) {
      final source = file.readAsStringSync();
      if (forbidden.hasMatch(source)) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });

  test('approved legal summary points rights requests to the DPO in About', () {
    final source = File('lib/features/legal/domain/legal_document.dart')
        .readAsStringSync();

    expect(source, contains('see, correct or delete your data'));
    expect(source, contains('data protection officer from About.'));
    final about =
        File('lib/features/settings/presentation/pages/about_page.dart')
            .readAsStringSync();
    expect(
      about.replaceAll(RegExp(r'\s+'), ''),
      contains('openDpoMail(contact.dpoEmail'),
    );
    expect(about, contains('SelectableText'));
    expect(source, isNot(contains('/export')));
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
