import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CONTRIBUTING documents immutable by id and retire via isActive', () {
    final text = File('CONTRIBUTING.md').readAsStringSync();

    expect(text, contains('immutable-by-id'));
    expect(text, contains('isActive: false'));
    expect(text, contains('schemaVersion'));
  });

  test('Sanity setup docs mention required setup values', () {
    final text = File('docs/content/sanity-setup.md').readAsStringSync();

    expect(text, contains('SANITY_PROJECT_ID'));
    expect(text, contains('SANITY_DATASET'));
    expect(text, contains('apicdn.sanity.io'));
    expect(text, contains('SANITY_READ_TOKEN'));
  });

  test('docs do not contain prohibited attribution strings', () {
    final files = [
      File('CONTRIBUTING.md'),
      File('docs/content/sanity-setup.md'),
      File('docs/quiz-modes.md'),
    ];

    for (final file in files) {
      final text = file.readAsStringSync().toLowerCase();
      expect(text, isNot(contains('ai-generated')), reason: file.path);
    }
  });

  test('quiz mode docs mention storage and scope boundaries', () {
    final text = File('docs/quiz-modes.md').readAsStringSync();
    final lower = text.toLowerCase();

    expect(text, contains('content.db'));
    expect(text, contains('app.db'));
    expect(text, contains('quiz_attempts'));
    expect(text, contains('Mock Exam'));
    expect(lower, contains('paywall'));
  });
}
