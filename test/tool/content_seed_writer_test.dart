import 'dart:io';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'seed_writer creates an openable content database from fixture JSON',
    () async {
      final tempDir = await Directory.systemTemp.createTemp('content_seed_');
      addTearDown(() => tempDir.delete(recursive: true));
      final output = File('${tempDir.path}/content.db');

      final result = await Process.run('dart', [
        'run',
        'tools/build_content_seed/seed_writer.dart',
        'test/fixtures/sanity/content_sample.json',
        output.path,
      ]);

      expect(result.exitCode, equals(0), reason: result.stderr as String?);
      final db = ContentDatabase(NativeDatabase(output));
      addTearDown(db.close);
      expect(await db.select(db.contentExams).get(), hasLength(1));
      expect(await db.select(db.contentQuestions).get(), hasLength(1));
    },
  );

  test('build.mjs requires Sanity env vars for live fetch', () async {
    final result = await Process.run(
      'node',
      [
        'tools/build_content_seed/build.mjs',
      ],
      environment: {
        'SANITY_PROJECT_ID': '',
        'SANITY_DATASET': '',
        'SANITY_READ_TOKEN': '',
      },
    );

    expect(result.exitCode, isNot(0));
    expect(result.stderr as String, contains('SANITY_PROJECT_ID'));
  });
}
