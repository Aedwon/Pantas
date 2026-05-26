import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sync and content modules do not import each other', () {
    final syncOffenders = _dartFiles('lib/core/sync')
        .where((file) => file.readAsStringSync().contains('/core/content/'))
        .map((file) => file.path)
        .toList();
    final contentOffenders = _dartFiles('lib/core/content')
        .where((file) => file.readAsStringSync().contains('/core/sync/'))
        .map((file) => file.path)
        .toList();

    expect(syncOffenders, isEmpty);
    expect(contentOffenders, isEmpty);
  });

  test('sync module does not import paywall feature files', () {
    final offenders = _dartFiles('lib/core/sync')
        .where((file) => file.readAsStringSync().contains('/features/paywall/'))
        .map((file) => file.path)
        .toList();

    expect(offenders, isEmpty);
  });

  test('only sync firestore gateway files import Firebase SDK packages', () {
    final offenders = <String>[];
    for (final file in _dartFiles('lib/core/sync')) {
      final source = file.readAsStringSync();
      final importsSdk = source.contains('package:cloud_firestore/') ||
          source.contains('package:cloud_functions/');
      final allowed = file.path.contains('/firestore/');
      if (importsSdk && !allowed) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });
}

Iterable<File> _dartFiles(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
