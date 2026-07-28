import 'dart:io';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reading comprehension questions resolve to their passages', () async {
    final tempDir = Directory.systemTemp.createTempSync('rc_roundtrip');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final exportPath = '${tempDir.path}/export.json';
    final resultExport = await Process.run('dart', [
      'run',
      'tools/build_content_export/build_content_export.dart',
      exportPath,
    ]);
    // 0 since 11 August: this asserted 65 while six authored topics were
    // unmapped and their questions dropped.
    expect(resultExport.exitCode, 0, reason: resultExport.stderr.toString());

    final dbPath = '${tempDir.path}/content.db';
    final resultSeed = await Process.run('dart', [
      'run',
      'tools/build_content_seed/seed_writer.dart',
      exportPath,
      dbPath,
    ]);
    expect(resultSeed.exitCode, 0, reason: resultSeed.stderr.toString());

    final file = File(dbPath);
    expect(file.existsSync(), isTrue);

    final db = ContentDatabase(NativeDatabase(file));
    addTearDown(db.close);

    const passageId = 'rc-cs-cc-p1';
    final passageRow = await (db.select(db.contentPassages)
          ..where((t) => t.id.equals(passageId)))
        .getSingleOrNull();

    expect(passageRow, isNotNull, reason: 'Passage $passageId must exist');
    expect(passageRow!.body, contains('harbor juvenile bangus in shallow'));
    expect(passageRow.title, equals('Aquaculture Strategies in Laguna de Bay'));

    const questionId = 'rc-cs-cc-0001';
    final questionRow = await (db.select(db.contentQuestions)
          ..where((t) => t.id.equals(questionId)))
        .getSingleOrNull();

    expect(questionRow, isNotNull, reason: 'Question $questionId must exist');
    expect(questionRow!.passageId, equals(passageId));
  });
}
