import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

class Seeder {
  Seeder(this._db, {required AssetBundle bundle}) : _bundle = bundle;

  final AppDatabase _db;
  final AssetBundle _bundle;

  Future<void> maybeSeed({String assetPath = 'assets/seed/v1.json'}) async {
    final existing = await _db.select(_db.exams).get();
    if (existing.isNotEmpty) return;

    final raw = await _bundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    await _db.transaction(() async {
      for (final e in (json['exams'] as List).cast<Map<String, dynamic>>()) {
        await _db.into(_db.exams).insert(
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
          await _db.into(_db.subjects).insert(
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
        await _db.into(_db.topics).insert(
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
        await _db.into(_db.lessons).insert(
              LessonsCompanion.insert(
                id: l['id'] as String,
                topicId: l['topicId'] as String,
                title: l['title'] as String,
                summary: l['summary'] as String,
                bodyJson: jsonEncode(l['bodyJson']),
                estimatedMinutes: l['estimatedMinutes'] as int,
              ),
            );
      }
      for (final q
          in (json['questions'] as List).cast<Map<String, dynamic>>()) {
        await _db.into(_db.questions).insert(
              QuestionsCompanion.insert(
                id: q['id'] as String,
                version: q['version'] as int,
                examIdsJson: jsonEncode(q['examIds']),
                topicId: q['topicId'] as String,
                lessonId: Value(q['lessonId'] as String?),
                language: q['language'] as String,
                stem: q['stem'] as String,
                choicesJson: jsonEncode(q['choices']),
                explanation: q['explanation'] as String,
                shortLabel: Value(q['shortLabel'] as String?),
              ),
            );
      }
    });
  }
}
