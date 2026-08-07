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
    // 141 of 144 lessons carry a position within their topic. The app sorts
    // every lesson list by it, so losing it serves a structured course in
    // arbitrary order.
    final orderedLessons = (await db
            .customSelect(
              'SELECT COUNT(*) AS c FROM content_lessons WHERE ordering > 0',
            )
            .getSingle())
        .read<int>('c');
    // 141 before the six topics were mapped; the 17 lessons that arrived
    // with them carry their ordering too.
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

    // Up from 2,000 / 144 / 19 on 11 August, when the six unmapped topics
    // were added to the outline: General Information's 156 questions and
    // Reasoning's clerical and verbal-logic sets were authored and reaching
    // nobody, because a question whose topic the outline does not carry is
    // dropped by the export.
    // 2,258 from 13 August. Gears, springs, levers and pulleys are drawn by
    // the app now, so those questions stopped being held back as
    // figure-pending. The number moves with each family that lands.
    expect(questionsCount, 2307, reason: 'Expected 2,307 questions');
    expect(lessonsCount, 161, reason: 'Expected 161 lessons');
    expect(topicsCount, 26, reason: 'Expected 26 topics');
    expect(examsCount, 7, reason: 'Expected 7 exams');
    expect(passagesCount, 32, reason: 'Expected 32 passages');
    expect(lessonLinksCount, 2305, reason: 'Expected 2,305 lesson links');
    expect(passageLinksCount, 160, reason: 'Expected 160 passage links');

    // 4. Assert the ids are underscored by reading one exam id back
    final upcatExam = await (db.select(db.contentExams)
          ..where((t) => t.id.equals('exam_upcat')))
        .getSingleOrNull();
    expect(upcatExam, isNotNull, reason: 'exam_upcat must be present');
    expect(upcatExam!.id, 'exam_upcat');
  });
}
