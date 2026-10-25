import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('Flutter ships only the immutable protected content package assets', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final gitignore = File('.gitignore').readAsStringSync();
    final flutter = (loadYaml(pubspec) as YamlMap)['flutter'] as YamlMap;
    final assets = (flutter['assets'] as YamlList).map(
      (asset) => asset is String ? asset : (asset as YamlMap)['path'] as String,
    );

    for (final path in <String>[
      'assets/seed/content.db',
      'assets/seed/content.manifest.json',
      'assets/seed/content.manifest.sig',
    ]) {
      expect(assets, contains(path));
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
