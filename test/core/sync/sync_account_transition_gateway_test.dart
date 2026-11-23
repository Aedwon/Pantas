import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
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
