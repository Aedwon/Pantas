import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

typedef SyncPayloadLoader = Future<Map<String, Object?>?> Function(
  String collection,
  String rowId,
);
typedef PushResultHandler = Future<void> Function(
  PendingSyncRow observed,
  RowCommitResult result,
);

class PushPipeline {
  PushPipeline({
    required PendingQueue queue,
    required FirestoreGateway gateway,
    required String uid,
    required String generationId,
    required String deviceId,
    required bool isAnonymous,
    required SyncPayloadLoader loadPayload,
    required PushResultHandler handleResult,
    DateTime Function()? now,
  })  : _queue = queue,
        _gateway = gateway,
        _uid = uid,
        _generationId = generationId,
        _deviceId = deviceId,
        _isAnonymous = isAnonymous,
        _loadPayload = loadPayload,
        _handleResult = handleResult,
        _now = now ?? DateTime.now;

  final PendingQueue _queue;
  final FirestoreGateway _gateway;
  final String _uid;
  final String _generationId;
  final String _deviceId;
  final bool _isAnonymous;
  final SyncPayloadLoader _loadPayload;
  final PushResultHandler _handleResult;
  final DateTime Function() _now;

  Future<void>? _activeFlush;

  Future<void> flush({int batchSize = 500}) {
    if (_isAnonymous) return Future<void>.value();
    final active = _activeFlush;
    if (active != null) return active;

    late final Future<void> current;
    current = _flushSerialized(batchSize: batchSize).whenComplete(() {
      if (identical(_activeFlush, current)) {
        _activeFlush = null;
      }
    });
    _activeFlush = current;
    return current;
  }

  Future<void> _flushSerialized({required int batchSize}) async {
    while (true) {
      final rows = await _queue.drainGeneration(
        uid: _uid,
        generationId: _generationId,
        limit: batchSize,
      );
      if (rows.isEmpty) return;

      var hadFailure = false;
      for (final row in rows) {
        final identity = PendingSyncIdentity.fromRow(row);
        try {
          final payload = row.op == PendingSyncOp.upsert.name
              ? await _loadPayload(row.tableType, row.rowId)
              : null;
          if (row.op == PendingSyncOp.upsert.name && payload == null) {
            throw StateError(
              'missing local payload for ${row.tableType}/${row.rowId}',
            );
          }

          final result = await _gateway.commitRowIfBaseMatches(
            path: _rowPath(row),
            base: _baseFor(row),
            data: <String, Object?>{
              ...?payload,
              'updatedAt': FirestoreServerTimestamp.value,
              'originDeviceId': _deviceId,
              'mutationId': row.mutationId,
              'schemaVersion': 1,
              'deleted': row.op == PendingSyncOp.delete.name,
            },
          );
          await _handleResult(row, result);
        } on SyncGatewayException catch (error) {
          hadFailure = true;
          await _queue.markFailure(
            [identity],
            error: error.code,
            attemptedAt: _now().toUtc(),
          );
        }
      }

      if (hadFailure || rows.length < batchSize) return;
    }
  }

  String _rowPath(PendingSyncRow row) =>
      'users/$_uid/sync_generations/$_generationId/'
      '${row.tableType}/${row.rowId}';

  static SyncCausalBase _baseFor(PendingSyncRow row) {
    return switch (row.baseState) {
      'knownAbsent' => const SyncCausalBase.knownAbsent(),
      'knownVersion' when row.baseUpdatedAt != null =>
        SyncCausalBase.knownVersion(row.baseUpdatedAt),
      _ => throw StateError(
          'generation-bound outbox row has invalid causal base: '
          '${row.baseState}',
        ),
    };
  }
}
