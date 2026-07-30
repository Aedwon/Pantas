import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';

/// The corpus lookups the signals need, against the content database.
///
/// A signal measures a student's own behaviour, but it has to name the subject
/// or the correct answer to do it, and that is corpus.
class SignalContentHelpers {
  const SignalContentHelpers(this._db);

  final ContentDatabase _db;

  Future<ContentQuestionRow?> question(String questionId) {
    return (_db.select(_db.contentQuestions)
          ..where((q) => q.id.equals(questionId)))
        .getSingleOrNull();
  }

  Future<ContentTopicRow?> topic(String topicId) {
    return (_db.select(_db.contentTopics)..where((t) => t.id.equals(topicId)))
        .getSingleOrNull();
  }

  Future<ContentSubjectRow?> subject(String subjectId) {
    return (_db.select(_db.contentSubjects)
          ..where((s) => s.id.equals(subjectId)))
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

  /// Which position the correct answer sits in, counting from zero.
  ///
  /// Choices used to be a JSON list on the question, so the index was the
  /// position in that list. They are rows in their own table now, ordered by
  /// `ordering`, and that order is what a student saw.
  Future<int?> correctIndex(String questionId) async {
    final choices = await (_db.select(_db.contentChoices)
          ..where(
            (choice) =>
                choice.questionId.equals(questionId) &
                choice.isActive.equals(true),
          )
          ..orderBy([(choice) => OrderingTerm.asc(choice.ordering)]))
        .get();
    for (var i = 0; i < choices.length; i += 1) {
      if (choices[i].isCorrect) return i;
    }
    return null;
  }
}
