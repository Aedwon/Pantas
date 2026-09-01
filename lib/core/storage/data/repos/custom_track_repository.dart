import 'package:drift/drift.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/sync/custom_track/custom_track_projection.dart';
import 'package:pantas/core/sync/engine/local_sync_mutation_recorder.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';
import 'package:uuid/uuid.dart';

class _ContentDatabaseCustomTrackProjection implements CustomTrackProjection {
  _ContentDatabaseCustomTrackProjection(
    this._contentDb, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ContentDatabase _contentDb;
  final DateTime Function() _now;

  @override
  Future<void> upsert({required String examId, required String name}) {
    return _contentDb.into(_contentDb.contentExams).insertOnConflictUpdate(
          ContentExamsCompanion.insert(
            id: examId,
            code: 'custom',
            name: name,
            shortName: name,
            language: 'en',
            ordering: 9999,
            isCustom: const Value(true),
            schemaVersion: 1,
            updatedAt: _now(),
          ),
        );
  }

  @override
  Future<void> delete(String examId) {
    return (_contentDb.delete(_contentDb.contentExams)
          ..where((row) => row.id.equals(examId)))
        .go();
  }
}

/// Owns custom-track user data in AppDatabase and keeps ContentDatabase as a
/// recoverable display/content projection.
class CustomTrackRepository {
  CustomTrackRepository(
    this._db,
    this._contentDb, {
    Uuid? uuid,
    LocalSyncMutationRecorder? syncRecorder,
    CustomTrackProjection? projection,
  })  : _uuid = uuid ?? const Uuid(),
        _syncRecorder =
            syncRecorder ?? LocalSyncMutationRecorder.forDatabase(_db),
        _projection =
            projection ?? _ContentDatabaseCustomTrackProjection(_contentDb);

  static const _projectionMarkerPrefix = 'customTrackProjectionRequired:';

  final AppDatabase _db;
  final ContentDatabase _contentDb;
  final Uuid _uuid;
  final LocalSyncMutationRecorder _syncRecorder;
  final CustomTrackProjection _projection;

  Future<ExamId> create({
    required String name,
    required Set<TopicId> includedTopicIds,
  }) async {
    final examId = 'exam_custom_${_uuid.v4()}';
    final allTopics = await _contentDb.select(_contentDb.contentTopics).get();
    final excludedTopicIds = {
      for (final topic in allTopics)
        if (!includedTopicIds.contains(topic.id)) topic.id,
    };

    await _syncRecorder.runRecordedBatch(
      mutations: [
        SyncMutationTarget(
          collection: 'track_scope',
          rowId: TrackScopeDocumentId.metadata(examId),
          op: SyncLocalMutationOp.upsert,
        ),
        for (final topicId in excludedTopicIds)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.scope(examId, topicId),
            op: SyncLocalMutationOp.upsert,
          ),
      ],
      mutate: () async {
        await _db.into(_db.customTrackMetaLocal).insertOnConflictUpdate(
              CustomTrackMetaLocalCompanion.insert(
                examId: examId,
                name: name,
              ),
            );
        for (final topicId in excludedTopicIds) {
          await _db.into(_db.trackScopeLocal).insertOnConflictUpdate(
                TrackScopeLocalCompanion.insert(
                  examId: examId,
                  topicId: topicId,
                ),
              );
        }
        await _setProjectionRequired(examId, required: true);
      },
    );

    await _projectWithoutRollingBackAuthority(examId);
    return examId;
  }

  Future<void> rename({required ExamId examId, required String name}) async {
    await _syncRecorder.runRecorded(
      collection: 'track_scope',
      rowId: TrackScopeDocumentId.metadata(examId),
      op: SyncLocalMutationOp.upsert,
      mutate: () async {
        final updated = await (_db.update(_db.customTrackMetaLocal)
              ..where((row) => row.examId.equals(examId)))
            .write(CustomTrackMetaLocalCompanion(name: Value(name)));
        if (updated == 0) {
          throw StateError('Unknown custom track: $examId');
        }
        await _setProjectionRequired(examId, required: true);
      },
    );
    await _projectWithoutRollingBackAuthority(examId);
  }

  Future<void> setExcluded({
    required ExamId examId,
    required Set<TopicId> topicIds,
  }) async {
    final current = await excludedTopicIds(examId);
    final added = topicIds.difference(current);
    final removed = current.difference(topicIds);
    if (added.isEmpty && removed.isEmpty) return;
    final isCustom = await _customTrackMeta(examId) != null;

    await _syncRecorder.runRecordedBatch(
      mutations: [
        for (final topicId in added)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.scope(examId, topicId),
            op: SyncLocalMutationOp.upsert,
          ),
        for (final topicId in removed)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.scope(examId, topicId),
            op: SyncLocalMutationOp.delete,
          ),
      ],
      mutate: () async {
        for (final topicId in removed) {
          await (_db.delete(_db.trackScopeLocal)
                ..where(
                  (row) =>
                      row.examId.equals(examId) & row.topicId.equals(topicId),
                ))
              .go();
        }
        for (final topicId in added) {
          await _db.into(_db.trackScopeLocal).insertOnConflictUpdate(
                TrackScopeLocalCompanion.insert(
                  examId: examId,
                  topicId: topicId,
                ),
              );
        }
        if (isCustom) {
          await _setProjectionRequired(examId, required: true);
        }
      },
    );

    if (isCustom) {
      await _projectWithoutRollingBackAuthority(examId);
    }
  }

  Future<void> delete(ExamId examId) async {
    final meta = await _customTrackMeta(examId);
    final scope = await excludedTopicIds(examId);
    if (meta == null && scope.isEmpty) return;

    await _syncRecorder.runRecordedBatch(
      mutations: [
        if (meta != null)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.metadata(examId),
            op: SyncLocalMutationOp.delete,
          ),
        for (final topicId in scope)
          SyncMutationTarget(
            collection: 'track_scope',
            rowId: TrackScopeDocumentId.scope(examId, topicId),
            op: SyncLocalMutationOp.delete,
          ),
      ],
      mutate: () async {
        await (_db.delete(_db.trackScopeLocal)
              ..where((row) => row.examId.equals(examId)))
            .go();
        await (_db.delete(_db.customTrackMetaLocal)
              ..where((row) => row.examId.equals(examId)))
            .go();
        if (meta != null) {
          await _setProjectionRequired(examId, required: true);
        }
      },
    );

    if (meta != null) {
      await _projectWithoutRollingBackAuthority(examId);
    }
  }

  Future<Set<TopicId>> excludedTopicIds(ExamId examId) async {
    final rows = await (_db.select(_db.trackScopeLocal)
          ..where((s) => s.examId.equals(examId)))
        .get();
    return {for (final row in rows) row.topicId};
  }

  Future<bool> projectionRequired(ExamId examId) async {
    final row = await _db.customSelect(
      'select value from sync_meta where key = ?',
      variables: [Variable<String>(_projectionMarkerKey(examId))],
    ).getSingleOrNull();
    return row?.read<String>('value') == '1';
  }

  Future<bool> anyProjectionRequired() async {
    final row = await _db.customSelect(
      'select 1 as pending from sync_meta where key like ? '
      "and value = '1' limit 1",
      variables: [const Variable<String>('$_projectionMarkerPrefix%')],
    ).getSingleOrNull();
    return row != null;
  }

  Future<void> retryProjection(ExamId examId) async {
    final meta = await _customTrackMeta(examId);
    if (meta == null) {
      await _projection.delete(examId);
    } else {
      await _projection.upsert(examId: examId, name: meta.name);
    }
    await _setProjectionRequired(examId, required: false);
  }

  Future<bool> retryPendingProjections() async {
    final rows = await _db.customSelect(
      "select key from sync_meta where key like ? and value = '1' order by key",
      variables: [const Variable<String>('$_projectionMarkerPrefix%')],
    ).get();
    var settled = true;
    for (final row in rows) {
      final key = row.read<String>('key');
      final encodedId = key.substring(_projectionMarkerPrefix.length);
      try {
        final identity = TrackScopeDocumentId.parse(encodedId);
        if (identity.kind != TrackScopeDocumentKind.metadata) {
          settled = false;
          continue;
        }
        await retryProjection(identity.examId);
      } on Object {
        settled = false;
      }
    }
    return settled && !await anyProjectionRequired();
  }

  Future<CustomTrackMetaLocalRow?> _customTrackMeta(ExamId examId) {
    return (_db.select(_db.customTrackMetaLocal)
          ..where((row) => row.examId.equals(examId)))
        .getSingleOrNull();
  }

  Future<void> _projectWithoutRollingBackAuthority(ExamId examId) async {
    try {
      await retryProjection(examId);
    } on Object {
      // Authority and the retry marker were committed before projection.
    }
  }

  Future<void> _setProjectionRequired(
    ExamId examId, {
    required bool required,
  }) async {
    final key = _projectionMarkerKey(examId);
    if (!required) {
      await _db.customStatement('delete from sync_meta where key = ?', [key]);
      return;
    }
    await _db.customStatement(
      'insert into sync_meta (key,value) values (?,?) '
      'on conflict(key) do update set value=excluded.value',
      <Object?>[key, '1'],
    );
  }

  String _projectionMarkerKey(ExamId examId) =>
      '$_projectionMarkerPrefix${TrackScopeDocumentId.metadata(examId)}';
}
