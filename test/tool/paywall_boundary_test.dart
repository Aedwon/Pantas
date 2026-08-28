import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'paywall module exists with domain data application and presentation '
    'layers',
    () {
      expect(Directory('lib/features/paywall/domain').existsSync(), isTrue);
      expect(Directory('lib/features/paywall/data').existsSync(), isTrue);
      expect(
        Directory('lib/features/paywall/application').existsSync(),
        isTrue,
      );
      expect(
        Directory('lib/features/paywall/presentation').existsSync(),
        isTrue,
      );
    },
  );

  test(
    'paywall domain files do not import framework or persistence packages',
    () {
      final offenders = <String>[];
      final dir = Directory('lib/features/paywall/domain');
      if (!dir.existsSync()) {
        fail('lib/features/paywall/domain does not exist');
      }

      for (final file in _dartFiles(dir.path)) {
        final source = file.readAsStringSync();
        final importsForbiddenPackage = source.contains('package:flutter/') ||
            source.contains('package:flutter_riverpod/') ||
            source.contains('package:firebase_') ||
            source.contains('package:cloud_firestore/') ||
            source.contains('package:cloud_functions/') ||
            source.contains('package:purchases_flutter/') ||
            source.contains('package:drift/') ||
            source.contains('package:dio/') ||
            source.contains('package:go_router/');
        if (importsForbiddenPackage) offenders.add(file.path);
      }

      expect(offenders, isEmpty);
    },
  );

  test('only the RevenueCat SDK adapter imports purchases_flutter', () {
    final offenders = <String>[];
    final dir = Directory('lib/features/paywall');
    if (!dir.existsSync()) {
      fail('lib/features/paywall does not exist');
    }

    for (final file in _dartFiles(dir.path)) {
      final source = file.readAsStringSync();
      final importsSdk = source.contains('package:purchases_flutter/');
      final allowed = file.path.endsWith('revenuecat_sdk.dart');
      if (importsSdk && !allowed) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });

  test('paywall module does not import content database internals', () {
    final offenders = <String>[];
    final dir = Directory('lib/features/paywall');
    if (!dir.existsSync()) {
      fail('lib/features/paywall does not exist');
    }

    for (final file in _dartFiles(dir.path)) {
      final source = file.readAsStringSync();
      if (source.contains('/core/content/content_database.dart') ||
          source.contains('/core/content/sanity/')) {
        offenders.add(file.path);
      }
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
