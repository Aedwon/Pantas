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
  Future<void> _persistenceTail = Future<void>.value();
  Object? _lastPersistenceError;

  Entitlement? get current => _current;
  Stream<Entitlement> get updates => _controller.stream;
  bool get hasPendingPersistence => _lastPersistenceError != null;
  Object? get lastPersistenceError => _lastPersistenceError;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _current = await _store.readConfirmed() ?? const Entitlement.free();
  }

  Future<void> acceptAuthoritative(Entitlement entitlement) async {
    await initialize();

    if (_current != entitlement) {
      _current = entitlement;
      if (!_controller.isClosed) _controller.add(entitlement);
    }

    final persistence = _persistenceTail.then((_) => _persist(entitlement));
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
