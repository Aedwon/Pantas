import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/review_state.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';

class ReviewStateRepository {
  ReviewStateRepository(
    this._db, {
    LocalSyncMutationRecorder? syncRecorder,
  }) : _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db);

  final AppDatabase _db;
  final LocalSyncMutationRecorder _syncRecorder;

  Future<void> upsert(ReviewState state) => _syncRecorder.runRecorded(
        collection: 'fsrs_cards',
        rowId: state.questionId,
        op: SyncLocalMutationOp.upsert,
        mutate: () => _db.into(_db.reviewStateLocal).insertOnConflictUpdate(
              ReviewStateLocalCompanion.insert(
                questionId: state.questionId,
                questionVersion: state.questionVersion,
                stage: _stageToRaw(state.stage),
                stability: state.stability,
                difficulty: state.difficulty,
                due: state.due,
                lastReview: state.lastReview,
                reps: state.reps,
                lapses: state.lapses,
                elapsedDays: state.elapsedDays,
                scheduledDays: state.scheduledDays,
                dirty: const Value(true),
              ),
            ),
      );

  Future<ReviewState?> byQuestionId(QuestionId id) async {
    final row = await (_db.select(_db.reviewStateLocal)
          ..where((r) => r.questionId.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _hydrate(row);
  }

  Future<Map<QuestionId, ReviewState>> byQuestionIds(
    Iterable<QuestionId> ids,
  ) async {
    final wanted = ids.toSet().toList();
    if (wanted.isEmpty) return const {};

    const batchSize = 400;
    final states = <QuestionId, ReviewState>{};
    for (var start = 0; start < wanted.length; start += batchSize) {
      final end = (start + batchSize).clamp(0, wanted.length);
      final batch = wanted.sublist(start, end);
      final rows = await (_db.select(_db.reviewStateLocal)
            ..where((row) => row.questionId.isIn(batch)))
          .get();
      for (final row in rows) {
        states[row.questionId] = _hydrate(row);
      }
    }
    return states;
  }

  Future<List<ReviewState>> dirtyStates() async {
    final rows = await (_db.select(_db.reviewStateLocal)
          ..where((r) => r.dirty.equals(true)))
        .get();
    return rows.map(_hydrate).toList();
  }

  Future<List<ReviewState>> allStates() async {
    final rows = await _db.select(_db.reviewStateLocal).get();
    return rows.map(_hydrate).toList();
  }

  Future<void> markClean(QuestionId id) async {
    await (_db.update(_db.reviewStateLocal)
          ..where((r) => r.questionId.equals(id)))
        .write(const ReviewStateLocalCompanion(dirty: Value(false)));
  }

  ReviewState _hydrate(ReviewStateLocalRow r) => ReviewState(
        questionId: r.questionId,
        questionVersion: r.questionVersion,
        stage: _stageFromRaw(r.stage),
        stability: r.stability,
        difficulty: r.difficulty,
        due: r.due,
        lastReview: r.lastReview,
        reps: r.reps,
        lapses: r.lapses,
        elapsedDays: r.elapsedDays,
        scheduledDays: r.scheduledDays,
      );

  String _stageToRaw(ReviewStage s) => switch (s) {
        ReviewStage.newCard => 'new',
        ReviewStage.learning => 'learning',
        ReviewStage.review => 'review',
        ReviewStage.relearning => 'relearning',
      };

  ReviewStage _stageFromRaw(String raw) => switch (raw) {
        'new' => ReviewStage.newCard,
        'learning' => ReviewStage.learning,
        'review' => ReviewStage.review,
        'relearning' => ReviewStage.relearning,
        _ => ReviewStage.newCard,
      };
}
