import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/wrapped/domain/share_id_generator.dart';

void main() {
  test('generates a 32-character lowercase hex token', () {
    final id = ShareIdGenerator().generate();

    expect(id, hasLength(32));
    expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(id), isTrue);
  });

  test('two calls produce different tokens', () {
    final generator = ShareIdGenerator();

    expect(generator.generate(), isNot(generator.generate()));
  });

  test('is deterministic when seeded for tests', () {
    String first() => ShareIdGenerator(random: Random(7)).generate();

    expect(first(), first());
  });
}
