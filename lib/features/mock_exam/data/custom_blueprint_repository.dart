import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/features/mock_exam/domain/custom_blueprint.dart';

/// Stores the one blueprint a custom track carries, replaced on save.
class CustomBlueprintRepository {
  CustomBlueprintRepository(
    this._db, {
    LocalSyncMutationRecorder? syncRecorder,
  }) : _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db);

  final AppDatabase _db;
  final LocalSyncMutationRecorder _syncRecorder;

  Future<void> save(
    CustomBlueprint blueprint, {
    required Map<SubjectId, List<TopicId>> topicsBySubject,
    required DateTime now,
  }) =>
      _syncRecorder.runRecorded(
        collection: 'custom_blueprints',
        rowId: blueprint.examId,
        op: SyncLocalMutationOp.upsert,
        mutate: () =>
            _db.into(_db.customBlueprintsLocal).insertOnConflictUpdate(
                  CustomBlueprintsLocalCompanion.insert(
                    examId: blueprint.examId,
                    totalQuestions: blueprint.effectiveQuestions,
                    totalMinutes: blueprint.effectiveMinutes,
                    sectionsJson: blueprint.toSectionsJson(topicsBySubject),
                    sectionsTimedSeparately:
                        Value(blueprint.sectionsTimedSeparately),
                    updatedAt: now,
                  ),
                ),
      );

  Future<CustomBlueprintRow?> read(ExamId examId) {
    return (_db.select(_db.customBlueprintsLocal)
          ..where((b) => b.examId.equals(examId)))
        .getSingleOrNull();
  }

  Future<bool> exists(ExamId examId) async => await read(examId) != null;
}
