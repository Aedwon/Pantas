import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question_outcome.dart';
import 'package:cse_cet_reviewer/core/storage/domain/sync_state.dart';
import 'package:drift/drift.dart';

class AttemptsRepository {
  AttemptsRepository(this._db);

  final AppDatabase _db;

  Future<void> save(Attempt attempt) async {
    await _db.into(_db.attemptsLocal).insertOnConflictUpdate(
          AttemptsLocalCompanion.insert(
            id: attempt.id,
            examId: attempt.examId,
            startedAt: attempt.startedAt,
            completedAt: Value(attempt.completedAt),
            origin: Value(attempt.origin),
            itemsJson:
                jsonEncode(attempt.items.map((i) => i.toJson()).toList()),
          ),
        );
  }

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
