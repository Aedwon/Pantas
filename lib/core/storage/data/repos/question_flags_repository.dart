import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/sync_state.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';

/// Durable practice flags. A flag set inside a mock lives on that attempt and
/// only reaches this table when the student converts it from the mock's
/// review, so nothing here writes itself from `mock_attempt.flagsJson`.
class QuestionFlagsRepository {
  QuestionFlagsRepository(
    this._db, {
    LocalSyncMutationRecorder? syncRecorder,
  }) : _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db);

  final AppDatabase _db;
  final LocalSyncMutationRecorder _syncRecorder;

  Future<void> flag(QuestionId questionId) => _syncRecorder.runRecorded(
        collection: 'question_flags',
        rowId: questionId,
        op: SyncLocalMutationOp.upsert,
        mutate: () => _db.into(_db.questionFlagsLocal).insertOnConflictUpdate(
              QuestionFlagsLocalCompanion(
                questionId: Value(questionId),
                flaggedAt: Value(DateTime.now()),
                syncState: Value(SyncState.pending.name),
              ),
            ),
      );

  Future<void> unflag(QuestionId questionId) => _syncRecorder.runRecorded(
        collection: 'question_flags',
        rowId: questionId,
        op: SyncLocalMutationOp.delete,
        mutate: () => (_db.delete(_db.questionFlagsLocal)
              ..where((row) => row.questionId.equals(questionId)))
            .go(),
      );

  Future<bool> isFlagged(QuestionId questionId) async {
    final row = await (_db.select(_db.questionFlagsLocal)
          ..where((flag) => flag.questionId.equals(questionId)))
        .getSingleOrNull();
    return row != null;
  }

  Future<Set<QuestionId>> flaggedIds() async {
    final rows = await _db.select(_db.questionFlagsLocal).get();
    return rows.map((row) => row.questionId).toSet();
  }

  Future<List<QuestionFlagLocalRow>> flagsNewestFirst() {
    return (_db.select(_db.questionFlagsLocal)
          ..orderBy([
            (row) => OrderingTerm(
                  expression: row.sortIndex,
                  nulls: NullsOrder.last,
                ),
            (row) => OrderingTerm.desc(row.flaggedAt),
          ]))
        .get();
  }

  Future<int> flagCount() async {
    final count = _db.questionFlagsLocal.questionId.count();
    final query = _db.selectOnly(_db.questionFlagsLocal)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}
