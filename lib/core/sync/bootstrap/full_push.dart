import 'package:drift/drift.dart' show Variable;
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/generation_repository.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/firestore/functions_gateway.dart';
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
import 'package:uuid/uuid.dart';

enum FullPushOutcome {
  activated,
  staleLocalEpoch,
  retryableFailure,
  generationConflict,
}

class FullPushResult {
  const FullPushResult({
    required this.outcome,
    required this.generationId,
    this.activeGenerationId,
  });

  final FullPushOutcome outcome;
  final String generationId;
  final String? activeGenerationId;
}

class FullPushBootstrap {
  FullPushBootstrap({
    required AppDatabase db,
    required FirestoreGateway gateway,
    required SyncFunctionsGateway functionsGateway,
    required String uid,
    required String deviceId,
    String Function()? generationIdFactory,
    String Function(String collection, String rowId)? mutationIdFactory,
    DateTime Function()? now,
  })  : _db = db,
        _gateway = gateway,
        _generationRepository = GenerationRepository(
          gateway: gateway,
          functionsGateway: functionsGateway,
          uid: uid,
        ),
        _uid = uid,
        _deviceId = deviceId,
        _generationIdFactory = generationIdFactory ?? _defaultGenerationId,
        _mutationIdFactory = mutationIdFactory ?? _defaultMutationId,
        _now = now ?? DateTime.now;

  final AppDatabase _db;
  final FirestoreGateway _gateway;
  final GenerationRepository _generationRepository;
  final String _uid;
  final String _deviceId;
  final String Function() _generationIdFactory;
  final String Function(String collection, String rowId) _mutationIdFactory;
  final DateTime Function() _now;

  Future<FullPushResult> run({
    required String? expectedActiveGenerationId,
  }) async {
    final generationId = _generationIdFactory();
    await _setMarker(generationId);
    final epoch = await _readEpoch();
    final journal = await _captureJournal(epoch);

    try {
      final preferences = {
        for (final row in await _db.select(_db.accountPrefs).get())
          row.key: row.value,
      };
      await _generationRepository.stageGeneration(
        generationId: generationId,
        deviceId: _deviceId,
        preferences: preferences,
      );

      final writes = await _buildWrites(generationId);
      for (var start = 0; start < writes.length; start += 500) {
        final end = (start + 500).clamp(0, writes.length);
        await _gateway.commitBatch(writes.sublist(start, end));
      }

      if (await _readEpoch() != epoch) {
        return FullPushResult(
          outcome: FullPushOutcome.staleLocalEpoch,
          generationId: generationId,
        );
      }

      try {
        await _generationRepository.activateGeneration(
          generationId: generationId,
          expectedActiveGenerationId: expectedActiveGenerationId,
        );
      } on SyncGatewayException catch (error) {
        if (error.code == 'generation-conflict') {
          final active = error.details?['activeGenerationId'];
          return FullPushResult(
            outcome: FullPushOutcome.generationConflict,
            generationId: generationId,
            activeGenerationId: active is String ? active : null,
          );
        }
        return FullPushResult(
          outcome: FullPushOutcome.retryableFailure,
          generationId: generationId,
        );
      }

      if (await _readEpoch() != epoch) {
        return FullPushResult(
          outcome: FullPushOutcome.staleLocalEpoch,
          generationId: generationId,
        );
      }

      final acknowledged = await _acknowledgeIfCurrent(
        generationId: generationId,
        epoch: epoch,
        journal: journal,
      );
      return FullPushResult(
        outcome: acknowledged
            ? FullPushOutcome.activated
            : FullPushOutcome.staleLocalEpoch,
        generationId: generationId,
      );
    } on SyncGatewayException {
      return FullPushResult(
        outcome: FullPushOutcome.retryableFailure,
        generationId: generationId,
      );
    }
  }

  Future<List<FirestoreWrite>> _buildWrites(String generationId) async {
    final stamp = _now().toUtc();
    final writes = <FirestoreWrite>[];

    const attempts = AttemptMapper();
    for (final row in await _db.select(_db.attemptsLocal).get()) {
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: attempts.name,
          rowId: attempts.documentId(row),
          payload: attempts.toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    const assessments = AssessmentMapper();
    for (final row in await _db.select(_db.assessmentResultsLocal).get()) {
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: assessments.name,
          rowId: assessments.documentId(row),
          payload: assessments.toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    const fsrs = FsrsCardMapper();
    for (final row in await _db.select(_db.reviewStateLocal).get()) {
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: fsrs.name,
          rowId: fsrs.documentId(row),
          payload: fsrs.toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    const lessons = LessonProgressMapper();
    for (final row in await _db.select(_db.lessonProgressLocal).get()) {
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: lessons.name,
          rowId: lessons.documentId(row),
          payload: lessons.toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    const bookmarks = LessonBookmarkMapper();
    for (final row in await _db.select(_db.lessonBookmarksLocal).get()) {
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: bookmarks.name,
          rowId: bookmarks.documentId(row),
          payload: bookmarks.toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    const flags = QuestionFlagMapper();
    for (final row in await _db.select(_db.questionFlagsLocal).get()) {
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: flags.name,
          rowId: flags.documentId(row),
          payload: flags.toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    const mocks = MockAttemptMapper();
    final mockRows = await (_db.select(_db.mockAttempts)
          ..where(
            (row) => row.status.isIn(
              const ['completed', 'discarded', 'forfeited'],
            ),
          ))
        .get();
    for (final row in mockRows) {
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: mocks.name,
          rowId: mocks.documentId(row),
          payload: mocks.toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    const reviews = ReviewLogMapper();
    for (final row in await _db.select(_db.reviewLogs).get()) {
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: reviews.name,
          rowId: reviews.documentId(row),
          payload: reviews.toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    const trackScope = TrackScopeMapper();
    for (final row in await _db.select(_db.customTrackMetaLocal).get()) {
      final rowId = trackScope.metadataDocumentId(row);
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: trackScope.name,
          rowId: rowId,
          payload: trackScope.metadataToFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }
    for (final row in await _db.select(_db.trackScopeLocal).get()) {
      final rowId = trackScope.scopeDocumentId(row);
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: trackScope.name,
          rowId: rowId,
          payload: trackScope.scopeToFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    const blueprints = CustomBlueprintMapper();
    for (final row in await _db.select(_db.customBlueprintsLocal).get()) {
      writes.add(
        _liveWrite(
          generationId: generationId,
          collection: blueprints.name,
          rowId: blueprints.documentId(row),
          payload: blueprints.toFirestore(
            row,
            updatedAt: stamp,
            originDeviceId: _deviceId,
          ),
        ),
      );
    }

    return writes;
  }

  FirestoreWrite _liveWrite({
    required String generationId,
    required String collection,
    required String rowId,
    required Map<String, Object?> payload,
  }) {
    return FirestoreWrite.set(
      path: 'users/$_uid/sync_generations/$generationId/$collection/$rowId',
      merge: false,
      data: {
        ...payload,
        'updatedAt': FirestoreServerTimestamp.value,
        'originDeviceId': _deviceId,
        'mutationId': _mutationIdFactory(collection, rowId),
        'schemaVersion': 1,
        'deleted': false,
      },
    );
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

  Future<List<_JournalSnapshot>> _captureJournal(int epoch) async {
    final rows = await _db.customSelect(
      'select collection,row_id,revision,mutation_epoch '
      'from sync_local_mutations where mutation_epoch <= ?',
      variables: [Variable<int>(epoch)],
    ).get();
    return [
      for (final row in rows)
        _JournalSnapshot(
          collection: row.read<String>('collection'),
          rowId: row.read<String>('row_id'),
          revision: row.read<int>('revision'),
          mutationEpoch: row.read<int>('mutation_epoch'),
        ),
    ];
  }

  Future<bool> _acknowledgeIfCurrent({
    required String generationId,
    required int epoch,
    required List<_JournalSnapshot> journal,
  }) async {
    var current = true;
    await _db.transaction(() async {
      if (await _readEpoch() != epoch) {
        current = false;
        return;
      }
      for (final row in journal) {
        await _db.customStatement(
          'delete from sync_local_mutations '
          'where collection = ? and row_id = ? '
          'and revision = ? and mutation_epoch = ?',
          [row.collection, row.rowId, row.revision, row.mutationEpoch],
        );
      }
      await _db.delete(_db.pendingSync).go();
      await _db.delete(_db.syncRowMeta).go();
      await _db.into(_db.syncMeta).insertOnConflictUpdate(
            SyncMetaCompanion.insert(
              key: 'currentLocalGenerationId',
              value: generationId,
            ),
          );
      await (_db.delete(_db.syncMeta)
            ..where((row) => row.key.equals('pending_full_push')))
          .go();
    });
    return current;
  }

  Future<void> _setMarker(String generationId) {
    return _db.into(_db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(
            key: 'pending_full_push',
            value: generationId,
          ),
        );
  }

  static String _defaultGenerationId() => 'gen_${const Uuid().v4()}';

  static String _defaultMutationId(
    String collection,
    String rowId,
  ) =>
      const Uuid().v4();
}

class _JournalSnapshot {
  const _JournalSnapshot({
    required this.collection,
    required this.rowId,
    required this.revision,
    required this.mutationEpoch,
  });

  final String collection;
  final String rowId;
  final int revision;
  final int mutationEpoch;
}
