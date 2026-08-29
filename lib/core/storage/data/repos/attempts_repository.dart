import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/question_outcome.dart';
import 'package:pantas/core/storage/domain/sync_state.dart';

class AttemptsRepository {
  AttemptsRepository(
    this._db, {
    LocalSyncMutationRecorder? syncRecorder,
  }) : _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db);

  final AppDatabase _db;
  final LocalSyncMutationRecorder _syncRecorder;

  Future<void> save(Attempt attempt) => _syncRecorder.runRecorded(
        collection: 'quiz_attempts',
        rowId: attempt.id,
        op: SyncLocalMutationOp.upsert,
        mutate: () => _db.into(_db.attemptsLocal).insertOnConflictUpdate(
              AttemptsLocalCompanion.insert(
                id: attempt.id,
                examId: attempt.examId,
                startedAt: attempt.startedAt,
                completedAt: Value(attempt.completedAt),
                origin: Value(attempt.origin),
                itemsJson: jsonEncode(
                  attempt.items.map((i) => i.toJson()).toList(),
                ),
              ),
            ),
      );

  Future<Attempt?> byId(AttemptId id) async {
    final row = await (_db.select(_db.attemptsLocal)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _hydrate(row);
  }

  Future<List<Attempt>> pendingSyncs() async {
    final rows = await (_db.select(_db.attemptsLocal)
          ..where((t) => t.syncState.equals(SyncState.pending.name)))
        .get();
    return rows.map(_hydrate).toList();
  }

  Future<void> markSynced(AttemptId id) async {
    await (_db.update(_db.attemptsLocal)..where((t) => t.id.equals(id))).write(
      AttemptsLocalCompanion(syncState: Value(SyncState.synced.name)),
    );
  }

  Future<void> markFailed(AttemptId id, String error) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.attemptsLocal)
            ..where((t) => t.id.equals(id)))
          .getSingle();
      await (_db.update(_db.attemptsLocal)..where((t) => t.id.equals(id)))
          .write(
        AttemptsLocalCompanion(
          syncState: const Value('failed'),
          syncAttempts: Value(row.syncAttempts + 1),
          lastSyncError: Value(error),
        ),
      );
    });
  }

  Future<int> countForExam(ExamId examId) async {
    final rows = await (_db.select(_db.attemptsLocal)
          ..where((t) => t.examId.equals(examId)))
        .get();
    return rows.length;
  }

  Future<List<QuestionId>> recentIncorrects({
    required ExamId examId,
    required DateTime now,
    required Duration window,
    int limit = 50,
  }) async {
    final cutoff = now.subtract(window);
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isBiggerOrEqualValue(cutoff),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();
    final questionIds = <QuestionId>[];
    final seen = <QuestionId>{};
    for (final row in rows) {
      final attempt = _hydrate(row);
      for (final item in attempt.items) {
        if (item.isCorrect || !seen.add(item.questionId)) continue;
        questionIds.add(item.questionId);
        if (questionIds.length >= limit) return questionIds;
      }
    }
    return questionIds;
  }

  /// How each question has gone inside [window]. The weakness reading groups
  /// these by topic; see `CountTodayBacklog`.
  Future<Map<QuestionId, QuestionOutcome>> questionOutcomes({
    required ExamId examId,
    required DateTime now,
    Duration window = const Duration(days: 30),
  }) async {
    final cutoff = now.subtract(window);
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isBiggerOrEqualValue(cutoff),
          ))
        .get();

    final attempts = <QuestionId, int>{};
    final corrects = <QuestionId, int>{};
    for (final row in rows) {
      for (final item in _hydrate(row).items) {
        attempts[item.questionId] = (attempts[item.questionId] ?? 0) + 1;
        if (item.isCorrect) {
          corrects[item.questionId] = (corrects[item.questionId] ?? 0) + 1;
        }
      }
    }

    return {
      for (final entry in attempts.entries)
        entry.key: QuestionOutcome(
          attempts: entry.value,
          correct: corrects[entry.key] ?? 0,
        ),
    };
  }

  /// Questions answered on one local day, and how many were right. Both are
  /// counted, never estimated: the session panel prints them as figures.
  Future<DayTally> tallyForDay({
    required ExamId examId,
    required DateTime day,
  }) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isBiggerOrEqualValue(start) &
                t.startedAt.isSmallerThanValue(end),
          ))
        .get();

    var answered = 0;
    var correct = 0;
    for (final row in rows) {
      for (final item in _hydrate(row).items) {
        answered++;
        if (item.isCorrect) correct++;
      }
    }
    return DayTally(answered: answered, correct: correct);
  }

  /// The student's own average time on one question, in milliseconds, or null
  /// until there is enough history to average honestly.
  ///
  /// The practice picker converts a requested number of minutes into a number
  /// of questions with this. Below [minimumSessions] it returns null and the
  /// picker withholds its minutes unit rather than converting through a figure
  /// the app made up.
  ///
  /// `PerQuestionSpeedSignal` computes the same average and gates on the same
  /// seven, but it lives in `features/metrics` and reading it from the quiz
  /// feature would cross a layer boundary.
  Future<int?> averageResponseMs({
    required ExamId examId,
    int minimumSessions = 7,
  }) async {
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) => t.examId.equals(examId) & t.completedAt.isNotNull(),
          ))
        .get();
    if (rows.length < minimumSessions) return null;

    var total = 0;
    var count = 0;
    for (final row in rows) {
      for (final item in _hydrate(row).items) {
        total += item.responseMs;
        count++;
      }
    }
    if (count == 0) return null;
    return (total / count).round();
  }

  /// Every question answered since [since], for any reason.
  ///
  /// The picker excludes these so a repeated drill does not return the same
  /// ten in the same order. Spec 4 section 4.3 asked for this and it was never
  /// built.
  Future<Set<QuestionId>> questionIdsAnsweredSince({
    required ExamId examId,
    required DateTime since,
  }) async {
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isBiggerOrEqualValue(since),
          ))
        .get();
    return {
      for (final row in rows)
        for (final item in _hydrate(row).items) item.questionId,
    };
  }

  /// Average time on a question, per topic, inside [window].
  ///
  /// The caller supplies [topicOf] because `attempts_local` stores question
  /// ids and nothing else, and this layer must not reach into content to
  /// resolve them.
  Future<Map<TopicId, int>> averageResponseMsByTopic({
    required ExamId examId,
    required Map<QuestionId, TopicId> topicOf,
    required DateTime now,
    Duration window = const Duration(days: 30),
  }) async {
    final cutoff = now.subtract(window);
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isBiggerOrEqualValue(cutoff),
          ))
        .get();

    final totals = <TopicId, int>{};
    final counts = <TopicId, int>{};
    for (final row in rows) {
      for (final item in _hydrate(row).items) {
        final topicId = topicOf[item.questionId];
        if (topicId == null) continue;
        totals[topicId] = (totals[topicId] ?? 0) + item.responseMs;
        counts[topicId] = (counts[topicId] ?? 0) + 1;
      }
    }
    return {
      for (final entry in totals.entries)
        entry.key: (entry.value / counts[entry.key]!).round(),
    };
  }

  /// When this question was last answered correctly before [before], or null.
  ///
  /// [before] excludes the session that is being debriefed, so its own answer
  /// cannot be mistaken for history.
  Future<DateTime?> lastCorrectAt({
    required ExamId examId,
    required QuestionId questionId,
    required DateTime before,
  }) async {
    final rows = await (_db.select(_db.attemptsLocal)
          ..where(
            (t) =>
                t.examId.equals(examId) &
                t.startedAt.isSmallerThanValue(before),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();

    for (final row in rows) {
      final attempt = _hydrate(row);
      for (final item in attempt.items) {
        if (item.questionId == questionId && item.isCorrect) {
          return attempt.startedAt;
        }
      }
    }
    return null;
  }

  /// Records what the student said went wrong, from the debrief.
  ///
  /// Rewrites the whole items blob because they are stored as JSON on the
  /// attempt row. One tag a tap is not a hot path.
  Future<void> tagItem({
    required AttemptId attemptId,
    required QuestionId questionId,
    required MistakeTag? tag,
  }) async {
    final attempt = await byId(attemptId);
    if (attempt == null) return;
    await save(
      attempt.copyWith(
        items: [
          for (final item in attempt.items)
            item.questionId == questionId
                ? item.copyWith(mistakeTag: tag)
                : item,
        ],
      ),
    );
  }

  Future<AttemptLocalRow> rawRowById(AttemptId id) =>
      (_db.select(_db.attemptsLocal)..where((t) => t.id.equals(id)))
          .getSingle();

  Attempt _hydrate(AttemptLocalRow r) {
    final items = (jsonDecode(r.itemsJson) as List)
        .cast<Map<String, dynamic>>()
        .map(AttemptItem.fromJson)
        .toList();
    return Attempt(
      id: r.id,
      examId: r.examId,
      startedAt: r.startedAt,
      completedAt: r.completedAt,
      origin: r.origin,
      items: items,
    );
  }
}
