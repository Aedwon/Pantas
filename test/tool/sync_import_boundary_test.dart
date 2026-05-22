import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only sync firestore gateway files import Firebase SDK packages', () {
    final syncFiles = Directory('lib/core/sync')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    final offenders = <String>[];
    for (final file in syncFiles) {
      final source = file.readAsStringSync();
      final importsSdk = source.contains('package:cloud_firestore/') ||
          source.contains('package:cloud_functions/');
      final allowed = file.path.contains('/firestore/');
      if (importsSdk && !allowed) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });
}
