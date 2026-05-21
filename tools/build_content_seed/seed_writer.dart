import 'dart:convert';
import 'dart:io';

import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/diagnostic_set_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/exam_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/lesson_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/mock_blueprint_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/mock_exam_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/question_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/subject_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/topic_parser.dart';
import 'package:drift/native.dart';

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln('Usage: seed_writer.dart <input.json> <output.db>');
    exitCode = 64;
    return;
  }
  await writeContentSeed(
    inputJson: File(args[0]),
    outputDb: File(args[1]),
  );
}

Future<void> writeContentSeed({
  required File inputJson,
  required File outputDb,
}) async {
  if (outputDb.existsSync()) {
    await outputDb.delete();
  }
  await outputDb.parent.create(recursive: true);
  final json =
      jsonDecode(await inputJson.readAsString()) as Map<String, dynamic>;
  final db = ContentDatabase(NativeDatabase(outputDb));
  try {
    await db.transaction(() async {
      await _insertMaybeList(json['exam'], (doc) {
        return db.into(db.contentExams).insertOnConflictUpdate(parseExam(doc));
      });
      await _insertMaybeList(json['subject'], (doc) {
        return db
            .into(db.contentSubjects)
            .insertOnConflictUpdate(parseSubject(doc));
      });
      await _insertMaybeList(json['topic'], (doc) {
        return db
            .into(db.contentTopics)
            .insertOnConflictUpdate(parseTopic(doc));
      });
      await _insertMaybeList(json['question'], (doc) async {
        final parsed = parseQuestion(doc);
        await db
            .into(db.contentQuestions)
            .insertOnConflictUpdate(parsed.question);
        await db.batch(
          (batch) => batch
            ..insertAllOnConflictUpdate(db.contentChoices, parsed.choices)
            ..insertAllOnConflictUpdate(
              db.contentQuestionExams,
              parsed.examLinks,
            ),
        );
      });
      await _insertMaybeList(json['lesson'], (doc) {
        return db
            .into(db.contentLessons)
            .insertOnConflictUpdate(parseLesson(doc));
      });
      await _insertMaybeList(json['mockBlueprint'], (doc) {
        return db
            .into(db.contentMockBlueprints)
            .insertOnConflictUpdate(parseMockBlueprint(doc));
      });
      await _insertMaybeList(json['mockExam'], (doc) {
        return db
            .into(db.contentMockExams)
            .insertOnConflictUpdate(parseMockExam(doc));
      });
      await _insertMaybeList(json['diagnosticSet'], (doc) {
        return db
            .into(db.contentDiagnosticSets)
            .insertOnConflictUpdate(parseDiagnosticSet(doc));
      });
    });
  } finally {
    await db.close();
  }
}

Future<void> _insertMaybeList(
  Object? value,
  Future<void> Function(Map<String, Object?> doc) insert,
) async {
  if (value == null) return;
  final docs = value is List ? value : [value];
  for (final doc in docs) {
    await insert(Map<String, Object?>.from(doc as Map));
  }
}
