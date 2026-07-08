import 'package:cse_cet_reviewer/core/fsrs/rating.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_log.dart';
import 'package:cse_cet_reviewer/core/storage/domain/review_state.dart';
import 'package:drift/drift.dart';

/// Append-only. A review that happened is a fact, so there is no update path.
///
/// This table is the optimizer's training data. Everything it stores is stored
/// because the rating cannot be reconstructed afterwards: the heuristic reads
/// the interval the card was on, and the review overwrites it.
class ReviewLogRepository {
  ReviewLogRepository(this._db);

  final AppDatabase _db;

  Future<void> insert(ReviewLog log) async {
    await _db.into(_db.reviewLogs).insert(
          ReviewLogsCompanion.insert(
            id: log.id,
            questionId: log.questionId,
            rating: log.rating.grade,
            state: _stateToRaw(log.state),
            due: log.due,
            stability: log.stability,
            difficulty: log.difficulty,
            elapsedDays: log.elapsedDays,
            lastElapsedDays: log.lastElapsedDays,
            scheduledDays: log.scheduledDays,
            review: log.review,
            durationMs: log.durationMs,
            isCorrect: log.isCorrect,
            heuristicVersion: Value(log.heuristicVersion),
          ),
        );
  }

  Future<List<ReviewLog>> byQuestionId(QuestionId questionId) async {
    final rows = await (_db.select(_db.reviewLogs)
          ..where((r) => r.questionId.equals(questionId))
          ..orderBy([(r) => OrderingTerm.asc(r.review)]))
        .get();
    return rows.map(_hydrate).toList();
  }

  /// Every row, oldest first. The optimizer reads this and nothing else.
  ///
  /// Ordered by time because a fit is split by time: it trains on the earlier
  /// reviews and is judged on the later ones it has not seen.
  Future<List<ReviewLog>> all({int? heuristicVersion}) async {
    final query = _db.select(_db.reviewLogs)
      ..orderBy([(r) => OrderingTerm.asc(r.review)]);
    if (heuristicVersion != null) {
      query.where((r) => r.heuristicVersion.equals(heuristicVersion));
    }
    return (await query.get()).map(_hydrate).toList();
  }

  Future<int> count() async {
    final rows = await _db.select(_db.reviewLogs).get();
    return rows.length;
  }

  ReviewLog _hydrate(ReviewLogRow r) {
    return ReviewLog(
      id: r.id,
      questionId: r.questionId,
      rating: Rating.fromGrade(r.rating),
      state: _stateFromRaw(r.state),
      due: r.due,
      stability: r.stability,
      difficulty: r.difficulty,
      elapsedDays: r.elapsedDays,
      lastElapsedDays: r.lastElapsedDays,
      scheduledDays: r.scheduledDays,
      review: r.review,
      durationMs: r.durationMs,
      isCorrect: r.isCorrect,
      heuristicVersion: r.heuristicVersion,
    );
  }

  static int _stateToRaw(ReviewStage stage) => stage.index;

  static ReviewStage _stateFromRaw(int raw) => ReviewStage.values[raw];
}
