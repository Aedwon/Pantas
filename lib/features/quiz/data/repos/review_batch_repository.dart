import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/features/quiz/data/repos/quiz_session_repository.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/quiz/domain/models/review_batch_position.dart';
import 'package:pantas/features/quiz/domain/models/session_origin.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:uuid/uuid.dart';

/// Local Reviews metadata shares ordinary session transactions. It never owns
/// custom quizzes, schema, sync payloads, or account-wipe behavior.
class ReviewBatchRepository {
  ReviewBatchRepository(
    this._db, {
    ReviewBatchScope? Function(String userId, String examId)? currentScope,
  }) : _currentScope = currentScope ?? ((_, __) => null);
  final AppDatabase _db;
  final ReviewBatchScope? Function(String, String) _currentScope;
  static String key(String userId, String examId) =>
      'quiz_review_batch.v1.$userId.$examId';

  ReviewBatchScope? capture(String userId, String examId) =>
      _currentScope(userId, examId);
  bool _current(ReviewBatchScope scope) =>
      _currentScope(scope.userId, scope.examId)?.matches(scope) ?? false;
  void _guard(ReviewBatchScope scope, bool Function() canPersist) {
    if (!_current(scope) || !canPersist()) throw const _Cancelled();
  }

  void checkScope(ReviewBatchScope? scope) {
    if (scope != null && !_current(scope)) {
      throw StateError('Reviews account changed');
    }
  }

  Future<void> requireNoBatch(String userId, String examId) async {
    final pref = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(key(userId, examId))))
        .getSingleOrNull();
    if (pref == null) return;
    final scope = capture(userId, examId);
    if (scope == null) throw StateError('Reviews account changed');
    final batch = await _read(scope);
    checkScope(scope);
    if (batch != null && !batch.nextReady) {
      throw StateError('Reviews must be resumed or explicitly discarded');
    }
  }

  Future<QuizSessionLocalRow?> _row(String id) =>
      (_db.select(_db.quizSessions)..where((r) => r.id.equals(id)))
          .getSingleOrNull();
  Future<QuizSessionLocalRow?> _active(ReviewBatchScope scope) =>
      (_db.select(_db.quizSessions)
            ..where(
              (r) =>
                  r.userId.equals(scope.userId) &
                  r.examId.equals(scope.examId) &
                  r.completedAt.isNull() &
                  r.quitAt.isNull(),
            )
            ..limit(1))
          .getSingleOrNull();
  List<String> _ids(QuizSessionLocalRow row) =>
      (jsonDecode(row.questionIdsJson) as List<dynamic>).cast<String>();
  Future<void> _delete(ReviewBatchScope scope) => (_db.delete(_db.devicePrefs)
        ..where((r) => r.key.equals(key(scope.userId, scope.examId))))
      .go();
  Future<void> _save(StoredReviewBatch batch) =>
      _db.into(_db.devicePrefs).insertOnConflictUpdate(
            DevicePrefsCompanion.insert(
              key: key(batch.scope.userId, batch.scope.examId),
              value: jsonEncode(batch.toJson()),
            ),
          );

  Future<StoredReviewBatch?> _read(ReviewBatchScope scope) async {
    final pref = await (_db.select(_db.devicePrefs)
          ..where((r) => r.key.equals(key(scope.userId, scope.examId))))
        .getSingleOrNull();
    if (pref == null) return null;
    StoredReviewBatch batch;
    try {
      batch = StoredReviewBatch.parse(jsonDecode(pref.value), scope: scope);
    } on Object {
      throw StateError('Invalid Reviews metadata');
    }
    final anchor = await _row(batch.batchId);
    if (anchor == null) {
      await _delete(scope);
      return null;
    }
    // Retain anchored ownership until wipe/discard. Deleting it here would
    // let a second resume misclassify another principal's row as legacy.
    if (batch.scope.principal != scope.principal) {
      throw StateError('Reviews account changed');
    }
    if (!_matches(anchor, batch, 0)) throw StateError('Invalid Reviews anchor');
    for (var i = 0; i < batch.current; i++) {
      final previous = await _row(batch.sessionIds[i]);
      if (previous == null ||
          !_matches(previous, batch, i) ||
          previous.completedAt == null ||
          previous.quitAt != null) {
        throw StateError('Invalid Reviews history');
      }
    }
    final row = await _row(batch.sessionIds[batch.current]);
    if (row == null ||
        !_matches(row, batch, batch.current) ||
        row.quitAt != null ||
        (batch.nextReady != (row.completedAt != null))) {
      throw StateError('Invalid Reviews lifecycle');
    }
    return batch;
  }

  bool _matches(QuizSessionLocalRow row, StoredReviewBatch batch, int index) =>
      row.id == batch.sessionIds[index] &&
      row.userId == batch.scope.userId &&
      row.examId == batch.scope.examId &&
      row.origin == _origin(batch).storageValue &&
      batch.matchesQuestions(index, _ids(row));
  SessionOrigin _origin(StoredReviewBatch batch) => batch.ordering == 'blocked'
      ? SessionOrigin.todayTopic
      : SessionOrigin.todayInterleaved;

  Future<ReviewBatchSession?> start({
    required PreparedReviewBatch prepared,
    required ContentRepository content,
    required DateTime now,
    required bool Function() canPersist,
  }) async {
    final scope = prepared.scope;
    if (!_current(scope) || !canPersist()) return null;
    final ids = [for (final _ in prepared.chunks) const Uuid().v4()];
    try {
      // Cleanup is committed even when an old principal cannot use a batch.
      await _db.transaction(() async {
        _guard(scope, canPersist);
        await _read(scope);
        _guard(scope, canPersist);
      });
      return await _db.transaction(() async {
        _guard(scope, canPersist);
        final existing = await _read(scope);
        final active = await _active(scope);
        if (existing != null) {
          return _claim(existing, scope, content, now, canPersist);
        }
        if (active != null) throw StateError('Another quiz is paused');
        if (prepared.chunks.isEmpty) return null;
        final batch = StoredReviewBatch(
          scope: scope,
          localDay: prepared.localDay,
          sessionLength: prepared.preferences.sessionLength,
          ordering: prepared.preferences.ordering.storageValue,
          sessionIds: ids,
          chunks: [
            for (final chunk in prepared.chunks) [for (final q in chunk) q.id],
          ],
          versions: [
            for (final chunk in prepared.chunks)
              [for (final q in chunk) q.version],
          ],
        );
        final questions = await _hydrate(batch, 0, content);
        _guard(scope, canPersist);
        await _insert(batch, 0, now);
        await _save(batch);
        _guard(scope, canPersist);
        final row = (await _row(ids.first))!;
        _guard(scope, canPersist);
        return _session(batch, row, questions);
      });
    } on _Cancelled {
      return null;
    }
  }

  Future<ReviewBatchSession?> continueBatch({
    required ReviewBatchScope scope,
    required ContentRepository content,
    required DateTime now,
    required bool Function() canPersist,
  }) async {
    if (!_current(scope) || !canPersist()) return null;
    // Orphan/principal invalidation must survive the caller's load failure.
    try {
      await _db.transaction(() async {
        _guard(scope, canPersist);
        await _read(scope);
        _guard(scope, canPersist);
      });
      return await _db.transaction(() async {
        _guard(scope, canPersist);
        final batch = await _read(scope);
        if (batch == null) throw StateError('Reviews batch is unavailable');
        return _claim(batch, scope, content, now, canPersist);
      });
    } on _Cancelled {
      return null;
    }
  }

  Future<ReviewBatchSession> _claim(
    StoredReviewBatch batch,
    ReviewBatchScope scope,
    ContentRepository content,
    DateTime now,
    bool Function() canPersist,
  ) async {
    final active = await _active(scope);
    if (active != null && active.id != batch.sessionIds[batch.current]) {
      throw StateError('Another quiz is paused');
    }
    if (batch.nextReady) {
      final next = batch.current + 1;
      final questions = await _hydrate(batch, next, content);
      _guard(scope, canPersist);
      await _insert(batch, next, now);
      final advanced = batch.advance(current: next, nextReady: false);
      await _save(advanced);
      _guard(scope, canPersist);
      final row = (await _row(batch.sessionIds[next]))!;
      _guard(scope, canPersist);
      return _session(advanced, row, questions);
    }
    if (active == null) throw StateError('Reviews session is unavailable');
    final questions = await _hydrate(batch, batch.current, content);
    _guard(scope, canPersist);
    return _session(batch, active, questions);
  }

  Future<void> _insert(StoredReviewBatch batch, int index, DateTime now) async {
    await _db.into(_db.quizSessions).insert(
          QuizSessionsCompanion.insert(
            id: batch.sessionIds[index],
            userId: batch.scope.userId,
            examId: batch.scope.examId,
            origin: _origin(batch).storageValue,
            questionIdsJson: jsonEncode(batch.chunks[index]),
            startedAt: now,
          ),
        );
  }

  Future<List<Question>> _hydrate(
    StoredReviewBatch batch,
    int index,
    ContentRepository content,
  ) async {
    final questions =
        await content.hydrateSelectedQuestions(batch.chunks[index]);
    validateHydration(batch, index, questions);
    return questions;
  }

  void validateHydration(
    StoredReviewBatch batch,
    int index,
    List<Question> questions,
  ) {
    if (!batch.matchesQuestions(index, [for (final q in questions) q.id]) ||
        !const ListEquality<int>().equals(
          batch.versions[index],
          [for (final q in questions) q.version],
        ) ||
        questions.any((q) => !q.examIds.contains(batch.scope.examId))) {
      throw StateError('Reviews content changed');
    }
  }

  ReviewBatchSession _session(
    StoredReviewBatch batch,
    QuizSessionLocalRow row,
    List<Question> questions,
  ) {
    final outcomes = (jsonDecode(row.outcomesJson) as List<dynamic>)
        .map((v) => v as Map<String, dynamic>)
        .toList();
    if (row.currentIndex != outcomes.length ||
        outcomes.length > questions.length) {
      throw StateError('Invalid Reviews answers');
    }
    for (var i = 0; i < outcomes.length; i++) {
      if (outcomes[i]['questionId'] != questions[i].id ||
          outcomes[i]['questionVersion'] != questions[i].version) {
        throw StateError('Invalid Reviews answer order');
      }
    }
    return ReviewBatchSession(
      session: QuizSession(
        sessionId: row.id,
        examId: row.examId,
        questions: questions,
        currentIndex: row.currentIndex.clamp(0, questions.length - 1),
        outcomes: row.outcomes,
        startedAt: row.startedAt,
        origin: SessionOrigin.fromStorage(row.origin),
        topicId: row.topicId,
        subtopicId: row.subtopicId,
        lessonId: row.lessonId,
        reviewBatch: ReviewBatchPosition(
          batchId: batch.batchId,
          userId: batch.scope.userId,
          ordinal: batch.current + 1,
          total: batch.chunks.length,
        ),
      ),
      ordinal: batch.current + 1,
      total: batch.chunks.length,
    );
  }

  /// Called transactionally by ordinary resume; no metadata means legacy.
  Future<StoredReviewBatch?> forRow(
    QuizSessionLocalRow row,
    ReviewBatchScope? scope,
  ) async {
    final pref = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(key(row.userId, row.examId))))
        .getSingleOrNull();
    if (pref == null) return null;
    if (scope == null || !_current(scope)) {
      throw StateError('Reviews account changed');
    }
    final batch = await _read(scope);
    checkScope(scope);
    if (batch == null) throw StateError('Reviews session changed');
    if (!batch.sessionIds.contains(row.id)) return null;
    if (batch.nextReady || !_matches(row, batch, batch.current)) {
      throw StateError('Reviews session changed');
    }
    return batch;
  }

  /// Runs inside saveAtomically/completeRequired, before terminal row writes.
  Future<void> completeRow(
    QuizSessionLocalRow row,
    ReviewBatchScope? scope,
    QuizSession? session,
  ) async {
    final batch = await forRow(row, scope);
    if (batch == null) return;
    if (row.currentIndex != batch.chunks[batch.current].length ||
        row.outcomes.length != row.currentIndex) {
      throw StateError('Reviews session has unanswered questions');
    }
    for (var i = 0; i < row.outcomes.length; i++) {
      if (row.outcomes[i].questionId != batch.chunks[batch.current][i] ||
          row.outcomes[i].questionVersion != batch.versions[batch.current][i]) {
        throw StateError('Reviews answer order changed');
      }
    }
    if (session != null) {
      validateHydration(batch, batch.current, session.questions);
      if (!const ListEquality<AnswerOutcome>()
              .equals(row.outcomes, session.outcomes) ||
          session.origin.storageValue != row.origin ||
          session.examId != row.examId) {
        throw StateError('Reviews completion changed');
      }
    }
    if (batch.current == batch.chunks.length - 1) {
      await _delete(scope!);
    } else {
      await _save(batch.advance(current: batch.current, nextReady: true));
    }
    _guard(scope!, () => true);
  }

  Future<void> discardForSessions(
    String userId,
    String examId,
    List<String> sessionIds,
  ) async {
    final scope = capture(userId, examId);
    final pref = await (_db.select(_db.devicePrefs)
          ..where((p) => p.key.equals(key(userId, examId))))
        .getSingleOrNull();
    if (pref == null || sessionIds.isEmpty) return;
    if (scope == null) throw StateError('Reviews account changed');
    final batch = await _parseForDiscard(pref.value, scope);
    if (batch == null) {
      checkScope(scope);
      return;
    }
    final anchor = await _row(batch.batchId);
    if (anchor == null) {
      await _delete(scope);
      checkScope(scope);
      return;
    }
    if (batch.scope.principal != scope.principal) {
      throw StateError('Reviews account changed');
    }
    if (sessionIds.contains(batch.sessionIds[batch.current])) {
      await _delete(scope);
    }
    checkScope(scope);
  }

  Future<StoredReviewBatch?> _parseForDiscard(
    String value,
    ReviewBatchScope scope,
  ) async {
    Object? raw;
    try {
      raw = jsonDecode(value);
    } on FormatException {
      await _delete(scope);
      return null;
    }
    if (raw is Map<String, dynamic> &&
        raw['principal'] is String &&
        raw['principal'] != scope.principal &&
        raw['batchId'] is String) {
      if (await _row(raw['batchId'] as String) != null) {
        throw StateError('Reviews account changed');
      }
    }
    try {
      return StoredReviewBatch.parse(raw, scope: scope);
    } on Object {
      await _delete(scope);
      return null;
    }
  }

  /// Explicit Reviews discard also works between chunks. It never quits an
  /// unrelated ordinary quiz and checks ownership inside the quit transaction.
  Future<void> discardBatch({
    required ReviewBatchScope scope,
    required DateTime now,
  }) =>
      _db.transaction(() async {
        checkScope(scope);
        final pref = await (_db.select(_db.devicePrefs)
              ..where((p) => p.key.equals(key(scope.userId, scope.examId))))
            .getSingleOrNull();
        if (pref == null) return;
        if (await _parseForDiscard(pref.value, scope) == null) {
          checkScope(scope);
          return;
        }
        final batch = await _read(scope);
        if (batch == null) return;
        await (_db.update(_db.quizSessions)
              ..where(
                (r) =>
                    r.id.equals(batch.sessionIds[batch.current]) &
                    r.completedAt.isNull() &
                    r.quitAt.isNull(),
              ))
            .write(QuizSessionsCompanion(quitAt: Value(now)));
        await _delete(scope);
        checkScope(scope);
      });
}

class _Cancelled implements Exception {
  const _Cancelled();
}
