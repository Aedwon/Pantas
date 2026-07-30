import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:drift/drift.dart';

class TopicRepo {
  TopicRepo(this._db);

  final ContentDatabase _db;
  ContentDatabase get database => _db;

  Future<List<Topic>> bySubject(SubjectId subjectId) async {
    final rows = await (_db.select(_db.contentTopics)
          ..where(
            (row) =>
                row.subjectId.equals(subjectId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.ordering)]))
        .get();
    return rows.map(_topicFromRow).toList();
  }

  Future<List<Topic>> byExam(ExamId examId) async {
    final subjects = await (_db.select(_db.contentSubjects)
          ..where(
            (row) => row.examId.equals(examId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.ordering)]))
        .get();
    final topics = <Topic>[];
    for (final subject in subjects) {
      topics.addAll(await bySubject(subject.id));
    }
    return topics;
  }

  Future<Topic?> findById(TopicId id) async {
    final row = await (_db.select(_db.contentTopics)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _topicFromRow(row);
  }

  Topic _topicFromRow(ContentTopicRow row) {
    return Topic(
      id: row.id,
      subjectId: row.subjectId,
      name: row.name,
      ordering: row.ordering,
    );
  }
}
