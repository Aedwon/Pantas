import 'package:drift/drift.dart' show Variable;
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/engine/sync_row_meta_repository.dart';
import 'package:pantas/core/sync/model/sync_causal_base.dart';
import 'package:pantas/core/sync/model/sync_document.dart';

enum PullApplyResult { applied, echoAdvanced, ignored, quarantined }

class PullPipeline {
  PullPipeline({
    required AppDatabase db,
    required PendingQueue queue,
    required String uid,
    required String generationId,
    required String deviceId,
  })  : _db = db,
        _queue = queue,
        _uid = uid,
        _generationId = generationId,
        _deviceId = deviceId,
        _rowMeta = SyncRowMetaRepository(db);

  final AppDatabase _db;
  final PendingQueue _queue;
  final String _uid;
  final String _generationId;
  final String _deviceId;
  final SyncRowMetaRepository _rowMeta;

  Future<PullApplyResult> applyDocument({
    required String generationId,
    required String collection,
    required SyncDocument document,
  }) async {
    if (generationId != _generationId) {
      return PullApplyResult.quarantined;
    }

    final entry = _activeEntry(collection);
    final updatedAt = document.updatedAt;
    if (updatedAt == null) {
      throw const FormatException(
        'accepted Sync document requires authoritative updatedAt',
      );
    }

    final accepted = await _rowMeta.readAcceptedBase(
      collection: collection,
      rowId: document.id,
    );
    final pending = await _queue.findGenerationBound(
      uid: _uid,
      generationId: _generationId,
      tableType: collection,
      rowId: document.id,
    );

    final ownDocument = document.originDeviceId == _deviceId;
    if (ownDocument &&
        pending != null &&
        document.mutationId == pending.mutationId) {
      await entry.adapter.applyRemote(
        db: _db,
        rowId: document.id,
        payload: document.deleted ? null : document.data,
        deleted: document.deleted,
        updatedAt: updatedAt,
        originDeviceId: document.originDeviceId,
      );
      await _queue.markSuccess([PendingSyncIdentity.fromRow(pending)]);
      return PullApplyResult.applied;
    }

    if (ownDocument &&
        pending != null &&
        document.mutationId != null &&
        _isNewerThanAccepted(updatedAt, accepted) &&
        _pendingMatchesBase(pending, accepted)) {
      await _rowMeta.acceptKnownVersion(
        collection: collection,
        rowId: document.id,
        updatedAt: updatedAt,
        originDeviceId: document.originDeviceId,
      );
      final advanced = await _queue.advanceCurrentBaseIfMatches(
        uid: _uid,
        generationId: _generationId,
        tableType: collection,
        rowId: document.id,
        expectedBaseState: pending.baseState,
        expectedBaseUpdatedAt: pending.baseUpdatedAt,
        acceptedUpdatedAt: updatedAt,
      );
      if (advanced) {
        return PullApplyResult.echoAdvanced;
      }
    }

    if (!_isNewerThanAccepted(updatedAt, accepted)) {
      return PullApplyResult.ignored;
    }

    if (pending != null) {
      final incomingBase = SyncCausalBase.knownVersion(updatedAt);
      if (_pendingMatchesBase(pending, incomingBase)) {
        await _rowMeta.acceptKnownVersion(
          collection: collection,
          rowId: document.id,
          updatedAt: updatedAt,
          originDeviceId: document.originDeviceId,
        );
        return PullApplyResult.ignored;
      }

      if (_pendingMatchesBase(pending, accepted)) {
        await _queue.discardCurrentLineage(
          observed: PendingSyncIdentity.fromRow(pending),
          uid: _uid,
          generationId: _generationId,
          tableType: collection,
          rowId: document.id,
          expectedBaseState: pending.baseState,
          expectedBaseUpdatedAt: pending.baseUpdatedAt,
        );
      } else {
        await _rowMeta.acceptKnownVersion(
          collection: collection,
          rowId: document.id,
          updatedAt: updatedAt,
          originDeviceId: document.originDeviceId,
        );
        return PullApplyResult.ignored;
      }
    }

    await entry.adapter.applyRemote(
      db: _db,
      rowId: document.id,
      payload: document.deleted ? null : document.data,
      deleted: document.deleted,
      updatedAt: updatedAt,
      originDeviceId: document.originDeviceId,
    );
    return PullApplyResult.applied;
  }

  Future<void> applyCompleteSnapshot({
    required String generationId,
    required String collection,
    required List<SyncDocument> documents,
  }) async {
    if (generationId != _generationId) return;
    final entry = _activeEntry(collection);
    final presentIds = <String>{};

    for (final document in documents) {
      presentIds.add(document.id);
      await applyDocument(
        generationId: generationId,
        collection: collection,
        document: document,
      );
    }

    final knownRows = await _db.customSelect(
      'select row_id from sync_row_meta where collection = ?',
      variables: [Variable<String>(collection)],
    ).get();
    for (final row in knownRows) {
      final rowId = row.read<String>('row_id');
      if (presentIds.contains(rowId)) continue;

      final pending = await _queue.findGenerationBound(
        uid: _uid,
        generationId: _generationId,
        tableType: collection,
        rowId: rowId,
      );
      if (pending != null &&
          pending.op == PendingSyncOp.upsert.name &&
          pending.baseState == SyncCausalBaseState.knownAbsent.storageValue) {
        continue;
      }

      await entry.adapter.applyKnownAbsent(db: _db, rowId: rowId);
    }
  }

  Future<void> handlePushResult(
    PendingSyncRow observed,
    RowCommitResult result,
  ) async {
    if (observed.uid != _uid || observed.generationId != _generationId) return;
    final entry = _activeEntry(observed.tableType);
    final identity = PendingSyncIdentity.fromRow(observed);
    final observedBase = _baseFromPending(observed);

    switch (result) {
      case RowCommitted(:final authoritative):
        final updatedAt = authoritative.updatedAt;
        if (updatedAt == null) {
          throw const FormatException(
            'committed Sync document requires authoritative updatedAt',
          );
        }
        final current = await _queue.findGenerationBound(
          uid: _uid,
          generationId: _generationId,
          tableType: observed.tableType,
          rowId: observed.rowId,
        );

        if (current != null && !_sameIdentity(current, identity)) {
          await _rowMeta.acceptKnownVersion(
            collection: observed.tableType,
            rowId: observed.rowId,
            updatedAt: updatedAt,
            originDeviceId: authoritative.originDeviceId,
          );
          if (current.id == observed.id &&
              current.revision > observed.revision &&
              _pendingMatchesBase(current, observedBase)) {
            await _queue.advanceNewerRevisionBase(
              observed: identity,
              uid: _uid,
              generationId: _generationId,
              tableType: observed.tableType,
              rowId: observed.rowId,
              expectedBaseState: observed.baseState,
              expectedBaseUpdatedAt: observed.baseUpdatedAt,
              acceptedUpdatedAt: updatedAt,
            );
          }
          return;
        }

        await entry.adapter.applyRemote(
          db: _db,
          rowId: observed.rowId,
          payload: authoritative.deleted ? null : authoritative.data,
          deleted: authoritative.deleted,
          updatedAt: updatedAt,
          originDeviceId: authoritative.originDeviceId,
        );
        if (current != null) {
          await _queue.markSuccess([identity]);
        }

      case RowStale(:final current):
        final currentPending = await _queue.findGenerationBound(
          uid: _uid,
          generationId: _generationId,
          tableType: observed.tableType,
          rowId: observed.rowId,
        );
        final authoritativeBase = current == null
            ? const SyncCausalBase.knownAbsent()
            : SyncCausalBase.knownVersion(_requireUpdatedAt(current));

        if (currentPending != null &&
            _pendingMatchesBase(currentPending, authoritativeBase)) {
          await _acceptOnly(
            collection: observed.tableType,
            rowId: observed.rowId,
            document: current,
          );
          return;
        }

        if (currentPending != null &&
            _pendingMatchesBase(currentPending, observedBase)) {
          await _queue.discardCurrentLineage(
            observed: identity,
            uid: _uid,
            generationId: _generationId,
            tableType: observed.tableType,
            rowId: observed.rowId,
            expectedBaseState: observed.baseState,
            expectedBaseUpdatedAt: observed.baseUpdatedAt,
          );
        }

        final afterDiscard = await _queue.findGenerationBound(
          uid: _uid,
          generationId: _generationId,
          tableType: observed.tableType,
          rowId: observed.rowId,
        );
        if (afterDiscard != null) {
          await _acceptOnly(
            collection: observed.tableType,
            rowId: observed.rowId,
            document: current,
          );
          return;
        }

        if (current == null) {
          await entry.adapter.applyKnownAbsent(
            db: _db,
            rowId: observed.rowId,
          );
        } else {
          final updatedAt = _requireUpdatedAt(current);
          await entry.adapter.applyRemote(
            db: _db,
            rowId: observed.rowId,
            payload: current.deleted ? null : current.data,
            deleted: current.deleted,
            updatedAt: updatedAt,
            originDeviceId: current.originDeviceId,
          );
        }
    }
  }

  Future<void> _acceptOnly({
    required String collection,
    required String rowId,
    required SyncDocument? document,
  }) {
    if (document == null) {
      return _rowMeta.acceptKnownAbsent(
        collection: collection,
        rowId: rowId,
      );
    }
    return _rowMeta.acceptKnownVersion(
      collection: collection,
      rowId: rowId,
      updatedAt: _requireUpdatedAt(document),
      originDeviceId: document.originDeviceId,
    );
  }

  SyncCollectionEntry _activeEntry(String collection) {
    for (final entry in activeSyncCollections) {
      if (entry.tableType == collection) return entry;
    }
    throw UnsupportedError('No active Sync collection for $collection');
  }

  static DateTime _requireUpdatedAt(SyncDocument document) {
    final value = document.updatedAt;
    if (value == null) {
      throw const FormatException(
        'accepted Sync document requires authoritative updatedAt',
      );
    }
    return value;
  }

  static bool _isNewerThanAccepted(
    DateTime incoming,
    SyncCausalBase? accepted,
  ) {
    if (accepted == null || accepted.state == SyncCausalBaseState.knownAbsent) {
      return true;
    }
    if (accepted.state != SyncCausalBaseState.knownVersion ||
        accepted.updatedAt == null) {
      return false;
    }
    return incoming.isAfter(accepted.updatedAt!);
  }

  static SyncCausalBase _baseFromPending(PendingSyncRow row) {
    return switch (row.baseState) {
      'knownAbsent' => const SyncCausalBase.knownAbsent(),
      'knownVersion' when row.baseUpdatedAt != null =>
        SyncCausalBase.knownVersion(row.baseUpdatedAt),
      _ => const SyncCausalBase.unbound(),
    };
  }

  static bool _pendingMatchesBase(
    PendingSyncRow pending,
    SyncCausalBase? base,
  ) {
    if (base == null) return false;
    if (pending.baseState != base.state.storageValue) return false;
    if (base.state == SyncCausalBaseState.knownAbsent) {
      return pending.baseUpdatedAt == null;
    }
    final left = pending.baseUpdatedAt;
    final right = base.updatedAt;
    return left != null && right != null && left.isAtSameMomentAs(right);
  }

  static bool _sameIdentity(
    PendingSyncRow row,
    PendingSyncIdentity identity,
  ) =>
      row.id == identity.id &&
      row.revision == identity.revision &&
      row.mutationId == identity.mutationId;
}

enum SyncApplyAction { upsert, delete, adoptTimestamp, ignore }

SyncApplyAction resolveIncomingChange({
  required DateTime? incomingUpdatedAt,
  required DateTime? localUpdatedAt,
  required bool isEcho,
  required bool hasPendingUpsert,
  required bool isDelete,
}) {
  if (isDelete) {
    return hasPendingUpsert ? SyncApplyAction.ignore : SyncApplyAction.delete;
  }
  if (isEcho) return SyncApplyAction.adoptTimestamp;
  if (localUpdatedAt == null) return SyncApplyAction.upsert;
  if (incomingUpdatedAt == null) return SyncApplyAction.ignore;
  return incomingUpdatedAt.isAfter(localUpdatedAt)
      ? SyncApplyAction.upsert
      : SyncApplyAction.ignore;
}
