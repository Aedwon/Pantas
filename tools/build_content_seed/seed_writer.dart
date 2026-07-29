import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/diagnostic_set_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/exam_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/lesson_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/mock_blueprint_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/mock_exam_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/passage_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/question_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/subject_parser.dart';
import 'package:cse_cet_reviewer/core/content/sanity/parsers/topic_parser.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> args) async {
  if (args.length != 2) {
    stderr.writeln('Usage: seed_writer.dart <input.json> <output.db>');
    exitCode = 64;
    return;
  }
  final outputDb = File(args[1]);
  await writeContentSeed(
    inputJson: File(args[0]),
    outputDb: outputDb,
  );
  // Only the shipped asset has a version worth recording. Tests build the
  // database into a temp directory through this same entry point, and writing
  // then would stamp the app with the digest of a fixture.
  if (p
      .normalize(outputDb.path)
      .endsWith(p.join('assets', 'seed', 'content.db'))) {
    await _writeVersionFile(outputDb);
  }
}

/// Records what was just built, so the installer never has to be told by hand.
///
/// The installer writes the bundled database to a device only when this string
/// differs from the one the device recorded. It used to be a date maintained by
/// whoever remembered: Content 01, 01b and 03 each regenerated the asset and
/// none of them changed it, and then a same-day rebuild slipped past a bump
/// because a date cannot tell two builds in one day apart. A digest of the
/// bytes cannot be forgotten and cannot collide.
Future<void> _writeVersionFile(File outputDb) async {
  final digest = sha256.convert(await outputDb.readAsBytes());
  final version = digest.toString().substring(0, 16);
  final target = File('lib/core/content/content_seed_version.dart');
  await target.writeAsString('''
// Written by tools/build_content_seed/seed_writer.dart. Do not edit by hand.
//
// Deliberately not a `.g.dart` file: those are gitignored here, and this one
// has to be committed so it travels with the asset it describes.
//
// A digest of `assets/seed/content.db` as built. Rebuild the asset and this
// changes with it, which is what tells an installed app its copy is stale.

const contentSeedVersion = '$version';
''');
  stdout.writeln('content seed version: $version');
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
      await _insertMaybeList(json['passage'], (doc) {
        return db
            .into(db.contentPassages)
            .insertOnConflictUpdate(parsePassage(doc));
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
