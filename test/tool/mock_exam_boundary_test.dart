import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock exam feature exposes a public barrel', () {
    final barrel = File('lib/features/mock_exam/mock_exam.dart');

    expect(barrel.existsSync(), isTrue);
  });

  test('mock exam feature does not import Sanity parser or client files', () {
    final dir = Directory('lib/features/mock_exam');
    if (!dir.existsSync()) {
      fail('lib/features/mock_exam must exist before Spec 5 ships');
    }

    final offenders = <String>[];
    for (final file in _dartFiles(dir.path)) {
      final source = file.readAsStringSync();
      final importsSanityInternals = source.contains('/core/content/sanity/') ||
          source.contains('sanity_client.dart') ||
          source.contains('groq_queries.dart') ||
          source.contains('/core/content/content_database.dart');
      if (importsSanityInternals) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });

  test('mock exam feature keeps content database out of attempt storage', () {
    final dir = Directory('lib/features/mock_exam');
    if (!dir.existsSync()) {
      fail('lib/features/mock_exam must exist before Spec 5 ships');
    }

    final offenders = <String>[];
    for (final file in _dartFiles(dir.path)) {
      final source = file.readAsStringSync();
      final importsContentDatabase =
          source.contains('/core/content/content_database.dart');
      if (importsContentDatabase) offenders.add(file.path);
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
