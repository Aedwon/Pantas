import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final spec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
  final flutter = spec['flutter'] as YamlMap;
  final families = flutter['fonts'] as YamlList;

  for (final entry in <String, List<int>>{
    'Geist': [400, 500, 600, 700],
    'Phosphor': [400],
  }.entries) {
    test('${entry.key} bundles every required weight for offline use', () {
      final declarations = families.cast<YamlMap>().where(
            (family) => family['family'] == entry.key,
          );
      expect(declarations, hasLength(1));
      final fonts = declarations.single['fonts'] as YamlList;
      expect(
        fonts.cast<YamlMap>().map((font) => font['weight'] ?? 400),
        unorderedEquals(entry.value),
      );
      for (final font in fonts.cast<YamlMap>()) {
        final file = File(font['asset'] as String);
        expect(file.existsSync(), isTrue, reason: file.path);
        expect(file.lengthSync(), greaterThan(0));
      }
    });
  }
  test('only current type and icon families are bundled', () {
    expect(
      families.cast<YamlMap>().map((family) => family['family']),
      unorderedEquals(['Geist', 'Phosphor']),
    );
  });
  test('bundled regular icon font is unchanged from package 2.1.0', () {
    expect(
      sha256
          .convert(
            File('assets/fonts/phosphor/Phosphor.ttf').readAsBytesSync(),
          )
          .toString(),
      '06b91e022b7ee899a63efced879392a74f0bacbda54e4467e9f663220d173a10',
    );
    expect(File('assets/fonts/phosphor/LICENSE').existsSync(), isTrue);
  });
}
