import 'dart:convert';

import 'package:pantas/features/paywall/domain/entitlement.dart';

typedef EntitlementSnapshotRead = Future<String?> Function(String key);
typedef EntitlementSnapshotWrite = Future<void> Function(
  String key,
  String value,
);

class EntitlementSnapshotStore {
  EntitlementSnapshotStore({
    required EntitlementSnapshotRead readValue,
    required EntitlementSnapshotWrite writeValue,
  })  : _readValue = readValue,
        _writeValue = writeValue;

  factory EntitlementSnapshotStore.inMemory() {
    final values = <String, String>{};
    return EntitlementSnapshotStore(
      readValue: (key) async => values[key],
      writeValue: (key, value) async => values[key] = value,
    );
  }

  static const storageKey = 'payment_last_confirmed_entitlement_v1';

  final EntitlementSnapshotRead _readValue;
  final EntitlementSnapshotWrite _writeValue;

  Future<Entitlement?> readConfirmed() async {
    final raw = await _readValue(storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final unknown = decoded['unknown'] == true;
      final productId = decoded['productId'] as String?;
      final expiresAtRaw = decoded['expiresAt'] as String?;
      final expiresAt = expiresAtRaw == null
          ? null
          : DateTime.tryParse(expiresAtRaw)?.toUtc();
      final isTrial = decoded['isTrial'] == true;
      final willRenew = decoded['willRenew'] == true;

      if (unknown) {
        if (productId == null || productId.isEmpty) return null;
        return Entitlement.activeUnknown(
          productId: productId,
          expiresAt: expiresAt,
          isTrial: isTrial,
          willRenew: willRenew,
        );
      }

      final planName = decoded['plan'] as String?;
      final plan = EntitlementPlan.values
          .where((candidate) => candidate.name == planName)
          .firstOrNull;
      if (plan == null) return null;
      if (plan == EntitlementPlan.free) return const Entitlement.free();

      return Entitlement(
        plan: plan,
        productId: productId,
        expiresAt: expiresAt,
        isTrial: isTrial,
        willRenew: willRenew,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> writeConfirmed(Entitlement entitlement) {
    final value = jsonEncode({
      'plan': entitlement.plan.name,
      'productId': entitlement.productId,
      'expiresAt': entitlement.expiresAt?.toUtc().toIso8601String(),
      'isTrial': entitlement.isTrial,
      'willRenew': entitlement.willRenew,
      'unknown': entitlement.isUnknownPlan,
    });
    return _writeValue(storageKey, value);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
