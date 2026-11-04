import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/features/home/application/settling_retry.dart';
import 'package:pantas/features/home/application/today_questions.dart';

void main() {
  group('isSettlingFailure', () {
    test('every guard message the first read can raise while starting up', () {
      const disposed = 'The provider X(e) was disposed during loading state, '
          'yet no value could be emitted.';
      for (final message in [
        'Quiz owner changed',
        'Home owner changed',
        'Study owner changed',
        'Quiz owner unavailable',
        'Quiz account is unavailable',
        'Quiz account changed',
        'Quiz controller is unavailable',
        'Study account unavailable',
        'Study exam changed',
        'Study exam unavailable',
        'Plan exam unavailable',
        disposed,
        'Cannot call onDispose after a provider was dispose',
      ]) {
        expect(isSettlingFailure(StateError(message)), isTrue, reason: message);
      }
    });

    test('server failures that clear by themselves', () {
      for (final code in [
        'unavailable',
        'deadline-exceeded',
        'unauthenticated',
      ]) {
        final error = FirebaseFunctionsException(code: code, message: 'x');
        expect(isSettlingFailure(error), isTrue, reason: code);
      }
      expect(
        isSettlingFailure(
          FirebaseFunctionsException(
            code: 'failed-precondition',
            message: 'Set your exam first.',
          ),
        ),
        isTrue,
      );
    });

    test('real failures are not held', () {
      for (final error in [
        StateError('Planned lesson content unavailable'),
        StateError('Reviews content unavailable'),
        const FormatException('Invalid study response'),
      ]) {
        expect(isSettlingFailure(error), isFalse, reason: '$error');
      }
      expect(
        isSettlingFailure(
          FirebaseFunctionsException(code: 'permission-denied', message: 'No'),
        ),
        isFalse,
      );
      expect(
        isSettlingFailure(
          FirebaseFunctionsException(
            code: 'failed-precondition',
            message: 'Something else.',
          ),
        ),
        isFalse,
      );
    });
  });

  group('SettlingRetry', () {
    test('retries on a growing delay, then lets the failure show', () {
      fakeAsync((async) {
        var retries = 0;
        final retry = SettlingRetry(
          retry: () => retries++,
          delays: const [
            Duration(milliseconds: 100),
            Duration(milliseconds: 200),
          ],
        );
        final held = StateError('Quiz owner changed');
        expect(retry.failed(held), isTrue);
        async.elapse(const Duration(milliseconds: 99));
        expect(retries, 0);
        async.elapse(const Duration(milliseconds: 1));
        expect(retries, 1);
        expect(retry.failed(held), isTrue);
        async.elapse(const Duration(milliseconds: 200));
        expect(retries, 2);
        expect(retry.failed(held), isFalse);
        async.elapse(const Duration(seconds: 10));
        expect(retries, 2);
        retry.reset();
        expect(retry.failed(held), isTrue);
        retry.dispose();
        async.elapse(const Duration(seconds: 10));
        expect(retries, 2);
      });
    });

    test('a real failure is never retried', () {
      fakeAsync((async) {
        var retries = 0;
        final retry = SettlingRetry(retry: () => retries++);
        final error = StateError('Planned lesson content unavailable');
        expect(retry.failed(error), isFalse);
        async.elapse(const Duration(seconds: 30));
        expect(retries, 0);
      });
    });
  });

  test('the owner guard is not captured until the account and exam settle',
      () async {
    final auth = StreamController<AuthState>();
    final focus = Completer<ActiveExamFocus>();
    addTearDown(auth.close);
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith((ref) => auth.stream),
        activeExamFocusProvider.overrideWith((ref) => focus.future),
      ],
    );
    addTearDown(container.dispose);
    final launcher = container.read(todayQuestionLauncherProvider);
    var captured = false;
    unawaited(
      launcher.captureGuard('e1', isAlive: () => true).then<void>(
            (_) => captured = true,
            onError: (_, __) => captured = true,
          ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(captured, isFalse, reason: 'account still loading');
    auth.add(const AnonymousAuthState(uid: 'u'));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(captured, isFalse, reason: 'exam still loading');
    focus.complete(const ActiveExamFocus.needsSelection());
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(captured, isTrue);
  });
}
