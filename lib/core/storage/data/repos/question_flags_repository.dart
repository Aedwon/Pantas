import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/sync_state.dart';
import 'package:drift/drift.dart';

/// Durable practice flags. A flag set inside a mock lives on that attempt and
/// only reaches this table when the student converts it from the mock's
/// review, so nothing here writes itself from `mock_attempt.flagsJson`.
class QuestionFlagsRepository {
  QuestionFlagsRepository(this._db);

  final AppDatabase _db;

  Future<void> flag(QuestionId questionId) async {
    // flaggedAt refreshes on a repeat flag: it records the most recent time
    // the student said this one matters, which is what the list sorts on.
    await _db.into(_db.questionFlagsLocal).insertOnConflictUpdate(
          QuestionFlagsLocalCompanion(
            questionId: Value(questionId),
            flaggedAt: Value(DateTime.now()),
            syncState: Value(SyncState.pending.name),
          ),
        );
  }

  Future<void> unflag(QuestionId questionId) async {
    await (_db.delete(_db.questionFlagsLocal)
          ..where((row) => row.questionId.equals(questionId)))
        .go();
  }

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

  /// Custom order first for the rows that carry one, then most recently
  /// flagged. Null `sortIndex` sorts last so an unordered flag never
  /// displaces one the student placed by hand.
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
