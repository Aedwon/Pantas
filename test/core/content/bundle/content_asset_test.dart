import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('Flutter assets declare the protected content package companions', () {
    final pubspec =
        loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final flutter = pubspec['flutter'] as YamlMap;
    final assets = (flutter['assets'] as YamlList)
        .map((asset) => asset as String)
        .toList(growable: false);

    expect(
      assets,
      containsAll(<String>[
        'assets/seed/content.db',
        'assets/seed/content.manifest.json',
        'assets/seed/content.manifest.sig',
      ]),
    );
    expect(assets, isNot(contains('assets/seed/v1.json')));
    expect(assets, isNot(contains('assets/seed/')));
  });
}
