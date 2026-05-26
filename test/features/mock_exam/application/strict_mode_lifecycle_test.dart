import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: cascade_invocations

void main() {
  test('strict lifecycle ignores non-strict attempts', () {
    var forfeited = false;
    final lifecycle = StrictModeLifecycle(
      strictMode: false,
      onForfeit: () => forfeited = true,
    );

    lifecycle
      ..paused()
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
        ..paused()
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
        ..paused()
        ..elapse(const Duration(seconds: 4))
        ..resumed()
        ..elapse(const Duration(seconds: 10));

      expect(forfeited, isFalse);
    },
  );
}
