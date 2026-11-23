import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/runtime/sync_account_transition_gateway.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

void main() {
  test('sign-out sends Sync, then reports, and does not stop Sync itself',
      () async {
    final runtime = RecordingRuntimeLifecycle();
    final calls = <String>[];
    final gateway = SyncAccountTransitionGateway(
      () => runtime,
      flushNow: () async => calls.add('flushNow'),
      flushReports: () async => calls.add('flushReports'),
    );

    await gateway.prepareForSignOut();

    expect(calls, ['flushNow', 'flushReports']);
    expect(runtime.calls, isEmpty, reason: 'the repository stops Sync');
  });

  test('an account switch sends the same way', () async {
    final calls = <String>[];
    final gateway = SyncAccountTransitionGateway(
      RecordingRuntimeLifecycle.new,
      flushNow: () async => calls.add('flushNow'),
      flushReports: () async => calls.add('flushReports'),
    );

    await gateway.prepareForAccountSwitch();

    expect(calls, ['flushNow', 'flushReports']);
  });

  test('a failing send never stops sign-out or a switch', () async {
    final gateway = SyncAccountTransitionGateway(
      RecordingRuntimeLifecycle.new,
      flushNow: () async => throw StateError('offline'),
      flushReports: () async => throw StateError('offline'),
    );
    await gateway.prepareForSignOut();
    await gateway.prepareForAccountSwitch();
  });

  test('a send that hangs (offline) delays sign-out only to the limit',
      () async {
    final gateway = SyncAccountTransitionGateway(
      RecordingRuntimeLifecycle.new,
      signOutFlushLimit: const Duration(milliseconds: 50),
      flushNow: () => Completer<void>().future,
      flushReports: () => Completer<void>().future,
    );

    await gateway.prepareForSignOut().timeout(const Duration(seconds: 1));
    await gateway.prepareForAccountSwitch().timeout(const Duration(seconds: 1));
  });

  test('it sends again until nothing is left, then stops', () async {
    var left = 3;
    var flushes = 0;
    final gateway = SyncAccountTransitionGateway(
      RecordingRuntimeLifecycle.new,
      flushNow: () async {
        flushes++;
        left--;
      },
      hasUnsentData: () async => left > 0,
    );

    await gateway.prepareForSignOut();

    expect(flushes, 3);
  });

  test('it stops sending at the limit even if something is still unsent',
      () async {
    var flushes = 0;
    final gateway = SyncAccountTransitionGateway(
      RecordingRuntimeLifecycle.new,
      signOutFlushLimit: const Duration(milliseconds: 250),
      flushNow: () async => flushes++,
      hasUnsentData: () async => true,
    );

    await gateway.prepareForSignOut().timeout(const Duration(seconds: 2));

    expect(flushes, greaterThan(1));
  });

  test('delete leaves Sync running', () async {
    final runtime = RecordingRuntimeLifecycle();
    final gateway = SyncAccountTransitionGateway(() => runtime);

    await gateway.prepareForDeleteAccount();

    expect(runtime.calls, isEmpty);
  });
}

class RecordingRuntimeLifecycle implements SyncRuntimeLifecycle {
  final calls = <String>[];

  @override
  Future<void> quiesce({required bool flush}) async {
    calls.add('quiesce:$flush');
  }
}
