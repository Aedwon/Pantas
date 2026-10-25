import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('Flutter assets declare the protected content package companions', () {
    final pubspec =
        loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    final flutter = pubspec['flutter'] as YamlMap;
    final entries = flutter['assets'] as YamlList;
    final assets = entries
        .map(
          (asset) =>
              asset is String ? asset : (asset as YamlMap)['path'] as String,
        )
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

    for (final path
        in assets.where((path) => path.startsWith('assets/seed/'))) {
      final entry = entries.whereType<YamlMap>().singleWhere(
            (entry) => entry['path'] == path,
          );
      expect(
        entry['platforms'],
        unorderedEquals(
          <String>['android', 'ios', 'linux', 'macos', 'windows'],
        ),
        reason: '$path must remain native-only',
      );
    }
  });
}
