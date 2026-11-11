import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('plaintext seed writer cannot stamp the shipped content revision', () {
    final source =
        File('tools/build_content_seed/seed_writer.dart').readAsStringSync();

    expect(source, isNot(contains('content_seed_version.dart')));
    expect(source, isNot(contains('_writeVersionFile')));
    expect(source, isNot(contains('package:crypto/crypto.dart')));
  });
}
