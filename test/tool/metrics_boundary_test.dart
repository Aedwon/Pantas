import 'dart:io';

import 'package:pantas/features/metrics/domain/signal_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('metrics exposes exactly the locked measured signals', () {
    expect(
      SignalKey.values.map((key) => key.code).toSet(),
      {
        'T1',
        'T2',
        'T3',
        'P1',
        'P2',
        'P4',
        'S1',
        'U1',
        'X1',
        'X2',
        'D1',
        'D2',
        'D3',
      },
    );
  });

  test('derived metrics cache tables are not registered for sync', () {
    final registry = File(
      'lib/core/sync/engine/collection_registry.dart',
    ).readAsStringSync();

    expect(registry, isNot(contains('userMetricsArchetypesLocal')));
    expect(registry, isNot(contains('userMetricsArtifactsLocal')));
    expect(registry, isNot(contains('user_metrics_archetypes_local')));
    expect(registry, isNot(contains('user_metrics_artifacts_local')));
  });
}
