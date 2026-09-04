import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

// ignore_for_file: cascade_invocations

void main() {
  test('strict lifecycle ignores non-strict attempts', () {
    var forfeited = false;
    final lifecycle = StrictModeLifecycle(
      strictMode: false,
      onForfeit: () => forfeited = true,
    );

    lifecycle
      ..paused(DateTime.utc(2026))
      ..elapse(const Duration(seconds: 10));

    expect(forfeited, isFalse);
  });

  test(
    'strict lifecycle forfeits only after more than five seconds backgrounded',
    () {
      var forfeits = 0;
      final lifecycle = StrictModeLifecycle(
        strictMode: true,
        onForfeit: () => forfeits += 1,
      );

      lifecycle
        ..paused(DateTime.utc(2026))
        ..elapse(const Duration(seconds: 5));
      expect(forfeits, 0);

      lifecycle.elapse(const Duration(milliseconds: 1));
      expect(forfeits, 1);

      lifecycle.elapse(const Duration(seconds: 10));
      expect(forfeits, 1);
    },
  );

  test(
    'strict lifecycle cancels guard when app resumes within five seconds',
    () {
      var forfeited = false;
      final lifecycle = StrictModeLifecycle(
        strictMode: true,
        onForfeit: () => forfeited = true,
      );

      lifecycle
        ..paused(DateTime.utc(2026))
        ..elapse(const Duration(seconds: 4))
        ..resumed(DateTime.utc(2026).add(const Duration(seconds: 4)))
        ..elapse(const Duration(seconds: 10));

      expect(forfeited, isFalse);
    },
  );

  test('strict lifecycle catches a suspended timer from wall time', () {
    var forfeited = false;
    final lifecycle = StrictModeLifecycle(
      strictMode: true,
      onForfeit: () => forfeited = true,
    );
    final backgroundedAt = DateTime.utc(2026);

    lifecycle
      ..paused(backgroundedAt)
      ..resumed(backgroundedAt.add(const Duration(seconds: 6)));

    expect(forfeited, isTrue);
  });
}
