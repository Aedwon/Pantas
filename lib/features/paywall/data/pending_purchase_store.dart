import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:pantas/features/paywall/data/entitlement_snapshot_store.dart';

@immutable
class PendingPurchase {
  const PendingPurchase({
    required this.uid,
    required this.productId,
    required this.startedAt,
  });

  final String uid;
  final String productId;
  final DateTime startedAt;
}

class PendingPurchaseStore {
  PendingPurchaseStore({
    required EntitlementSnapshotRead readValue,
    required EntitlementSnapshotWrite writeValue,
  })  : _readValue = readValue,
        _writeValue = writeValue;

  factory PendingPurchaseStore.inMemory() {
    final values = <String, String>{};
    return PendingPurchaseStore(
      readValue: (key) async => values[key],
      writeValue: (key, value) async => values[key] = value,
    );
  }

  final EntitlementSnapshotRead _readValue;
  final EntitlementSnapshotWrite _writeValue;
  final _changes = StreamController<String>.broadcast(sync: true);

  Future<PendingPurchase?> read(String uid) async {
    final raw = await _readValue('payment_pending_v1:$uid');
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['uid'] != uid) return null;
      return PendingPurchase(
        uid: uid,
        productId: json['productId'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String).toUtc(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(PendingPurchase marker) async {
    await _writeValue(
      'payment_pending_v1:${marker.uid}',
      jsonEncode({
        'uid': marker.uid,
        'productId': marker.productId,
        'startedAt': marker.startedAt.toUtc().toIso8601String(),
      }),
    );
    if (!_changes.isClosed) _changes.add(marker.uid);
  }

  Future<void> clear(String uid) async {
    await _writeValue('payment_pending_v1:$uid', '');
    if (!_changes.isClosed) _changes.add(uid);
  }

  Stream<PendingPurchase?> watch(String uid) async* {
    final updates = StreamIterator(_changes.stream);
    try {
      yield await read(uid);
      while (await updates.moveNext()) {
        if (updates.current == uid) yield await read(uid);
      }
    } finally {
      await updates.cancel();
    }
  }

  Future<void> dispose() => _changes.close();
}
