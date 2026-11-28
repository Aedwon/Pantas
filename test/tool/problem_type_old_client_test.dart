// L7: content with type rows must not break a client built from current main.
// This test builds the real export and the real web documents, then reads them
// with the current client parsing code (called, not changed).
@Timeout(Duration(minutes: 5))
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/remote/content_catalog.dart';
import 'package:pantas/core/content/remote/question_set_mapper.dart';
import 'package:pantas/core/content/sanity/parsers/question_parser.dart';

Map<String, Object?> _json(File file) =>
    jsonDecode(file.readAsStringSync()) as Map<String, Object?>;

void main() {
  late Map<String, Object?> export;
  late Directory served;

  setUpAll(() async {
    final temp = Directory.systemTemp.createTempSync('old-client');
    addTearDown(() => temp.deleteSync(recursive: true));
    final exportFile = File('${temp.path}/export.json');
    final built = await Process.run('dart', [
      'tools/build_content_export/build_content_export.dart',
      exportFile.path,
    ]);
    expect(built.exitCode, 0, reason: built.stderr.toString());
    export = _json(exportFile);
    served = Directory('${temp.path}/served');
    final uploaded = await Process.run('node', [
      'tools/upload_content/upload_content.mjs',
      '--skip-invalid',
      '--export',
      exportFile.path,
      '--out-dir',
      served.path,
    ]);
    expect(
      uploaded.exitCode,
      0,
      reason: '${uploaded.stdout}${uploaded.stderr}',
    );
  });

  List<File> servedSets() => Directory('${served.path}/questions')
      .listSync()
      .whereType<File>()
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('the native question list holds no type row', () {
    final rows =
        (export['question']! as List<Object?>).cast<Map<String, Object?>>();
    expect(rows.where((row) => '${row['_id']}'.startsWith('qt-')), isEmpty);
    final types = (export['problemTypes']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((record) => (record['question']! as Map<String, Object?>)['id'])
        .toSet();
    expect(types, isNotEmpty);
    // The current seed parser still reads every row it is given.
    for (final row in rows) {
      expect(() => parseQuestion(row), returnsNormally);
    }
  });

  test('why the rows are kept out of questions: a type row there would show',
      () {
    final record = (export['problemTypes']! as List<Object?>).first!
        as Map<String, Object?>;
    final row = record['question']! as Map<String, Object?>;
    final shown = questionsFromSet({
      'meta': {
        'topic': 'spatial-abstract-reasoning',
        'subtopic': 'x',
        'exams': ['acet'],
      },
      'questions': [row],
    });
    // The old reader maps it to a question with the stem "null" and no choices.
    expect(shown, hasLength(1));
    expect(shown.single.stem, 'null');
    expect(shown.single.choices, isEmpty);
  });

  test('a current web client maps no question from a type-only set', () {
    final typeSets = servedSets().where(
      (file) => file.uri.pathSegments.last.startsWith('qs-types__'),
    );
    expect(typeSets, isNotEmpty);
    for (final file in typeSets) {
      final data = _json(file);
      expect(data['questions'], isEmpty);
      expect(data['problemTypes'], isNotEmpty);
      expect(questionsFromSet(data), isEmpty, reason: file.path);
    }
  });

  test('no served question of any set is a type row', () {
    for (final file in servedSets()) {
      final ids = [
        for (final question in questionsFromSet(_json(file))) question.id,
      ];
      expect(
        ids.where((id) => id.startsWith('qt-')),
        isEmpty,
        reason: file.path,
      );
    }
  });

  test('a current client still maps the merged source questions', () {
    final mergedIds =
        (export['mergedQuestionActivity']! as Map<String, Object?>)
            .keys
            .toSet();
    final mapped = <String>{};
    for (final file in servedSets()) {
      final data = _json(file);
      final raw =
          (data['questions']! as List<Object?>).cast<Map<String, Object?>>();
      final byId = {for (final question in raw) question['id']: question};
      for (final question in questionsFromSet(data)) {
        if (!mergedIds.contains(question.id)) continue;
        mapped.add(question.id);
        expect(question.stem, isNotEmpty);
        expect(question.stem, isNot(contains('{')));
        // The old reader ignores isActive in a served set, so it keeps serving
        // the source question while the new reader moves to the type.
        expect(byId[question.id]!.containsKey('isActive'), isTrue);
      }
    }
    expect(mapped, mergedIds);
  });

  test('a current client reads the catalog and counts no type as a question',
      () {
    final catalogs = Directory('${served.path}/catalog')
        .listSync()
        .whereType<File>()
        .where((file) => file.uri.pathSegments.last.startsWith('exam_'));
    var typeSets = 0;
    for (final file in catalogs) {
      final catalog = parseExamCatalog(_json(file));
      for (final set in catalog.sets) {
        for (final question in set.questions) {
          expect(question.id, isNot(startsWith('qt-')));
        }
        if (set.id.startsWith('qs-types__')) {
          typeSets++;
          expect(set.questions, isEmpty);
          expect(set.lessonId, isNotNull);
        }
      }
    }
    expect(typeSets, greaterThan(0));
  });
}
