import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Flutter ships only the immutable protected content package assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final gitignore = File('.gitignore').readAsStringSync();

    for (final path in <String>[
      'assets/seed/content.db',
      'assets/seed/content.manifest.json',
      'assets/seed/content.manifest.sig',
    ]) {
      expect(pubspec, contains('- $path'));
      expect(gitignore, contains(path));
    }

    expect(pubspec, isNot(contains('assets/seed/v1.json')));
    expect(pubspec, isNot(contains('historical_v1.json')));
    expect(File('assets/seed/v1.json').existsSync(), isFalse);
    expect(
      File('tools/build_content_export/historical_v1.json').existsSync(),
      isTrue,
    );
  });
}
