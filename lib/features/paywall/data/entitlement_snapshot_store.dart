import 'dart:convert';

import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

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

      final planName = decoded['plan'] as String?;
      final plan = EntitlementPlan.values
          .where((candidate) => candidate.name == planName)
          .firstOrNull;
      if (plan == null) return null;
      if (unknown && (productId == null || productId.isEmpty)) return null;

      return Entitlement(
        plan: plan,
        productId: productId,
        expiresAt: expiresAt,
        isTrial: isTrial,
        willRenew: willRenew,
        isUnknownPlan: unknown,
        tier: _enumValue(PriceTier.values, decoded['tier']),
        state: _enumValue(EntitlementState.values, decoded['state']),
        endsAt: _date(decoded['endsAt']),
        renewsAt: _date(decoded['renewsAt']),
        chargesAt: _date(decoded['chargesAt']),
        passes: {
          for (final entry
              in (decoded['passes'] as Map<String, dynamic>? ?? {}).entries)
            entry.key: DateTime.parse(entry.value as String).toUtc(),
        },
        subscriptions: _periods(decoded['subscriptions']),
        promotions: _periods(decoded['promotions']),
        examTiers: {
          for (final entry
              in (decoded['examTiers'] as Map<String, dynamic>? ?? {}).entries)
            entry.key: PriceTier.values.byName(entry.value as String),
        },
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
      'tier': entitlement.tier?.name,
      'state': entitlement.state.name,
      'endsAt': entitlement.endsAt?.toUtc().toIso8601String(),
      'renewsAt': entitlement.renewsAt?.toUtc().toIso8601String(),
      'chargesAt': entitlement.chargesAt?.toUtc().toIso8601String(),
      'passes': {
        for (final entry in entitlement.passes.entries)
          entry.key: entry.value.toUtc().toIso8601String(),
      },
      'subscriptions': _encodePeriods(entitlement.subscriptions),
      'promotions': _encodePeriods(entitlement.promotions),
      'examTiers': {
        for (final entry in entitlement.examTiers.entries)
          entry.key: entry.value.name,
      },
    });
    return _writeValue(storageKey, value);
  }
}

T? _enumValue<T extends Enum>(List<T> values, Object? raw) =>
    values.where((value) => value.name == raw).firstOrNull;

DateTime? _date(Object? raw) =>
    raw is String ? DateTime.tryParse(raw)?.toUtc() : null;

List<CoveragePeriod> _periods(Object? raw) => [
      for (final row
          in (raw as List<dynamic>? ?? []).cast<Map<String, dynamic>>())
        CoveragePeriod(
          id: row['id'] as String,
          endsAt: DateTime.parse(row['endsAt'] as String).toUtc(),
          active: row['active'] == true,
        ),
    ];

List<Map<String, Object>> _encodePeriods(List<CoveragePeriod> periods) => [
      for (final period in periods)
        {
          'id': period.id,
          'endsAt': period.endsAt.toUtc().toIso8601String(),
          'active': period.active,
        },
    ];

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
