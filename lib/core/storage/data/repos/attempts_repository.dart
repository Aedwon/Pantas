import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
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
      items: items,
    );
  }
}
