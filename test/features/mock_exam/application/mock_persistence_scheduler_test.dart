import 'package:pantas/features/mock_exam/mock_exam.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: cascade_invocations

void main() {
  test('answer mutations debounce into one flush', () {
    final flushed = <MockFlushPayload>[];
    final scheduler = MockPersistenceScheduler(onFlush: flushed.add);
    final payload = _payload(elapsedSeconds: 1);

    scheduler
      ..markChanged(payload)
      ..elapse(const Duration(milliseconds: 250))
      ..markChanged(_payload(elapsedSeconds: 2))
      ..elapse(const Duration(milliseconds: 499));

    expect(flushed, isEmpty);

    scheduler.elapse(const Duration(milliseconds: 1));
    expect(flushed, hasLength(1));
    expect(flushed.single.elapsedSeconds, 2);
  });

  test('heartbeat flushes elapsed every thirty seconds', () {
    final flushed = <MockFlushPayload>[];
    final scheduler = MockPersistenceScheduler(onFlush: flushed.add);

    scheduler
      ..heartbeat(_payload(elapsedSeconds: 30))
      ..elapse(const Duration(seconds: 29));
    expect(flushed, isEmpty);

    scheduler.elapse(const Duration(seconds: 1));
    expect(flushed.single.elapsedSeconds, 30);
  });

  test('pause and resume flush immediately', () {
    final flushed = <MockFlushPayload>[];
    final scheduler = MockPersistenceScheduler(onFlush: flushed.add);

    scheduler
      ..forceFlush(_payload(elapsedSeconds: 10, pausedAtLastFlush: true))
      ..forceFlush(_payload(elapsedSeconds: 10));

    expect(flushed.map((payload) => payload.pausedAtLastFlush), [true, false]);
  });
}

MockFlushPayload _payload({
  required int elapsedSeconds,
  bool pausedAtLastFlush = false,
}) {
  return MockFlushPayload(
    attemptId: 'mock_1',
    elapsedSeconds: elapsedSeconds,
    accumulatedPausedSeconds: 0,
    pausedAtLastFlush: pausedAtLastFlush,
    answersJson: '{}',
    flagsJson: '[]',
    currentIndex: 0,
  );
}
