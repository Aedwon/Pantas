import 'dart:async';

import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';

class PaymentEntitlementState {
  PaymentEntitlementState(this._store);

  final EntitlementSnapshotStore _store;
  final StreamController<Entitlement> _controller =
      StreamController<Entitlement>.broadcast();

  Entitlement? _current;
  bool _initialized = false;

  Entitlement? get current => _current;
  Stream<Entitlement> get updates => _controller.stream;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _current = await _store.readConfirmed() ?? const Entitlement.free();
  }

  Future<void> acceptAuthoritative(Entitlement entitlement) async {
    await initialize();
    await _store.writeConfirmed(entitlement);
    if (_current == entitlement) return;
    _current = entitlement;
    if (!_controller.isClosed) _controller.add(entitlement);
  }
}
