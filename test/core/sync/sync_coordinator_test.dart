import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/sync_coordinator.dart';

void main() {
  test('pushLocalToCloud delegates to full push', () async {
    var calls = 0;
    final coordinator = SyncCoordinatorImpl(
      fullPush: () async => calls += 1,
      fullPull: () async {},
    );

    await coordinator.pushLocalToCloud();

    expect(calls, 1);
  });

  test('pullCloudToLocal delegates to full pull', () async {
    var calls = 0;
    final coordinator = SyncCoordinatorImpl(
      fullPush: () async {},
      fullPull: () async => calls += 1,
    );

    await coordinator.pullCloudToLocal();

    expect(calls, 1);
  });
}
