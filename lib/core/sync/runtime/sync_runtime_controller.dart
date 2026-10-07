import 'dart:async';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/bootstrap/full_pull.dart';
import 'package:pantas/core/sync/bootstrap/full_push.dart';
import 'package:pantas/core/sync/eligibility/sync_claim_gateway.dart';
import 'package:pantas/core/sync/eligibility/sync_entitlement.dart';
import 'package:pantas/core/sync/engine/generation_repository.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_meaningful_progress.dart';
import 'package:pantas/core/sync/sync_coordinator.dart';
import 'package:pantas/core/sync/sync_status.dart';

typedef GenerationRepositoryFactory = GenerationRepository Function(String uid);

enum SyncReconciliationChoice { keepThisDevice, keepMyAccount }

abstract interface class SyncRuntimeEngine {
  Future<void> start({required String uid, required String generationId});

  Future<void> stop();

  Future<void> forceFlush();
}

sealed class SyncRuntimeEvent {
  const SyncRuntimeEvent();
}

class SyncRuntimeActivity extends SyncRuntimeEvent {
  const SyncRuntimeActivity();
}

class SyncRuntimeSettled extends SyncRuntimeEvent {
  const SyncRuntimeSettled();
}

class SyncRuntimeOffline extends SyncRuntimeEvent {
  const SyncRuntimeOffline();
}

class SyncRuntimeFailure extends SyncRuntimeEvent {
  const SyncRuntimeFailure(this.message);

  final String message;
}

// ignore: one_member_abstracts
abstract interface class SyncRuntimeLifecycle {
  Future<void> quiesce({required bool flush});
}

class SyncRuntimeController implements SyncRuntimeLifecycle {
  SyncRuntimeController({
    required AppDatabase db,
    required SyncClaimGateway claimGateway,
    required SyncActiveContextStore activeContextStore,
    required GenerationRepositoryFactory generationRepositoryForUid,
    required SyncCoordinator coordinator,
    required SyncRuntimeEngine engine,
    Stream<SyncRuntimeEvent>? runtimeEvents,
  })  : _db = db,
        _claimGateway = claimGateway,
        _activeContextStore = activeContextStore,
        _generationRepositoryForUid = generationRepositoryForUid,
        _coordinator = coordinator,
        _engine = engine {
    _runtimeEventSubscription = runtimeEvents?.listen(_handleRuntimeEvent);
  }

  final AppDatabase _db;
  final SyncClaimGateway _claimGateway;
  final SyncActiveContextStore _activeContextStore;
  final GenerationRepositoryFactory _generationRepositoryForUid;
  final SyncCoordinator _coordinator;
  final SyncRuntimeEngine _engine;
  final _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription<SyncRuntimeEvent>? _runtimeEventSubscription;

  Future<void> _serialTail = Future<void>.value();
  SyncStatus _status = const SyncOff();
  _PendingReconciliation? _pendingReconciliation;
  int _transitionToken = 0;
  int _runtimeEventToken = 0;
  bool _activeSync = false;
  Timer? _bootstrapRetry;

  SyncStatus get status => _status;

  Stream<SyncStatus> get statuses async* {
    yield _status;
    yield* _statusController.stream;
  }

  Future<void> update({
    required SyncIdentity identity,
    required SyncEntitlement entitlement,
  }) async {
    final token = ++_transitionToken;
    _cancelBootstrapRetry();
    _pendingReconciliation = null;

    if (identity.isAnonymous || entitlement != SyncEntitlement.pro) {
      _emit(const SyncOff());
      await _activeContextStore.clearStable();
      return _enqueue(() async {
        await _engine.stop();
        if (_isCurrent(token)) {
          _activeSync = false;
        }
      });
    }

    _emit(const SyncActivating());
    await _activeContextStore.clearStable();
    return _enqueue(() => _activate(identity: identity, token: token));
  }

  Future<void> chooseReconciliation(SyncReconciliationChoice choice) {
    final pending = _pendingReconciliation;
    if (pending == null || !_isCurrent(pending.token)) {
      throw StateError('No current Sync reconciliation choice is pending');
    }
    _pendingReconciliation = null;
    _emit(const Syncing());
    return _enqueue(() async {
      if (!_isCurrent(pending.token)) return;
      switch (choice) {
        case SyncReconciliationChoice.keepThisDevice:
          await _pushThisDevice(
            identity: pending.identity,
            token: pending.token,
            expectedActiveGenerationId: pending.activeGenerationId,
          );
        case SyncReconciliationChoice.keepMyAccount:
          final result = await _coordinator.keepMyAccount(
            uid: pending.identity.uid,
            generationId: pending.activeGenerationId,
            shouldContinue: () => _isCurrent(pending.token),
          );
          if (!_isCurrent(pending.token)) return;
          await _handlePullResult(
            result: result,
            identity: pending.identity,
            generationId: pending.activeGenerationId,
            token: pending.token,
          );
      }
    });
  }

  @override
  Future<void> quiesce({required bool flush}) async {
    final token = ++_transitionToken;
    _cancelBootstrapRetry();
    final shouldFlush = flush && _activeSync;
    _pendingReconciliation = null;
    _emit(const SyncOff());
    await _activeContextStore.clearStable();

    return _enqueue(() async {
      await _engine.stop();
      _activeSync = false;
      if (shouldFlush) {
        await _engine.forceFlush();
      }
      if (!_isCurrent(token)) return;
    });
  }

  Future<void> close() async {
    ++_transitionToken;
    _cancelBootstrapRetry();
    await _activeContextStore.clearStable();
    await _runtimeEventSubscription?.cancel();
    await _enqueue(_engine.stop);
    await _statusController.close();
  }

  Future<void> _activate({
    required SyncIdentity identity,
    required int token,
  }) async {
    await _engine.stop();
    _activeSync = false;
    if (!_isCurrent(token)) return;

    bool hasClaim;
    try {
      hasClaim = await _claimGateway.refreshProClaim(uid: identity.uid);
    } on Object catch (error) {
      if (_isCurrent(token)) {
        _emit(SyncError(message: '$error'));
      }
      return;
    }
    if (!_isCurrent(token)) return;

    final eligibility = evaluateSyncEligibility(
      identity: identity,
      entitlement: SyncEntitlement.pro,
      hasFreshProClaim: hasClaim,
    );
    if (eligibility == SyncEligibility.activating) {
      _emit(const SyncActivating());
      return;
    }
    if (eligibility != SyncEligibility.eligible) {
      _emit(const SyncOff());
      return;
    }

    _emit(const Syncing());
    await _runB3(identity: identity, token: token);
  }

  Future<void> _runB3({
    required SyncIdentity identity,
    required int token,
  }) async {
    while (_isCurrent(token)) {
      final localMeaningful =
          await SyncMeaningfulProgress(_db).hasMeaningfulData();
      if (!_isCurrent(token)) return;

      final generations = _generationRepositoryForUid(identity.uid);
      String? activeGenerationId;
      try {
        activeGenerationId = await generations.readActiveGenerationId();
      } on Object catch (error) {
        if (_isCurrent(token)) {
          _emit(SyncError(message: '$error'));
        }
        return;
      }
      if (!_isCurrent(token)) return;

      if (activeGenerationId == null) {
        if (await _pushThisDevice(
          identity: identity,
          token: token,
          expectedActiveGenerationId: null,
          retryB3: false,
        )) {
          return;
        }
        continue;
      }

      if (!localMeaningful) {
        final result = await _coordinator.keepMyAccount(
          uid: identity.uid,
          generationId: activeGenerationId,
          shouldContinue: () => _isCurrent(token),
        );
        if (!_isCurrent(token)) return;
        if (await _handlePullResult(
          result: result,
          identity: identity,
          generationId: activeGenerationId,
          token: token,
          retryB3: false,
        )) {
          return;
        }
        continue;
      }

      bool cloudMeaningful;
      try {
        cloudMeaningful =
            await generations.hasMeaningfulCloudData(activeGenerationId);
      } on Object catch (error) {
        if (_isCurrent(token)) {
          _emit(SyncError(message: '$error'));
        }
        return;
      }
      if (!_isCurrent(token)) return;

      if (cloudMeaningful) {
        _pendingReconciliation = _PendingReconciliation(
          token: token,
          identity: identity,
          activeGenerationId: activeGenerationId,
        );
        _emit(
          SyncReconciliationRequired(
            activeGenerationId: activeGenerationId,
          ),
        );
        return;
      }

      if (await _pushThisDevice(
        identity: identity,
        token: token,
        expectedActiveGenerationId: activeGenerationId,
        retryB3: false,
      )) {
        return;
      }
    }
  }

  Future<bool> _pushThisDevice({
    required SyncIdentity identity,
    required int token,
    required String? expectedActiveGenerationId,
    bool retryB3 = true,
  }) async {
    try {
      final result = await _coordinator.keepThisDevice(
        uid: identity.uid,
        expectedActiveGenerationId: expectedActiveGenerationId,
        shouldContinue: () => _isCurrent(token),
      );
      if (!_isCurrent(token)) return true;
      return await _handlePushResult(
        result: result,
        identity: identity,
        token: token,
        expectedActiveGenerationId: expectedActiveGenerationId,
        retryB3: retryB3,
      );
    } on Object catch (error) {
      if (_isCurrent(token)) {
        _emit(SyncError(message: '$error'));
        _scheduleBootstrapRetry(identity, token, expectedActiveGenerationId);
      }
      return true;
    }
  }

  void _cancelBootstrapRetry() {
    _bootstrapRetry?.cancel();
    _bootstrapRetry = null;
  }

  void _scheduleBootstrapRetry(
    SyncIdentity identity,
    int token,
    String? expectedActiveGenerationId,
  ) {
    _cancelBootstrapRetry();
    // The rules allow a new staging generation after five minutes.
    _bootstrapRetry = Timer(const Duration(minutes: 5, seconds: 1), () {
      _bootstrapRetry = null;
      if (!_isCurrent(token)) return;
      unawaited(
        _enqueue(() async {
          if (!_isCurrent(token)) return;
          try {
            final hasClaim =
                await _claimGateway.refreshProClaim(uid: identity.uid);
            if (!_isCurrent(token)) return;
            if (!hasClaim) {
              _emit(const SyncActivating());
              return;
            }
            _emit(const Syncing());
            await _pushThisDevice(
              identity: identity,
              token: token,
              expectedActiveGenerationId: expectedActiveGenerationId,
            );
          } on Object catch (error) {
            if (_isCurrent(token)) {
              _emit(SyncError(message: '$error'));
              _scheduleBootstrapRetry(
                identity,
                token,
                expectedActiveGenerationId,
              );
            }
          }
        }),
      );
    });
  }

  Future<bool> _handlePushResult({
    required FullPushResult result,
    required SyncIdentity identity,
    required int token,
    required String? expectedActiveGenerationId,
    bool retryB3 = true,
  }) async {
    switch (result.outcome) {
      case FullPushOutcome.activated:
        await _finalizeActive(
          identity: identity,
          generationId: result.generationId,
          token: token,
        );
        return true;
      case FullPushOutcome.staleLocalEpoch:
      case FullPushOutcome.generationConflict:
        if (retryB3) {
          await _runB3(identity: identity, token: token);
          return true;
        }
        return false;
      case FullPushOutcome.cancelled:
        return true;
      case FullPushOutcome.retryableFailure:
        _emit(const SyncError(message: 'Sync bootstrap upload failed'));
        _scheduleBootstrapRetry(identity, token, expectedActiveGenerationId);
        return true;
    }
  }

  Future<bool> _handlePullResult({
    required FullPullResult result,
    required SyncIdentity identity,
    required String generationId,
    required int token,
    bool retryB3 = true,
  }) async {
    switch (result.outcome) {
      case FullPullOutcome.applied:
        await _finalizeActive(
          identity: identity,
          generationId: generationId,
          token: token,
        );
        return true;
      case FullPullOutcome.appliedProjectionPending:
        await _finalizeActive(
          identity: identity,
          generationId: generationId,
          token: token,
          forceUnsettled: true,
        );
        return true;
      case FullPullOutcome.staleLocalEpoch:
        if (retryB3) {
          await _runB3(identity: identity, token: token);
          return true;
        }
        return false;
      case FullPullOutcome.cancelled:
        return true;
      case FullPullOutcome.retryableFailure:
        _emit(const SyncError(message: 'Sync bootstrap download failed'));
        return true;
      case FullPullOutcome.invalidSnapshot:
        _emit(const SyncError(message: 'Sync cloud snapshot is invalid'));
        return true;
    }
  }

  Future<void> _finalizeActive({
    required SyncIdentity identity,
    required String generationId,
    required int token,
    bool forceUnsettled = false,
  }) async {
    if (!_isCurrent(token)) return;
    await _activeContextStore.publishStable(
      uid: identity.uid,
      generationId: generationId,
    );
    if (!_isCurrent(token)) {
      await _activeContextStore.clearStable();
      return;
    }

    try {
      await _engine.start(uid: identity.uid, generationId: generationId);
    } on Object catch (error) {
      await _activeContextStore.clearStable();
      _activeSync = false;
      if (_isCurrent(token)) {
        _emit(SyncError(message: '$error'));
      }
      return;
    }
    if (!_isCurrent(token)) {
      await _activeContextStore.clearStable();
      await _engine.stop();
      return;
    }

    _activeSync = true;
    await _refreshSettledStatus(forceUnsettled: forceUnsettled);
  }

  void _handleRuntimeEvent(SyncRuntimeEvent event) {
    if (!_activeSync) return;
    final transitionToken = _transitionToken;
    final eventToken = ++_runtimeEventToken;
    switch (event) {
      case SyncRuntimeActivity():
        _emit(const Syncing());
      case SyncRuntimeSettled():
        unawaited(_refreshFromRuntimeEvent(transitionToken, eventToken));
      case SyncRuntimeOffline():
        _emit(const SyncOffline());
      case SyncRuntimeFailure(:final message):
        _emit(SyncError(message: message));
    }
  }

  Future<void> _refreshFromRuntimeEvent(
    int transitionToken,
    int eventToken,
  ) {
    return _enqueue(() async {
      if (!_activeSync || !_isCurrent(transitionToken)) return;
      try {
        final status = await _readSettledStatus();
        if (!_activeSync ||
            !_isCurrent(transitionToken) ||
            eventToken != _runtimeEventToken) {
          return;
        }
        _emit(status);
      } on Object catch (error) {
        if (_activeSync &&
            _isCurrent(transitionToken) &&
            eventToken == _runtimeEventToken) {
          _emit(SyncError(message: '$error'));
        }
      }
    });
  }

  Future<void> _refreshSettledStatus({bool forceUnsettled = false}) async {
    _emit(await _readSettledStatus(forceUnsettled: forceUnsettled));
  }

  Future<SyncStatus> _readSettledStatus({
    bool forceUnsettled = false,
  }) async {
    final pending = await _db.select(_db.pendingSync).get();
    final failed = pending.where((row) => row.lastError != null).toList();
    if (failed.isNotEmpty) {
      return SyncError(message: failed.first.lastError);
    }
    final journal = await _db
        .customSelect(
          'select 1 as pending from sync_local_mutations limit 1',
        )
        .get();
    final markers = await _db
        .customSelect(
          "select 1 as pending from sync_meta where value = '1' and ( "
          "key = 'pending_full_push' or key = 'pending_full_pull' or "
          "key like 'customTrackProjectionRequired:%') limit 1",
        )
        .get();
    if (forceUnsettled ||
        pending.isNotEmpty ||
        journal.isNotEmpty ||
        markers.isNotEmpty) {
      return Syncing(pendingCount: pending.length);
    }
    return const SyncUpToDate();
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final run = _serialTail.then((_) => operation());
    _serialTail = run.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return run;
  }

  bool _isCurrent(int token) => token == _transitionToken;

  void _emit(SyncStatus status) {
    _status = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }
}

class _PendingReconciliation {
  const _PendingReconciliation({
    required this.token,
    required this.identity,
    required this.activeGenerationId,
  });

  final int token;
  final SyncIdentity identity;
  final String activeGenerationId;
}
