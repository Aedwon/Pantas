import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content_database.dart';

void main() {
  test('the export builds the whole corpus into the content database',
      () async {
    // 1. Run the writer
    final tempDir = Directory.systemTemp.createTempSync('export_roundtrip');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final exportPath = '${tempDir.path}/export.json';
    final resultExport = await Process.run('dart', [
      'run',
      'tools/build_content_export/build_content_export.dart',
      exportPath,
    ]);
    // 0, and pinned so a regression cannot hide.
    //
    // This asserted 65 until 11 August, with the six authored-but-unmapped
    // topics listed as a standing content gap. That pinned the defect: the
    // export exits 65 when a lesson or question names a topic the outline
    // does not carry, and those questions are silently dropped. All six are
    // mapped now, so a whole corpus exits 0 and any new unmapped topic turns
    // the build red instead of joining an accepted list.
    expect(
      resultExport.exitCode,
      0,
      reason: resultExport.stderr.toString(),
    );

    final unmapped = RegExp('no outline topic for "([a-z-]+)"')
        .allMatches('${resultExport.stdout}${resultExport.stderr}')
        .map((m) => m.group(1))
        .toSet();
    expect(unmapped, isEmpty);

    // 2. Feed its output to seed_writer.dart
    final dbPath = '${tempDir.path}/content.db';
    final resultSeed = await Process.run('dart', [
      'run',
      'tools/build_content_seed/seed_writer.dart',
      exportPath,
      dbPath,
    ]);
    expect(resultSeed.exitCode, 0, reason: resultSeed.stderr.toString());

    // 3. Open the database and count
    final file = File(dbPath);
    expect(file.existsSync(), isTrue);

    final db = ContentDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final questionsCount = (await db
            .customSelect('SELECT COUNT(*) AS c FROM content_questions')
            .getSingle())
        .read<int>('c');
    final lessonsCount = (await db
            .customSelect('SELECT COUNT(*) AS c FROM content_lessons')
            .getSingle())
        .read<int>('c');
    final topicsCount = (await db
            .customSelect('SELECT COUNT(*) AS c FROM content_topics')
            .getSingle())
        .read<int>('c');
    // The QA bank has 158 ordered lessons out of 161. The three CSE
    // vocabulary lessons remain outside the audit. The app sorts lesson
    // lists by this position, so the export must preserve it.
    final orderedLessons = (await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM content_lessons WHERE ordering > 0',
            )
            .getSingle())
        .read<int>('c');
    expect(orderedLessons, 158);
    final examsCount = (await db
            .customSelect('SELECT COUNT(*) AS c FROM content_exams')
            .getSingle())
        .read<int>('c');
    final passagesCount = (await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM content_passages',
            )
            .getSingle())
        .read<int>('c');
    final lessonLinksCount = (await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM content_questions '
              'WHERE lesson_id IS NOT NULL',
            )
            .getSingle())
        .read<int>('c');
    final passageLinksCount = (await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM content_questions '
              'WHERE passage_id IS NOT NULL',
            )
            .getSingle())
        .read<int>('c');

    // The October QA expansion exports 3,163 active lesson-linked questions
    // plus two historical CSE placeholders without lesson links. Passage
    // links increased to 260 while the 32 passages stayed unchanged.
    expect(questionsCount, 3165, reason: 'Expected 3,165 questions');
    expect(lessonsCount, 161, reason: 'Expected 161 lessons');
    expect(topicsCount, 26, reason: 'Expected 26 topics');
    expect(examsCount, 9, reason: 'Expected 9 exams including scholarships');
    expect(passagesCount, 32, reason: 'Expected 32 passages');
    expect(lessonLinksCount, 3163, reason: 'Expected 3,163 lesson links');
    expect(passageLinksCount, 260, reason: 'Expected 260 passage links');

    // 4. Assert the ids are underscored by reading one exam id back
    final upcatExam = await (db.select(db.contentExams)
          ..where((t) => t.id.equals('exam_upcat')))
        .getSingleOrNull();
    expect(upcatExam, isNotNull, reason: 'exam_upcat must be present');
    expect(upcatExam!.id, 'exam_upcat');
  });
}
