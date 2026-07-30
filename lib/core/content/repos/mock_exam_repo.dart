import 'package:drift/drift.dart';
import 'package:pantas/core/content/content_database.dart';
import 'package:pantas/core/content/domain/mock_exam.dart';

class MockExamRepo {
  MockExamRepo(this._db);

  final ContentDatabase _db;
  ContentDatabase get database => _db;

  Future<List<MockExam>> byBlueprint(String blueprintId) async {
    final rows = await (_db.select(_db.contentMockExams)
          ..where(
            (row) =>
                row.blueprintId.equals(blueprintId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.publishedAt)]))
        .get();
    return [
      for (final row in rows)
        MockExam(
          id: row.id,
          blueprintId: row.blueprintId,
          name: row.name,
          publishedAt: row.publishedAt,
        ),
    ];
  }
}
