import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/sync/runtime/sync_account_transition_gateway.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

void main() {
  test('ordinary sign-out quiesces and requires flush', () async {
    final runtime = RecordingRuntimeLifecycle();
    final gateway = SyncAccountTransitionGateway(() => runtime);

    await gateway.prepareForSignOut();

    expect(runtime.calls, ['quiesce:true']);
  });

  test('a failed flush does not stop sign-out', () async {
    final runtime = RecordingRuntimeLifecycle(failFlush: true);
    final gateway = SyncAccountTransitionGateway(() => runtime);

    await gateway.prepareForSignOut();

    expect(runtime.calls, ['quiesce:true']);
  });

  test('a flush that hangs (offline) delays sign-out only to the limit',
      () async {
    final runtime = RecordingRuntimeLifecycle(hang: true);
    final gateway = SyncAccountTransitionGateway(
      () => runtime,
      signOutFlushLimit: const Duration(milliseconds: 50),
    );

    await gateway.prepareForSignOut().timeout(const Duration(seconds: 1));

    expect(runtime.calls, ['quiesce:true']);
  });

  test('sign-out and an account switch send the queued reports first',
      () async {
    final runtime = RecordingRuntimeLifecycle();
    var flushes = 0;
    final gateway = SyncAccountTransitionGateway(
      () => runtime,
      flushReports: () async => flushes++,
    );

    await gateway.prepareForSignOut();
    await gateway.prepareForAccountSwitch();

    expect(flushes, 2);
  });

  test('a failing or hanging report flush never stops sign-out or a switch',
      () async {
    final runtime = RecordingRuntimeLifecycle();
    final failing = SyncAccountTransitionGateway(
      () => runtime,
      flushReports: () async => throw StateError('offline'),
    );
    await failing.prepareForSignOut();
    await failing.prepareForAccountSwitch();
    final hanging = SyncAccountTransitionGateway(
      () => runtime,
      signOutFlushLimit: const Duration(milliseconds: 50),
      flushReports: () => Completer<void>().future,
    );
    await hanging.prepareForSignOut().timeout(const Duration(seconds: 1));
    await hanging.prepareForAccountSwitch().timeout(const Duration(seconds: 1));
  });

  group('unsent data blocks the wipe', () {
    test('sign-out stops before it touches Sync when something is unsent',
        () async {
      final runtime = RecordingRuntimeLifecycle();
      final calls = <String>[];
      final gateway = SyncAccountTransitionGateway(
        () => runtime,
        flushNow: () async => calls.add('flushNow'),
        flushReports: () async => calls.add('flushReports'),
        hasUnsentData: () async {
          calls.add('check');
          return true;
        },
      );

      await expectLater(
        gateway.prepareForSignOut(),
        throwsA(
          isA<AuthGatewayException>()
              .having((e) => e.code, 'code', 'network-request-failed'),
        ),
      );

      expect(calls, ['flushNow', 'flushReports', 'check']);
      expect(runtime.calls, isEmpty, reason: 'Sync keeps running');
    });

    test('an account switch stops the same way', () async {
      final runtime = RecordingRuntimeLifecycle();
      final gateway = SyncAccountTransitionGateway(
        () => runtime,
        hasUnsentData: () async => true,
      );

      await expectLater(
        gateway.prepareForAccountSwitch(),
        throwsA(isA<AuthGatewayException>()),
      );
      expect(runtime.calls, isEmpty);
    });

    test('with nothing unsent sign-out goes on as before', () async {
      final runtime = RecordingRuntimeLifecycle();
      final calls = <String>[];
      final gateway = SyncAccountTransitionGateway(
        () => runtime,
        flushNow: () async => calls.add('flushNow'),
        flushReports: () async => calls.add('flushReports'),
        hasUnsentData: () async => false,
      );

      await gateway.prepareForSignOut();
      await gateway.prepareForAccountSwitch();

      expect(runtime.calls, ['quiesce:true']);
      expect(calls, [
        'flushNow',
        'flushReports',
        'flushNow',
        'flushReports',
      ]);
    });

    test('a failing check blocks rather than wipes', () async {
      final gateway = SyncAccountTransitionGateway(
        RecordingRuntimeLifecycle.new,
        hasUnsentData: () async => throw StateError('db'),
      );
      await expectLater(
        gateway.prepareForSignOut(),
        throwsA(isA<AuthGatewayException>()),
      );
    });

    test('a flush that hangs still ends at the limit, then checks', () async {
      var checked = false;
      final gateway = SyncAccountTransitionGateway(
        RecordingRuntimeLifecycle.new,
        signOutFlushLimit: const Duration(milliseconds: 50),
        flushNow: () => Completer<void>().future,
        hasUnsentData: () async => checked = true,
      );
      await expectLater(
        gateway.prepareForSignOut().timeout(const Duration(seconds: 2)),
        throwsA(isA<AuthGatewayException>()),
      );
      expect(checked, isTrue);
    });
  });

  test('account switch and delete leave Sync running', () async {
    final runtime = RecordingRuntimeLifecycle();
    final gateway = SyncAccountTransitionGateway(() => runtime);

    await gateway.prepareForAccountSwitch();
    await gateway.prepareForDeleteAccount();

    expect(runtime.calls, isEmpty);
  });
}

class RecordingRuntimeLifecycle implements SyncRuntimeLifecycle {
  RecordingRuntimeLifecycle({this.failFlush = false, this.hang = false});

  final bool failFlush;
  final bool hang;
  final calls = <String>[];

  @override
  Future<void> quiesce({required bool flush}) async {
    calls.add('quiesce:$flush');
    if (hang) return Completer<void>().future;
    if (flush && failFlush) {
      throw StateError('flush failed');
    }
  }
}
