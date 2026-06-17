import 'dart:convert';
import 'dart:io';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/repos/question_repo.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/question_parser.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Future<ProcessResult> _run(List<String> args) => Process.run(
      'dart',
      ['run', 'tools/import_questions/import_questions.dart', ...args],
    );

void main() {
  test('emits NDJSON docs the shipping parser accepts', () async {
    final tmp = await Directory.systemTemp.createTemp('iq_ndjson_');
    addTearDown(() => tmp.delete(recursive: true));
    // Point at a root that contains only the good fixture.
    final root = Directory('${tmp.path}/science/biology')
      ..createSync(recursive: true);
    File('${root.path}/cell-structure.yaml').writeAsStringSync(
      File('test/fixtures/questions/science/biology/cell-structure.yaml')
          .readAsStringSync(),
    );

    final result = await _run(['--root', tmp.path]);
    expect(result.exitCode, 0, reason: result.stderr as String?);

    final lines = (result.stdout as String)
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    expect(lines, hasLength(2));
    for (final line in lines) {
      final doc = Map<String, Object?>.from(jsonDecode(line) as Map);
      expect(doc['_type'], 'question');
      expect(() => parseQuestion(doc), returnsNormally);
    }
    // Figure-pending question is inactive.
    final byId = {
      for (final l in lines)
        (jsonDecode(l) as Map)['_id'] as String: jsonDecode(l) as Map,
    };
    expect(byId['q-biology-cell-structure-0002']!['isActive'], false);
  });

  test('fails loudly on an invalid question', () async {
    final tmp = await Directory.systemTemp.createTemp('iq_bad_');
    addTearDown(() => tmp.delete(recursive: true));
    final root = Directory('${tmp.path}/science/biology')
      ..createSync(recursive: true);
    File('${root.path}/bad.yaml').writeAsStringSync(
      File('test/fixtures/questions/science/biology/_bad.yaml')
          .readAsStringSync(),
    );

    final result = await _run(['--root', tmp.path]);
    expect(result.exitCode, isNot(0));
    expect(result.stderr as String, contains('q-biology-cell-structure-9001'));
  });

  test('seed-json builds an openable database via seed_writer', () async {
    final tmp = await Directory.systemTemp.createTemp('iq_seed_');
    addTearDown(() => tmp.delete(recursive: true));
    final root = Directory('${tmp.path}/science/biology')
      ..createSync(recursive: true);
    File('${root.path}/cell-structure.yaml').writeAsStringSync(
      File('test/fixtures/questions/science/biology/cell-structure.yaml')
          .readAsStringSync(),
    );
    final seed = '${tmp.path}/seed.json';

    final gen = await _run(['--root', tmp.path, '--seed-json', seed]);
    expect(gen.exitCode, 0, reason: gen.stderr as String?);

    final json = jsonDecode(File(seed).readAsStringSync()) as Map;
    expect((json['question'] as List), hasLength(2));
    expect((json['topic'] as List).first['_id'], 'topic-biology');
    expect((json['subject'] as List).first['_id'], 'subject-science');
    expect((json['exam'] as List).map((e) => e['_id']),
        containsAll(['exam-upcat', 'exam-dost-sei']));

    // Build a real database and hydrate through the shipping repo so choice
    // ids that collide across questions (same primary key -> silent
    // overwrite via insertOnConflictUpdate) are caught, not just json shape.
    final dbFile = File('${tmp.path}/content.db');
    final writer = await Process.run('dart', [
      'run',
      'tools/build_content_seed/seed_writer.dart',
      seed,
      dbFile.path,
    ]);
    expect(writer.exitCode, 0, reason: writer.stderr as String?);

    final db = ContentDatabase(NativeDatabase(dbFile));
    addTearDown(db.close);
    final repo = QuestionRepo(db);
    // byTopic only returns isActive rows; the fixture's second question is
    // figure-pending (isActive: false), so only the first is active here.
    final activeQuestions = await repo.byTopic('topic-biology');
    expect(activeQuestions, hasLength(1));
    final figurePending = await repo.findById('q-biology-cell-structure-0002');
    final allQuestions = [...activeQuestions, figurePending!];
    for (final q in allQuestions) {
      expect(q.choices, isNotEmpty, reason: '${q.id} lost its choices');
      expect(q.choices.where((c) => c.isCorrect), hasLength(1),
          reason: '${q.id} correct-choice count');
    }
    final allChoiceIds = allQuestions.expand((q) => q.choices.map((c) => c.id));
    expect(allChoiceIds.toSet(), hasLength(allChoiceIds.length),
        reason: 'choice ids must be unique across questions');
  });
}
