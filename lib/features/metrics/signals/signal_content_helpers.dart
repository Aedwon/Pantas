import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';

class SignalContentHelpers {
  const SignalContentHelpers(this._db);

  final AppDatabase _db;

  Future<QuestionRow?> question(String questionId) {
    return (_db.select(_db.questions)..where((q) => q.id.equals(questionId)))
        .getSingleOrNull();
  }

  Future<TopicRow?> topic(String topicId) {
    return (_db.select(_db.topics)..where((t) => t.id.equals(topicId)))
        .getSingleOrNull();
  }

  Future<SubjectRow?> subject(String subjectId) {
    return (_db.select(_db.subjects)..where((s) => s.id.equals(subjectId)))
        .getSingleOrNull();
  }

  Future<String?> subjectNameForQuestion(String questionId) async {
    final q = await question(questionId);
    if (q == null) return null;
    final t = await topic(q.topicId);
    if (t == null) return null;
    final s = await subject(t.subjectId);
    return s?.name;
  }

  Future<String?> topicIdForQuestion(String questionId) async {
    return (await question(questionId))?.topicId;
  }

  Future<int?> correctIndex(String questionId) async {
    final row = await question(questionId);
    if (row == null) return null;
    final choices = jsonDecode(row.choicesJson) as List;
    for (var i = 0; i < choices.length; i += 1) {
      final choice = choices[i];
      if (choice is Map<String, Object?> && choice['isCorrect'] == true) {
        return i;
      }
    }
    return null;
  }
}
