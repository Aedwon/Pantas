import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/subject.dart';

class ExamRepo {
  ExamRepo(this._db);

  final ContentDatabase _db;
  ContentDatabase get database => _db;

  Future<List<Exam>> activeExams() async {
    final examRows = await (_db.select(_db.contentExams)
          ..where((row) => row.isActive.equals(true))
          ..orderBy([(row) => OrderingTerm.asc(row.ordering)]))
        .get();
    final subjectRows = await (_db.select(_db.contentSubjects)
          ..where((row) => row.isActive.equals(true))
          ..orderBy([(row) => OrderingTerm.asc(row.ordering)]))
        .get();

    final subjectsByExam = <ExamId, List<Subject>>{};
    for (final row in subjectRows) {
      subjectsByExam.putIfAbsent(row.examId, () => []).add(
            Subject(
              id: row.id,
              examId: row.examId,
              name: row.name,
              ordering: row.ordering,
            ),
          );
    }

    return [
      for (final row in examRows)
        Exam(
          id: row.id,
          code: row.code,
          name: row.name,
          shortName: row.shortName,
          language: row.language,
          isActive: row.isActive,
          subjects: subjectsByExam[row.id] ?? const [],
        ),
    ];
  }

  Future<Exam?> findById(ExamId id) async {
    final row = await (_db.select(_db.contentExams)
          ..where((table) => table.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    final subjects = await (_db.select(_db.contentSubjects)
          ..where((table) => table.examId.equals(id))
          ..orderBy([(table) => OrderingTerm.asc(table.ordering)]))
        .get();
    return Exam(
      id: row.id,
      code: row.code,
      name: row.name,
      shortName: row.shortName,
      language: row.language,
      isActive: row.isActive,
      subjects: [
        for (final subject in subjects)
          Subject(
            id: subject.id,
            examId: subject.examId,
            name: subject.name,
            ordering: subject.ordering,
          ),
      ],
    );
  }

  Stream<List<Exam>> watchActive() =>
      _db.select(_db.contentExams).watch().asyncMap((_) => activeExams());
}
