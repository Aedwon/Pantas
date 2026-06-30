import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Seeder {
  Seeder(this._db, {required AssetBundle bundle}) : _bundle = bundle;

  final AppDatabase _db;
  final AssetBundle _bundle;

  Future<void> maybeSeed({
    String assetPath = 'assets/seed/v1.json',
    int? contentVersion,
  }) async {
    final prefs = AppPreferencesRepository(_db);
    final storedVersion = await prefs.appliedContentVersion();

    if (storedVersion != null &&
        contentVersion != null &&
        storedVersion == contentVersion) {
      return;
    }

    final raw = await _bundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final bundledVersion = contentVersion ?? (json['contentVersion'] as int?);

    if (storedVersion != null && bundledVersion != null) {
      if (storedVersion == bundledVersion) {
        return;
      }
      if (storedVersion > bundledVersion) {
        debugPrint(
          'Skipping content seed downgrade: stored $storedVersion > '
          'bundled $bundledVersion',
        );
        return;
      }
    }

    await _db.transaction(() async {
      for (final e in (json['exams'] as List).cast<Map<String, dynamic>>()) {
        await _db.into(_db.exams).insertOnConflictUpdate(
              ExamsCompanion.insert(
                id: e['id'] as String,
                code: e['code'] as String,
                name: e['name'] as String,
                shortName: e['shortName'] as String,
                language: e['language'] as String,
                isActive: Value(e['isActive'] as bool? ?? true),
              ),
            );
        for (final s in (e['subjects'] as List).cast<Map<String, dynamic>>()) {
          await _db.into(_db.subjects).insertOnConflictUpdate(
                SubjectsCompanion.insert(
                  id: s['id'] as String,
                  examId: s['examId'] as String,
                  name: s['name'] as String,
                  ordering: s['ordering'] as int,
                ),
              );
        }
      }
      for (final t in (json['topics'] as List).cast<Map<String, dynamic>>()) {
        await _db.into(_db.topics).insertOnConflictUpdate(
              TopicsCompanion.insert(
                id: t['id'] as String,
                subjectId: t['subjectId'] as String,
                name: t['name'] as String,
                ordering: t['ordering'] as int,
              ),
            );
      }
      // Lessons come before questions: a question may name the lesson it was
      // authored for, and foreign keys are only unenforced until someone turns
      // the pragma on.
      for (final l in (json['lessons'] as List).cast<Map<String, dynamic>>()) {
        await _db.into(_db.lessons).insertOnConflictUpdate(
              LessonsCompanion.insert(
                id: l['id'] as String,
                topicId: l['topicId'] as String,
                title: l['title'] as String,
                summary: l['summary'] as String,
                bodyJson: jsonEncode(l['bodyJson']),
                estimatedMinutes: l['estimatedMinutes'] as int,
                ordering: Value(l['ordering'] as int? ?? 0),
              ),
            );
      }
      // Passages come before questions: a question references a passage, and
      // foreign keys are unenforced until foreign_keys PRAGMA is enabled.
      if (json['passages'] is List) {
        for (final p
            in (json['passages'] as List).cast<Map<String, dynamic>>()) {
          final body = (p['body'] as String).trim();
          final wordCount = p['wordCount'] as int? ??
              body.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
          await _db.into(_db.passages).insertOnConflictUpdate(
                PassagesCompanion.insert(
                  id: p['id'] as String,
                  topicId: p['topicId'] as String,
                  title: (p['title'] as String).trim(),
                  body: body,
                  language: p['language'] as String? ?? 'en',
                  wordCount: wordCount,
                ),
              );
        }
      }
      for (final q
          in (json['questions'] as List).cast<Map<String, dynamic>>()) {
        final qId = q['id'] as String;
        final qVersion = q['version'] as int;
        final existingQuestion = await (_db.select(_db.questions)
              ..where((row) => row.id.equals(qId)))
            .getSingleOrNull();

        if (existingQuestion == null || qVersion > existingQuestion.version) {
          await _db.into(_db.questions).insertOnConflictUpdate(
                QuestionsCompanion.insert(
                  id: qId,
                  version: qVersion,
                  examIdsJson: jsonEncode(q['examIds']),
                  topicId: q['topicId'] as String,
                  lessonId: Value(q['lessonId'] as String?),
                  passageId: Value(q['passageId'] as String?),
                  language: q['language'] as String,
                  stem: q['stem'] as String,
                  choicesJson: jsonEncode(q['choices']),
                  explanation: q['explanation'] as String,
                  shortLabel: Value(q['shortLabel'] as String?),
                  isWithdrawn: Value(q['isWithdrawn'] as bool? ?? false),
                ),
              );
        }
      }
    });

    if (bundledVersion != null) {
      await prefs.setAppliedContentVersion(bundledVersion);
    }
  }
}
