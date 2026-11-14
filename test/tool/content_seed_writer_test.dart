import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/repos/lesson_repo.dart';

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

  test('seed stores and hydrates bite-sized metadata', () async {
    final temp = Directory.systemTemp.createTempSync('metadata-seed');
    addTearDown(() => temp.deleteSync(recursive: true));
    final doc = jsonDecode(
      File('test/fixtures/sanity/content_sample.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final lessons =
        doc['lesson'] is List ? doc['lesson'] as List : [doc['lesson']];
    final lesson = lessons.first as Map<String, dynamic>
      ..addAll({
        'quizSize': 3,
        'status': 'retired',
        'replacedBy': ['part-one'],
        'part': 1,
        'partCount': 2,
        'keyPoints': ['Recall', 'Apply'],
        'ordering': 8,
      })
      ..remove('estimatedMinutes');
    final questions =
        doc['question'] is List ? doc['question'] as List : [doc['question']];
    (questions.first as Map<String, dynamic>)['keyPoint'] = 2;
    final input = File('${temp.path}/input.json')
      ..writeAsStringSync(jsonEncode(doc));
    final result = await Process.run('dart', [
      'run',
      'tools/build_content_seed/seed_writer.dart',
      input.path,
      '${temp.path}/content.db',
    ]);
    expect(result.exitCode, 0, reason: '${result.stderr}');
    final db = ContentDatabase(NativeDatabase(File('${temp.path}/content.db')));
    addTearDown(db.close);
    final stored =
        await db.customSelect('SELECT * FROM content_lessons').getSingle();
    expect(stored.data, containsPair('estimated_minutes', 0));
    expect(stored.data, containsPair('quiz_size', 3));
    expect(stored.data, containsPair('status', 'retired'));
    expect(stored.data, containsPair('replaced_by', '["part-one"]'));
    expect(stored.data, containsPair('part', 1));
    expect(stored.data, containsPair('part_count', 2));
    expect(stored.data, containsPair('key_points_json', '["Recall","Apply"]'));
    final question =
        await db.customSelect('SELECT * FROM content_questions').getSingle();
    expect(question.data, containsPair('key_point', 2));
    final hydrated =
        (await LessonRepo(db).findById(lesson['_id'] as String))!.toJson();
    for (final key in [
      'quizSize',
      'status',
      'replacedBy',
      'part',
      'partCount',
      'keyPoints',
      'ordering',
    ]) {
      expect(hydrated[key], lesson[key], reason: key);
    }
  });

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
