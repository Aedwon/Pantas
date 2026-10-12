import 'dart:async';

import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

class PaymentEntitlementState {
  PaymentEntitlementState(this._store);

  final EntitlementSnapshotStore _store;
  final StreamController<Entitlement> _controller =
      StreamController<Entitlement>.broadcast(sync: true);

  Entitlement? _current;
  bool _initialized = false;
  int _epoch = 0;
  Future<void> _persistenceTail = Future<void>.value();
  Object? _lastPersistenceError;

  Entitlement? get current => _current;
  Stream<Entitlement> get updates => _controller.stream;
  bool get hasPendingPersistence => _lastPersistenceError != null;
  Object? get lastPersistenceError => _lastPersistenceError;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    final epoch = _epoch;
    final snapshot = await _store.readConfirmed() ?? const Entitlement.free();
    if (epoch == _epoch) _current = snapshot;
  }

  Future<String?> readOwner() => _store.readOwner();
  Future<void> writeOwner(String uid) => _store.writeOwner(uid);

  Future<void> clear() {
    _epoch++;
    _current = const Entitlement.free();
    _initialized = true;
    if (!_controller.isClosed) _controller.add(_current!);
    final cleared = _persistenceTail.then((_) async {
      try {
        await _store.clear();
        _lastPersistenceError = null;
      } catch (error) {
        _lastPersistenceError = error;
      }
    });
    _persistenceTail = cleared;
    return cleared;
  }

  Future<void> acceptAuthoritative(
    Entitlement entitlement, {
    bool Function()? shouldContinue,
  }) async {
    await initialize();
    if (shouldContinue != null && !shouldContinue()) return;

    if (_current != entitlement) {
      _current = entitlement;
      if (!_controller.isClosed) _controller.add(entitlement);
    }

    final persistence = _persistenceTail.then((_) async {
      if (shouldContinue != null && !shouldContinue()) return;
      await _persist(entitlement);
    });
    _persistenceTail = persistence;
    await persistence;
  }

  Future<void> _persist(Entitlement entitlement) async {
    try {
      await _store.writeConfirmed(entitlement);
      _lastPersistenceError = null;
    } catch (error) {
      _lastPersistenceError = error;
    }
  }
}
