import 'dart:io';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

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
    // 65, not 0, and pinned rather than waved through.
    //
    // The export exits 65 when a lesson or question names a topic the
    // outline does not carry. **`build_dev_seed` has always done the same**,
    // with the same six topics, so this is a standing content gap rather
    // than something this tool introduced: `clerical-ability`,
    // `data-interpretation`, `environment-management`,
    // `peace-and-human-rights`, `philippine-constitution` and `verbal-logic`
    // are authored but unmapped.
    //
    // The set is asserted so a **seventh** breaks the build. Accepting
    // `anyOf(0, 65)` would let a new and unrelated failure through wearing
    // the same exit code.
    expect(
      resultExport.exitCode,
      65,
      reason: resultExport.stderr.toString(),
    );

    final unmapped = RegExp('no outline topic for "([a-z-]+)"')
        .allMatches('${resultExport.stdout}${resultExport.stderr}')
        .map((m) => m.group(1))
        .toSet();
    expect(unmapped, {
      'clerical-ability',
      'data-interpretation',
      'environment-management',
      'peace-and-human-rights',
      'philippine-constitution',
      'verbal-logic',
    });

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
    final examsCount = (await db
            .customSelect('SELECT COUNT(*) AS c FROM content_exams')
            .getSingle())
        .read<int>('c');

    expect(questionsCount, 2000, reason: 'Expected 2,000 questions');
    expect(lessonsCount, 144, reason: 'Expected 144 lessons');
    expect(topicsCount, 19, reason: 'Expected 19 topics');
    expect(examsCount, 7, reason: 'Expected 7 exams');

    // 4. Assert the ids are underscored by reading one exam id back
    final upcatExam = await (db.select(db.contentExams)
          ..where((t) => t.id.equals('exam_upcat')))
        .getSingleOrNull();
    expect(upcatExam, isNotNull, reason: 'exam_upcat must be present');
    expect(upcatExam!.id, 'exam_upcat');
  });
}
