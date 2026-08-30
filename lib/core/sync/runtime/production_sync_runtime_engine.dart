import 'dart:async';

import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/sync/engine/collection_registry.dart';
import 'package:pantas/core/sync/engine/pending_queue.dart';
import 'package:pantas/core/sync/engine/pull_pipeline.dart';
import 'package:pantas/core/sync/engine/push_pipeline.dart';
import 'package:pantas/core/sync/engine/sync_active_context_store.dart';
import 'package:pantas/core/sync/engine/sync_outbox_promoter.dart';
import 'package:pantas/core/sync/engine/sync_payload_loader.dart';
import 'package:pantas/core/sync/firestore/firestore_gateway.dart';
import 'package:pantas/core/sync/model/sync_document.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

class ProductionSyncRuntimeEngine implements SyncRuntimeEngine {
  ProductionSyncRuntimeEngine({
    required AppDatabase db,
    required FirestoreGateway gateway,
    required SyncActiveContextStore activeContextStore,
    required String deviceId,
    Future<bool> Function()? recoverCustomTrackProjection,
    Duration localMutationDebounce = const Duration(seconds: 5),
  })  : _db = db,
        _gateway = gateway,
        _activeContextStore = activeContextStore,
        _deviceId = deviceId,
        _recoverCustomTrackProjection = recoverCustomTrackProjection,
        _localMutationDebounce = localMutationDebounce;

  final AppDatabase _db;
  final FirestoreGateway _gateway;
  final SyncActiveContextStore _activeContextStore;
  final String _deviceId;
  final Future<bool> Function()? _recoverCustomTrackProjection;
  final Duration _localMutationDebounce;

  final _events = StreamController<SyncRuntimeEvent>.broadcast();
  final _remoteSubscriptions = <StreamSubscription<List<SyncDocument>>>[];
  final _offlinePaths = <String>{};
  // Cancelled explicitly by stop(); the listener is intentionally
  // runtime-lived.
  // ignore: cancel_subscriptions
  StreamSubscription<Object?>? _localMutationSubscription;
  Timer? _localMutationTimer;
  Future<void> _serialTail = Future<void>.value();

  PushPipeline? _push;
  SyncOutboxPromoter? _promoter;
  String? _uid;
  String? _generationId;
  int _runToken = 0;
  bool _running = false;

  Stream<SyncRuntimeEvent> get events => _events.stream;
  bool get isRunning => _running;
  String? get activeUid => _uid;
  String? get activeGenerationId => _generationId;

  @override
  Future<void> start({
    required String uid,
    required String generationId,
  }) async {
    if (uid.isEmpty) throw ArgumentError.value(uid, 'uid', 'must not be empty');
    if (generationId.isEmpty) {
      throw ArgumentError.value(
        generationId,
        'generationId',
        'must not be empty',
      );
    }

    await stop();
    _offlinePaths.clear();
    _uid = uid;
    _generationId = generationId;
    final queue = PendingQueue(_db);
    final pull = PullPipeline(
      db: _db,
      queue: queue,
      uid: uid,
      generationId: generationId,
      deviceId: _deviceId,
    );
    final loader = SyncLocalPayloadLoader(db: _db, deviceId: _deviceId);
    final push = PushPipeline(
      queue: queue,
      gateway: _gateway,
      uid: uid,
      generationId: generationId,
      deviceId: _deviceId,
      isAnonymous: false,
      loadPayload: loader.load,
      handleResult: pull.handlePushResult,
    );
    final promoter = SyncOutboxPromoter(
      _db,
      activeContextStore: _activeContextStore,
      pendingQueue: queue,
    );

    _push = push;
    _promoter = promoter;
    _running = true;
    final token = ++_runToken;

    for (final entry in activeSyncCollections) {
      final path =
          'users/$uid/sync_generations/$generationId/${entry.firestorePath}';
      final subscription = _gateway.watchCollection(path).listen(
        (documents) {
          if (!_isCurrent(token, uid, generationId)) return;
          final reconnecting = _offlinePaths.remove(path);
          _emit(const SyncRuntimeActivity());
          unawaited(
            _enqueue(() async {
              if (!_isCurrent(token, uid, generationId)) return;
              try {
                await pull.applyCompleteSnapshot(
                  generationId: generationId,
                  collection: entry.tableType,
                  documents: documents,
                );
                if (entry.tableType == 'track_scope') {
                  await _recoverCustomTrackProjection?.call();
                }
                if (reconnecting && _isCurrent(token, uid, generationId)) {
                  await _flushComponents(
                    uid: uid,
                    generationId: generationId,
                    promoter: promoter,
                    push: push,
                  );
                }
                if (_isCurrent(token, uid, generationId)) {
                  _emitCurrentOutcome();
                }
              } on Object catch (error, stackTrace) {
                if (_isCurrent(token, uid, generationId)) {
                  _emit(SyncRuntimeFailure('$error'));
                }
                Error.throwWithStackTrace(error, stackTrace);
              }
            }).catchError((Object _, StackTrace __) {}),
          );
        },
        onError: (Object _, StackTrace __) {
          if (!_isCurrent(token, uid, generationId)) return;
          _offlinePaths.add(path);
          _emit(const SyncRuntimeOffline());
        },
      );
      _remoteSubscriptions.add(subscription);
    }

    _localMutationSubscription =
        _db.select(_db.syncLocalMutations).watch().listen(
      (rows) {
        if (!_isCurrent(token, uid, generationId)) return;
        if (rows.isEmpty) {
          _localMutationTimer?.cancel();
          _localMutationTimer = null;
          _emitCurrentOutcome();
          return;
        }
        _emit(const SyncRuntimeActivity());
        _localMutationTimer?.cancel();
        _localMutationTimer = Timer(_localMutationDebounce, () {
          if (!_isCurrent(token, uid, generationId)) return;
          unawaited(forceFlush().catchError((Object _, StackTrace __) {}));
        });
      },
      onError: (Object error, StackTrace __) {
        if (_isCurrent(token, uid, generationId)) {
          _emit(SyncRuntimeFailure('$error'));
        }
      },
    );
  }

  @override
  Future<void> stop() async {
    _running = false;
    ++_runToken;
    _offlinePaths.clear();
    _localMutationTimer?.cancel();
    _localMutationTimer = null;
    final localSubscription = _localMutationSubscription;
    _localMutationSubscription = null;
    if (localSubscription != null) {
      await localSubscription.cancel();
    }
    final subscriptions = List.of(_remoteSubscriptions);
    _remoteSubscriptions.clear();
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await _serialTail;
  }

  @override
  Future<void> forceFlush() {
    final uid = _uid;
    final generationId = _generationId;
    final promoter = _promoter;
    final push = _push;
    if (uid == null ||
        generationId == null ||
        promoter == null ||
        push == null) {
      return Future<void>.value();
    }

    final publishStatus = _running;
    if (publishStatus) {
      _emit(const SyncRuntimeActivity());
    }
    return _enqueue(() async {
      try {
        await _flushComponents(
          uid: uid,
          generationId: generationId,
          promoter: promoter,
          push: push,
        );
        if (publishStatus && _running) {
          _emitCurrentOutcome();
        }
      } on Object catch (error, stackTrace) {
        if (publishStatus && _running) {
          _emit(SyncRuntimeFailure('$error'));
        }
        Error.throwWithStackTrace(error, stackTrace);
      }
    });
  }

  Future<void> _flushComponents({
    required String uid,
    required String generationId,
    required SyncOutboxPromoter promoter,
    required PushPipeline push,
  }) async {
    if (_running) {
      await promoter.promoteAvailable();
    } else {
      await promoter.promoteAvailableForContext(
        uid: uid,
        generationId: generationId,
      );
    }
    await push.flush();
    await _recoverCustomTrackProjection?.call();
  }

  void _emitCurrentOutcome() {
    if (_offlinePaths.isNotEmpty) {
      _emit(const SyncRuntimeOffline());
      return;
    }
    _emit(const SyncRuntimeSettled());
  }

  void _emit(SyncRuntimeEvent event) {
    if (!_events.isClosed) {
      _events.add(event);
    }
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    final run = _serialTail.then((_) => operation());
    _serialTail = run.then<void>(
      (_) {},
      onError: (Object _, StackTrace __) {},
    );
    return run;
  }

  bool _isCurrent(int token, String uid, String generationId) {
    return _running &&
        token == _runToken &&
        _uid == uid &&
        _generationId == generationId;
  }
}
