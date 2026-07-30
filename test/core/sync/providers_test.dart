import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';

void main() {
  test('syncStatusProvider emits idle from fake engine', () async {
    final container = ProviderContainer(
      overrides: [
        syncEngineProvider.overrideWithValue(FakeSyncEngine()),
      ],
    );
    addTearDown(container.dispose);

    final status = await container.read(syncStatusProvider.future);

    expect(status, isA<SyncIdle>());
  });

  test('manual retry provider calls force flush', () async {
    final engine = FakeSyncEngine();
    final container = ProviderContainer(
      overrides: [
        syncEngineProvider.overrideWithValue(engine),
      ],
    );
    addTearDown(container.dispose);

    await container.read(manualSyncRetryProvider.future);

    expect(engine.forceFlushCalls, 1);
  });
}
