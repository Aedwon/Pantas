import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('study plan module exists with domain data and presentation layers', () {
    expect(Directory('lib/features/study_plan/domain').existsSync(), isTrue);
    expect(Directory('lib/features/study_plan/data').existsSync(), isTrue);
    expect(
        Directory('lib/features/study_plan/presentation').existsSync(), isTrue);
  });

  test(
      'study plan domain files do not import framework or persistence packages',
      () {
    final offenders = <String>[];
    final dir = Directory('lib/features/study_plan/domain');
    if (!dir.existsSync()) {
      fail('lib/features/study_plan/domain does not exist');
    }

    for (final file in _dartFiles(dir.path)) {
      final source = file.readAsStringSync();
      final importsForbiddenPackage = source.contains('package:flutter/') ||
          source.contains('package:flutter_riverpod/') ||
          source.contains('package:cloud_firestore/') ||
          source.contains('package:firebase_auth/') ||
          source.contains('package:dio/') ||
          source.contains('package:drift/');
      if (importsForbiddenPackage) {
        offenders.add(file.path);
      }
    }

    expect(offenders, isEmpty);
  });

  test(
      'study plan data files do not import content database internals directly',
      () {
    final offenders = <String>[];
    final dir = Directory('lib/features/study_plan/data');
    if (!dir.existsSync()) {
      fail('lib/features/study_plan/data does not exist');
    }

    for (final file in _dartFiles(dir.path)) {
      final source = file.readAsStringSync();
      if (source.contains('/core/content/content_database.dart')) {
        offenders.add(file.path);
      }
    }

    expect(offenders, isEmpty);
  });

  test('content database does not contain study plan preference tables', () {
    final offenders = <String>[];
    for (final file in _dartFiles('lib/core/content')) {
      final source = file.readAsStringSync();
      final hasStudyPlanTable =
          source.contains('PlanPrefs') || source.contains('study_plan');
      if (hasStudyPlanTable) offenders.add(file.path);
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
