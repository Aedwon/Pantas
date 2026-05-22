import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('quiz domain files do not import UI network or Firebase SDK packages',
      () {
    final offenders = <String>[];
    for (final file in _dartFiles('lib/features/quiz/domain')) {
      final source = file.readAsStringSync();
      final importsForbiddenPackage =
          source.contains('package:flutter/material.dart') ||
              source.contains('package:flutter/widgets.dart') ||
              source.contains('package:cloud_firestore/') ||
              source.contains('package:firebase_auth/') ||
              source.contains('package:dio/');
      if (importsForbiddenPackage) {
        offenders.add(file.path);
      }
    }

    expect(offenders, isEmpty);
  });

  test('quiz session persistence is app database scoped', () {
    final offenders = <String>[];
    final dir = Directory('lib/features/quiz/data');
    if (!dir.existsSync()) {
      return;
    }

    for (final file in _dartFiles(dir.path)) {
      final source = file.readAsStringSync();
      if (source.contains('/core/content/content_database.dart')) {
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
