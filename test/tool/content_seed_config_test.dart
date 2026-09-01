import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assets/seed/content.db is gitignored', () {
    final text = File('.gitignore').readAsStringSync();

    expect(text, contains('assets/seed/content.db'));
  });

  test('Node and Dart query files expose the same doctype names', () {
    final node =
        File('tools/build_content_seed/queries.mjs').readAsStringSync();
    final dart =
        File('lib/core/content/sanity/groq_queries.dart').readAsStringSync();

    for (final doctype in [
      'exam',
      'subject',
      'topic',
      'question',
      'lesson',
      'mockExam',
      'mockBlueprint',
      'diagnosticSet',
    ]) {
      expect(node, contains(doctype), reason: 'queries.mjs $doctype');
      expect(
        dart,
        contains("'$doctype'"),
        reason: 'groq_queries.dart $doctype',
      );
    }
  });

  test('CI workflows build the content seed from the corpus', () {
    for (final path in [
      '.github/workflows/ci.yml',
      '.github/workflows/main.yml',
    ]) {
      final workflow = File(path).readAsStringSync();
      expect(workflow, contains('tools/build_content_seed'), reason: path);
    }
  });
}
