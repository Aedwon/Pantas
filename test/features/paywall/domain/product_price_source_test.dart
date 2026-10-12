import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('payment domain and data never embed peso prices', () {
    for (final directory in ['domain', 'data']) {
      final files = Directory('lib/features/paywall/$directory')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      for (final file in files) {
        expect(
          file.readAsStringSync(),
          isNot(contains('₱')),
          reason: file.path,
        );
      }
    }
  });
}
