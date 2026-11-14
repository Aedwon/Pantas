import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/domain/lesson_credit.dart';
import 'package:pantas/core/storage/domain/sync_state.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';

/// What a student has read is theirs; which lessons a topic has is corpus.
/// Counting the first against the second is why this holds both databases.
class LessonProgressRepository {
  LessonProgressRepository(
    this._db,
    this._contentDb, {
    LocalSyncMutationRecorder? syncRecorder,
  }) : _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db);

  final AppDatabase _db;
  final ContentDatabase _contentDb;
  final LocalSyncMutationRecorder _syncRecorder;

  Future<void> markRead(LessonId lessonId) => _syncRecorder.runRecorded(
        collection: 'lesson_progress',
        rowId: lessonId,
        op: SyncLocalMutationOp.upsert,
        mutate: () => _db.into(_db.lessonProgressLocal).insertOnConflictUpdate(
              LessonProgressLocalCompanion(
                lessonId: Value(lessonId),
                readAt: Value(DateTime.now()),
                syncState: Value(SyncState.pending.name),
              ),
            ),
      );

  /// Resolves reads or exclusions from metadata without loading lesson bodies.
  Future<Map<String, T>> creditedValues<T extends Object>(
    Map<String, T> own,
    int Function(T, T) compare,
  ) async {
    final table = _contentDb.contentLessons;
    final rows = await (_contentDb.selectOnly(table)
          ..addColumns(
            [table.id, table.status, table.replacedBy, table.isActive],
          ))
        .get();
    final credit = resolveLessonCredit<T>(
      retiredReplacements: {
        for (final row in rows)
          if (row.read(table.status) == 'retired')
            row.read(table.id)!:
                (jsonDecode(row.read(table.replacedBy) ?? '[]') as List)
                    .cast<String>(),
      },
      own: own,
      compare: compare,
    );
    return {
      for (final row in rows)
        if (row.read(table.status) != 'retired' &&
            row.read(table.isActive)! &&
            credit.containsKey(row.read(table.id)))
          row.read(table.id)!: credit[row.read(table.id)]!,
    };
  }

  Future<Map<LessonId, DateTime>> readTimes() async => creditedValues(
        {
          for (final row in await _db.select(_db.lessonProgressLocal).get())
            row.lessonId: row.readAt,
        },
        (a, b) => a.compareTo(b),
      );

  Future<Set<LessonId>> excludedLessonIds(Set<LessonId> own) async =>
      (await creditedValues({for (final id in own) id: true}, (a, b) => 0))
          .keys
          .toSet();

  Future<bool> isRead(LessonId lessonId) async =>
      (await readTimes()).containsKey(lessonId);

  Future<Set<LessonId>> readLessonIds() async =>
      (await readTimes()).keys.toSet();

  Future<int> readCountForTopic(TopicId topicId) async {
    final read = await readLessonIds();
    final table = _contentDb.contentLessons;
    final rows = await (_contentDb.selectOnly(table)
          ..addColumns([table.id])
          ..where(table.topicId.equals(topicId)))
        .get();
    return rows.where((row) => read.contains(row.read(table.id))).length;
  }

  Future<bool> hasAnyRead() async => (await readLessonIds()).isNotEmpty;
}
