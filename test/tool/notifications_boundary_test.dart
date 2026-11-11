import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notifications domain files do not import framework or plugin packages',
      () {
    final offenders = <String>[];
    for (final file in _dartFiles('lib/features/notifications/domain')) {
      final source = file.readAsStringSync();
      final hasForbiddenImport = source.contains('package:flutter/') ||
          source.contains('package:flutter_riverpod/') ||
          source.contains('package:firebase_') ||
          source.contains('package:cloud_') ||
          source.contains('package:drift/') ||
          source.contains('package:go_router/') ||
          source.contains('package:flutter_local_notifications/') ||
          source.contains('package:timezone/') ||
          source.contains('package:app_settings/');
      if (hasForbiddenImport) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });

  test('only flutter local notifications gateway imports plugin packages', () {
    final offenders = <String>[];
    for (final file in _dartFiles('lib/features/notifications')) {
      final source = file.readAsStringSync();
      final importsPlugin =
          source.contains('package:flutter_local_notifications/') ||
              source.contains('package:timezone/') ||
              source.contains('package:app_settings/');
      final allowed =
          file.path.endsWith('flutter_local_notifications_gateway_native.dart');
      if (importsPlugin && !allowed) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });

  test('notifications files do not import firebase messaging', () {
    final offenders = _dartFiles('lib/features/notifications')
        .where(
          (file) =>
              file.readAsStringSync().contains('package:firebase_messaging/'),
        )
        .map((file) => file.path)
        .toList();

    expect(offenders, isEmpty);
  });

  test('pubspec includes local notification dependencies only', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('flutter_local_notifications:'));
    expect(pubspec, contains('timezone:'));
    expect(pubspec, contains('app_settings:'));
  });
}

Iterable<File> _dartFiles(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}
