import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/engine/backoff_policy.dart';

void main() {
  test('backoff emits 1s through 1024s then caps at 30 minutes', () {
    final policy = BackoffPolicy();

    final delays = List.generate(13, (_) => policy.nextDelay());

    expect(delays.take(11), [
      const Duration(seconds: 1),
      const Duration(seconds: 2),
      const Duration(seconds: 4),
      const Duration(seconds: 8),
      const Duration(seconds: 16),
      const Duration(seconds: 32),
      const Duration(seconds: 64),
      const Duration(seconds: 128),
      const Duration(seconds: 256),
      const Duration(seconds: 512),
      const Duration(seconds: 1024),
    ]);
    expect(delays[11], const Duration(minutes: 30));
    expect(delays[12], const Duration(minutes: 30));
  });

  test('reconnect reset restarts backoff at 1s', () {
    final policy = BackoffPolicy();

    advanceTwiceAndReset(policy);

    expect(policy.nextDelay(), const Duration(seconds: 1));
  });
}

void advanceTwiceAndReset(BackoffPolicy policy) {
  policy
    ..nextDelay()
    ..nextDelay()
    ..reset();
}
