import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:drift/drift.dart';

class ReviewStateRepository {
  ReviewStateRepository(this._db);

  final AppDatabase _db;

  Future<void> upsert(ReviewState state) async {
    await _db.into(_db.reviewStateLocal).insertOnConflictUpdate(
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
        );
  }

  Future<ReviewState?> byQuestionId(QuestionId id) async {
    final row = await (_db.select(_db.reviewStateLocal)
          ..where((r) => r.questionId.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _hydrate(row);
  }

  Future<List<ReviewState>> dirtyStates() async {
    final rows = await (_db.select(_db.reviewStateLocal)
          ..where((r) => r.dirty.equals(true)))
        .get();
    return rows.map(_hydrate).toList();
  }

  /// Every stored state. `FsrsDueSelector` takes the whole list and filters it,
  /// so there is no narrower query worth having here.
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
