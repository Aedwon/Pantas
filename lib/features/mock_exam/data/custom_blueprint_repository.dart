import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';
import 'package:drift/drift.dart';

/// Stores the one blueprint a custom track carries, replaced on save.
class CustomBlueprintRepository {
  const CustomBlueprintRepository(this._db);

  final AppDatabase _db;

  Future<void> save(
    CustomBlueprint blueprint, {
    required Map<SubjectId, List<TopicId>> topicsBySubject,
    required DateTime now,
  }) {
    return _db.into(_db.customBlueprintsLocal).insertOnConflictUpdate(
          CustomBlueprintsLocalCompanion.insert(
            examId: blueprint.examId,
            totalQuestions: blueprint.effectiveQuestions,
            totalMinutes: blueprint.effectiveMinutes,
            sectionsJson: blueprint.toSectionsJson(topicsBySubject),
            sectionsTimedSeparately: Value(blueprint.sectionsTimedSeparately),
            updatedAt: now,
          ),
        );
  }

  Future<CustomBlueprintRow?> read(ExamId examId) {
    return (_db.select(_db.customBlueprintsLocal)
          ..where((b) => b.examId.equals(examId)))
        .getSingleOrNull();
  }

  Future<bool> exists(ExamId examId) async => await read(examId) != null;
}
