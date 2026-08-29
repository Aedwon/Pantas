import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';

class PushPipeline {
  PushPipeline({
    required PendingQueue queue,
    required FirestoreGateway gateway,
    required String uid,
    required bool isAnonymous,
  })  : _queue = queue,
        _gateway = gateway,
        _uid = uid,
        _isAnonymous = isAnonymous;

  static const batchLimit = 500;

  final PendingQueue _queue;
  final FirestoreGateway _gateway;
  final String _uid;
  final bool _isAnonymous;

  Future<void> flush() async {
    if (_isAnonymous) return;

    while (true) {
      final pending = await _queue.drain(limit: batchLimit);
      if (pending.isEmpty) return;

      final writes = pending.map(_writeFor).toList(growable: false);
      try {
        await _gateway.commitBatch(writes);
        await _queue.markSuccess(
          pending.map(PendingSyncIdentity.fromRow).toList(growable: false),
        );
      } on SyncGatewayException catch (error) {
        await _queue.markFailure(
          pending.map(PendingSyncIdentity.fromRow).toList(growable: false),
          error: error.code,
          attemptedAt: DateTime.now().toUtc(),
        );
        return;
      }
    }
  }

  FirestoreWrite _writeFor(PendingSyncRow row) {
    final path = 'users/$_uid/${row.tableType}/${row.rowId}';
    if (row.op == PendingSyncOp.delete.name) {
      return FirestoreWrite.delete(path: path);
    }

    return FirestoreWrite.set(
      path: path,
      data: {
        'id': row.rowId,
        'schemaVersion': 1,
      },
    );
  }
}
