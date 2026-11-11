import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/features/mock_exam/domain/mock_attempt.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';

class MockAttemptRepo {
  MockAttemptRepo(
    this._db, {
    LocalSyncMutationRecorder? syncRecorder,
  }) : _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db);

  final AppDatabase _db;
  final LocalSyncMutationRecorder _syncRecorder;

  Future<void> insertStart(MockAttemptStart start) {
    return _db.into(_db.mockAttempts).insert(
          MockAttemptsCompanion.insert(
            id: start.id,
            userId: start.userId,
            examId: start.examId,
            blueprintId: start.blueprintId,
            blueprintName: start.blueprintName,
            durationMinutes: start.durationMinutes,
            status: MockAttemptStatus.inProgress.value,
            strictMode: start.strictMode,
            sampledQuestionsJson: start.sampledQuestionsJson,
            startedAt: start.startedAt,
            lastFlushedAt: start.startedAt,
            updatedAt: start.startedAt,
          ),
        );
  }

  Future<MockAttempt?> findById(String attemptId) async {
    final row = await (_db.select(_db.mockAttempts)
          ..where((attempt) => attempt.id.equals(attemptId)))
        .getSingleOrNull();
    return row == null ? null : MockAttempt.fromRow(row);
  }

  Future<MockAttempt?> findInProgress(String userId) async {
    final row = await (_db.select(_db.mockAttempts)
          ..where(
            (attempt) =>
                attempt.userId.equals(userId) &
                attempt.status.equals(MockAttemptStatus.inProgress.value),
          )
          ..orderBy([
            (attempt) => OrderingTerm.desc(attempt.startedAt),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : MockAttempt.fromRow(row);
  }

  Future<void> flushProgress({
    required String attemptId,
    required int elapsedSeconds,
    required int accumulatedPausedSeconds,
    required bool pausedAtLastFlush,
    required String answersJson,
    required String flagsJson,
    required int currentIndex,
    required DateTime flushedAt,
    String? sampledQuestionsJson,
    bool updateSyncTimestamp = true,
  }) async {
    await (_db.update(_db.mockAttempts)
          ..where((attempt) => attempt.id.equals(attemptId)))
        .write(
      MockAttemptsCompanion(
        elapsedSeconds: Value(elapsedSeconds),
        accumulatedPausedSeconds: Value(accumulatedPausedSeconds),
        pausedAtLastFlush: Value(pausedAtLastFlush),
        answersJson: Value(answersJson),
        flagsJson: Value(flagsJson),
        sampledQuestionsJson: sampledQuestionsJson == null
            ? const Value.absent()
            : Value(sampledQuestionsJson),
        currentIndex: Value(currentIndex),
        lastFlushedAt: Value(flushedAt),
        updatedAt:
            updateSyncTimestamp ? Value(flushedAt) : const Value.absent(),
      ),
    );
  }

  Future<void> discard(String attemptId, DateTime discardedAt) =>
      _syncRecorder.runRecorded(
        collection: 'mock_exam_attempts',
        rowId: attemptId,
        op: SyncLocalMutationOp.upsert,
        mutate: () => (_db.update(_db.mockAttempts)
              ..where((attempt) => attempt.id.equals(attemptId)))
            .write(
          MockAttemptsCompanion(
            status: Value(MockAttemptStatus.discarded.value),
            updatedAt: Value(discardedAt),
          ),
        ),
      );

  Future<void> submit({
    required String attemptId,
    required MockAttemptStatus status,
    required MockResults results,
    required String sectionResultsJson,
    required DateTime submittedAt,
  }) {
    Future<int> mutate() => (_db.update(_db.mockAttempts)
              ..where((attempt) => attempt.id.equals(attemptId)))
            .write(
          MockAttemptsCompanion(
            status: Value(status.value),
            scoreRaw: Value(results.scoreRaw),
            scoreTotal: Value(results.scoreTotal),
            sectionResultsJson: Value(sectionResultsJson),
            totalTimeSeconds: Value(results.totalTimeSeconds),
            submittedAt: Value(submittedAt),
            updatedAt: Value(submittedAt),
          ),
        );

    if (status == MockAttemptStatus.inProgress) {
      return mutate();
    }
    return _syncRecorder.runRecorded(
      collection: 'mock_exam_attempts',
      rowId: attemptId,
      op: SyncLocalMutationOp.upsert,
      mutate: mutate,
    );
  }

  Future<MockAttempt?> lastCooldownAttempt(String userId, String examId) async {
    final row = await (_db.select(_db.mockAttempts)
          ..where(
            (attempt) =>
                attempt.userId.equals(userId) &
                attempt.examId.equals(examId) &
                attempt.status.isIn([
                  MockAttemptStatus.completed.value,
                  MockAttemptStatus.forfeited.value,
                ]),
          )
          ..orderBy([
            (attempt) => OrderingTerm.desc(attempt.submittedAt),
          ])
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : MockAttempt.fromRow(row);
  }

  /// Submitted mocks of one exam whose answers count as answers: completed
  /// (time-up is stored as completed) and forfeited. Discarded mocks are out.
  Future<List<MockAttempt>> answeredTerminalForExam(String examId) async {
    final rows = await (_db.select(_db.mockAttempts)
          ..where(
            (attempt) =>
                attempt.examId.equals(examId) &
                attempt.submittedAt.isNotNull() &
                attempt.status.isIn([
                  MockAttemptStatus.completed.value,
                  MockAttemptStatus.forfeited.value,
                ]),
          ))
        .get();
    return rows.map(MockAttempt.fromRow).toList();
  }

  Future<List<MockAttempt>> history(
    String userId, {
    int? limit = 10,
    String? examId,
  }) async {
    final rows =
        await _historyQuery(userId, limit: limit, examId: examId).get();
    return rows.map(MockAttempt.fromRow).toList(growable: false);
  }

  Stream<List<MockAttempt>> watchHistory(String userId, {int? limit = 10}) =>
      _historyQuery(userId, limit: limit).watch().map(
            (rows) => rows.map(MockAttempt.fromRow).toList(growable: false),
          );

  SimpleSelectStatement<$MockAttemptsTable, MockAttemptLocalRow> _historyQuery(
    String userId, {
    int? limit,
    String? examId,
  }) {
    final query = _db.select(_db.mockAttempts)
      ..where(
        (attempt) =>
            attempt.userId.equals(userId) &
            (examId == null
                ? const Constant(true)
                : attempt.examId.equals(examId)) &
            attempt.submittedAt.isNotNull() &
            attempt.status.isIn([
              MockAttemptStatus.completed.value,
              MockAttemptStatus.forfeited.value,
            ]),
      )
      ..orderBy([
        (attempt) => OrderingTerm.desc(attempt.submittedAt),
        (attempt) => OrderingTerm.desc(attempt.id),
      ]);
    if (limit != null) query.limit(limit);
    return query;
  }

  Future<Set<String>> recentQuestionIds(String userId, String examId) async {
    final attempts = await history(userId, examId: examId, limit: 2);
    return <String>{
      for (final attempt in attempts)
        for (final section
            in jsonDecode(attempt.sampledQuestionsJson) as List<dynamic>)
          ...((section as Map<String, dynamic>)['questionIds'] as List<dynamic>)
              .cast<String>(),
    };
  }

  /// Review changes only the reason fields and sync timestamp. The student's
  /// selections, clock, score and flags stay as submitted.
  Future<void> saveReviewReason({
    required String attemptId,
    required String questionId,
    required DateTime savedAt,
    MissReason? missReason,
    BlankReason? blankReason,
    String? reasonNote,
  }) =>
      _syncRecorder.runRecorded(
        collection: 'mock_exam_attempts',
        rowId: attemptId,
        op: SyncLocalMutationOp.upsert,
        mutate: () async {
          final attempt = await findById(attemptId);
          if (attempt == null ||
              (attempt.status != MockAttemptStatus.completed &&
                  attempt.status != MockAttemptStatus.forfeited)) {
            throw StateError('Review requires a submitted mock');
          }
          final sample =
              jsonDecode(attempt.sampledQuestionsJson) as List<dynamic>;
          if (!sample.any(
            (Object? section) => ((section!
                    as Map<String, dynamic>)['questionIds'] as List<dynamic>)
                .contains(questionId),
          )) {
            throw ArgumentError.value(
              questionId,
              'questionId',
              'Not in this mock',
            );
          }
          final raw = jsonDecode(attempt.answersJson) as Map<String, dynamic>;
          final answer = raw[questionId] as Map<String, dynamic>?;
          if ((answer == null || (answer['selectedIndex'] as int) < 0)
              ? missReason != null
              : blankReason != null) {
            throw ArgumentError('Reason does not match the answer');
          }
          raw[questionId] = {
            ...?answer,
            'selectedIndex': answer?['selectedIndex'] ?? -1,
            'atSec': answer?['atSec'] ?? 0,
            if (missReason != null) 'missReason': missReason.name,
            if (blankReason != null) 'blankReason': blankReason.name,
            if (reasonNote != null) 'reasonNote': reasonNote,
          };
          // Clearing a reason removes its old keys as well.
          final updated = raw[questionId] as Map<String, dynamic>;
          if (missReason == null) updated.remove('missReason');
          if (blankReason == null) updated.remove('blankReason');
          if (reasonNote == null) updated.remove('reasonNote');
          await (_db.update(_db.mockAttempts)
                ..where((row) => row.id.equals(attemptId)))
              .write(
            MockAttemptsCompanion(
              answersJson: Value(jsonEncode(raw)),
              updatedAt: Value(savedAt),
            ),
          );
        },
      );
}
