import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:drift/drift.dart';

class SubjectRepo {
  SubjectRepo(this._db);

  final ContentDatabase _db;
  ContentDatabase get database => _db;

  Future<List<Subject>> byExam(ExamId examId) async {
    final rows = await (_db.select(_db.contentSubjects)
          ..where(
            (row) => row.examId.equals(examId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.ordering)]))
        .get();
    return [
      for (final row in rows)
        Subject(
          id: row.id,
          examId: row.examId,
          name: row.name,
          ordering: row.ordering,
        ),
    ];
  }
}
