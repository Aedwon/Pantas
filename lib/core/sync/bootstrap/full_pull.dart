import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/engine/sync_collection_adapter.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/mapping/assessment_mapper.dart';
import 'package:pantas/core/sync/mapping/attempt_mapper.dart';
import 'package:pantas/core/sync/mapping/custom_blueprint_mapper.dart';
import 'package:pantas/core/sync/mapping/fsrs_card_mapper.dart';
import 'package:pantas/core/sync/mapping/lesson_bookmark_mapper.dart';
import 'package:pantas/core/sync/mapping/lesson_progress_mapper.dart';
import 'package:pantas/core/sync/mapping/mock_attempt_mapper.dart';
import 'package:pantas/core/sync/mapping/question_flag_mapper.dart';
import 'package:pantas/core/sync/mapping/review_log_mapper.dart';
import 'package:pantas/core/sync/mapping/track_scope_mapper.dart';
import 'package:pantas/core/sync/model/sync_document.dart';
import 'package:pantas/core/sync/model/sync_generation.dart';

enum FullPullOutcome {
  applied,
  appliedProjectionPending,
  staleLocalEpoch,
  retryableFailure,
  invalidSnapshot,
}

class FullPullResult {
  const FullPullResult(this.outcome);

  final FullPullOutcome outcome;
}

class FullPullBootstrap {
  FullPullBootstrap({
    required AppDatabase db,
    required FirestoreGateway gateway,
    required String uid,
    Future<void> Function(String examId)? rebuildCustomTrackProjection,
  })  : _db = db,
        _gateway = gateway,
        _uid = uid,
        _rebuildCustomTrackProjection = rebuildCustomTrackProjection;

  static const _projectionMarkerPrefix = 'customTrackProjectionRequired:';

  final AppDatabase _db;
  final FirestoreGateway _gateway;
  final String _uid;
  final Future<void> Function(String examId)? _rebuildCustomTrackProjection;

  Future<FullPullResult> run({required String generationId}) async {
    await _setMarker(generationId);
    final epoch = await _readEpoch();

    late final _DownloadedSnapshot snapshot;
    try {
      snapshot = await _downloadAndValidate(generationId);
    } on SyncGatewayException {
      return const FullPullResult(FullPullOutcome.retryableFailure);
    } on FormatException {
      return const FullPullResult(FullPullOutcome.invalidSnapshot);
    }

    final projectionExamIds = <String>{};
    try {
      await _db.transaction(() async {
        if (await _readEpoch() != epoch) {
          throw const _StaleLocalEpoch();
        }

        final oldCustomTracks =
            await _db.select(_db.customTrackMetaLocal).get();
        projectionExamIds
          ..addAll(oldCustomTracks.map((row) => row.examId))
          ..addAll(snapshot.customTrackExamIds);

        await _replaceSyncOwnedState(snapshot);
        for (final examId in projectionExamIds) {
          await _setProjectionRequired(examId, required: true);
        }
        await _db.into(_db.syncMeta).insertOnConflictUpdate(
              SyncMetaCompanion.insert(
                key: 'currentLocalGenerationId',
                value: generationId,
              ),
            );
        await (_db.delete(_db.syncMeta)
              ..where((row) => row.key.equals('pending_full_pull')))
            .go();
      });
    } on _StaleLocalEpoch {
      return const FullPullResult(FullPullOutcome.staleLocalEpoch);
    } on FormatException {
      return const FullPullResult(FullPullOutcome.invalidSnapshot);
    }

    if (projectionExamIds.isEmpty) {
      return const FullPullResult(FullPullOutcome.applied);
    }
    if (_rebuildCustomTrackProjection == null) {
      return const FullPullResult(FullPullOutcome.appliedProjectionPending);
    }

    var projectionPending = false;
    for (final examId in projectionExamIds) {
      try {
        await _rebuildCustomTrackProjection(examId);
        await _setProjectionRequired(examId, required: false);
      } on Object {
        projectionPending = true;
      }
    }
    return FullPullResult(
      projectionPending
          ? FullPullOutcome.appliedProjectionPending
          : FullPullOutcome.applied,
    );
  }

  Future<_DownloadedSnapshot> _downloadAndValidate(String generationId) async {
    final root = await _gateway.readDocument(
      'users/$_uid/sync_generations/$generationId',
    );
    if (root == null) {
      throw const FormatException('active Sync generation missing');
    }
    final generation = SyncGeneration.fromMap(
      id: generationId,
      data: root.data,
    );
    if (generation.status != SyncGenerationStatus.active) {
      throw const FormatException('Keep Account requires active generation');
    }

    final preferences = <String, String>{};
    for (final entry in generation.preferences.entries) {
      final value = entry.value;
      if (value is! String) {
        throw const FormatException('Sync preference value must be a string');
      }
      preferences[entry.key] = value;
    }

    final documents = <String, List<SyncDocument>>{};
    final customTrackExamIds = <String>{};
    for (final entry in activeSyncCollections) {
      final rows = await _gateway.readCollection(
        'users/$_uid/sync_generations/$generationId/${entry.firestorePath}',
      );
      for (final row in rows) {
        _validateDocument(entry.tableType, row);
        if (entry.tableType == 'track_scope') {
          customTrackExamIds.add(TrackScopeDocumentId.parse(row.id).examId);
        }
      }
      documents[entry.tableType] = rows;
    }

    return _DownloadedSnapshot(
      preferences: preferences,
      documents: documents,
      customTrackExamIds: customTrackExamIds,
    );
  }

  void _validateDocument(String collection, SyncDocument document) {
    final updatedAt = document.updatedAt;
    if (updatedAt == null) {
      throw const FormatException('Sync snapshot row missing updatedAt');
    }
    if (document.deleted) {
      if (collection == 'track_scope') {
        TrackScopeDocumentId.parse(document.id);
      }
      return;
    }

    final payload = document.data;
    switch (collection) {
      case 'quiz_attempts':
        const mapper = AttemptMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(document.id, mapper.documentId(row));
      case 'assessments':
        const mapper = AssessmentMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(document.id, mapper.documentId(row));
      case 'fsrs_cards':
        const mapper = FsrsCardMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(document.id, mapper.documentId(row));
      case 'lesson_progress':
        const mapper = LessonProgressMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(document.id, mapper.documentId(row));
      case 'lesson_bookmarks':
        const mapper = LessonBookmarkMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(document.id, mapper.documentId(row));
      case 'question_flags':
        const mapper = QuestionFlagMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(document.id, mapper.documentId(row));
      case 'mock_exam_attempts':
        const mapper = MockAttemptMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(document.id, mapper.documentId(row));
        if (!const {'completed', 'discarded', 'forfeited'}
            .contains(row.status)) {
          throw const FormatException(
            'in-progress mock attempts cannot appear in cloud snapshot',
          );
        }
      case 'review_logs':
        const mapper = ReviewLogMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(document.id, mapper.documentId(row));
      case 'track_scope':
        const TrackScopeMapper().fromFirestore(document.id, payload);
      case 'custom_blueprints':
        const mapper = CustomBlueprintMapper();
        final row = mapper.fromFirestore(payload);
        _requireIdentity(document.id, mapper.documentId(row));
      default:
        throw UnsupportedError('No active Sync collection for $collection');
    }
  }

  Future<void> _replaceSyncOwnedState(_DownloadedSnapshot snapshot) async {
    await _db.delete(_db.attemptsLocal).go();
    await _db.delete(_db.assessmentResultsLocal).go();
    await _db.delete(_db.reviewStateLocal).go();
    await _db.delete(_db.lessonProgressLocal).go();
    await _db.delete(_db.lessonBookmarksLocal).go();
    await _db.delete(_db.questionFlagsLocal).go();
    await (_db.delete(_db.mockAttempts)
          ..where(
            (row) => row.status.isIn(
              const ['completed', 'discarded', 'forfeited'],
            ),
          ))
        .go();
    await _db.delete(_db.reviewLogs).go();
    await _db.delete(_db.customTrackMetaLocal).go();
    await _db.delete(_db.trackScopeLocal).go();
    await _db.delete(_db.customBlueprintsLocal).go();
    await _db.delete(_db.accountPrefs).go();
    await _db.delete(_db.pendingSync).go();
    await _db.delete(_db.syncRowMeta).go();
    await _db.customStatement('delete from sync_local_mutations');

    for (final entry in snapshot.preferences.entries) {
      await _db.into(_db.accountPrefs).insertOnConflictUpdate(
            AccountPrefsCompanion.insert(key: entry.key, value: entry.value),
          );
    }

    for (final entry in activeSyncCollections) {
      final adapter = SyncCollectionAdapter(entry.tableType);
      for (final document
          in snapshot.documents[entry.tableType] ?? const <SyncDocument>[]) {
        await adapter.applyRemote(
          db: _db,
          rowId: document.id,
          payload: document.deleted ? null : document.data,
          deleted: document.deleted,
          updatedAt: document.updatedAt!,
          originDeviceId: document.originDeviceId,
        );
      }
    }
  }

  Future<int> _readEpoch() async {
    final row = await _db
        .customSelect(
          "select value from sync_meta where key = 'localMutationEpoch'",
        )
        .getSingleOrNull();
    if (row == null) return 0;
    final value = int.tryParse(row.read<String>('value'));
    if (value == null || value < 0) {
      throw StateError('Invalid localMutationEpoch');
    }
    return value;
  }

  Future<void> _setMarker(String generationId) {
    return _db.into(_db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(
            key: 'pending_full_pull',
            value: generationId,
          ),
        );
  }

  Future<void> _setProjectionRequired(
    String examId, {
    required bool required,
  }) async {
    final key =
        '$_projectionMarkerPrefix${TrackScopeDocumentId.metadata(examId)}';
    if (!required) {
      await _db.customStatement(
        'delete from sync_meta where key = ?',
        [key],
      );
      return;
    }
    await _db.customStatement(
      'insert into sync_meta (key,value) values (?,?) '
      'on conflict(key) do update set value=excluded.value',
      [key, '1'],
    );
  }

  void _requireIdentity(String expected, String actual) {
    if (expected != actual) {
      throw FormatException(
        'Sync document identity mismatch: expected $expected, got $actual',
      );
    }
  }
}

class _DownloadedSnapshot {
  const _DownloadedSnapshot({
    required this.preferences,
    required this.documents,
    required this.customTrackExamIds,
  });

  final Map<String, String> preferences;
  final Map<String, List<SyncDocument>> documents;
  final Set<String> customTrackExamIds;
}

class _StaleLocalEpoch implements Exception {
  const _StaleLocalEpoch();
}
