import 'package:cse_cet_reviewer/core/content/content_database.dart';
import 'package:cse_cet_reviewer/core/content/domain/mock_blueprint.dart';
import 'package:drift/drift.dart';

class MockBlueprintRepo {
  MockBlueprintRepo(this._db);

  final ContentDatabase _db;
  ContentDatabase get database => _db;

  Future<List<MockBlueprint>> byExam(String examId) async {
    final rows = await (_db.select(_db.contentMockBlueprints)
          ..where(
            (row) => row.examId.equals(examId) & row.isActive.equals(true),
          )
          ..orderBy([(row) => OrderingTerm.asc(row.name)]))
        .get();
    return [
      for (final row in rows)
        MockBlueprint(
          id: row.id,
          examId: row.examId,
          name: row.name,
          durationMinutes: row.durationMinutes,
          sectionsJson: row.sectionsJson,
        ),
    ];
  }
}
