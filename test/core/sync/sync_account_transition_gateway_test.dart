import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/sync/runtime/sync_account_transition_gateway.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

void main() {
  test('ordinary sign-out quiesces and requires flush', () async {
    final runtime = RecordingRuntimeLifecycle();
    final gateway = SyncAccountTransitionGateway(runtime);

    await gateway.prepareForSignOut();

    expect(runtime.calls, ['quiesce:true']);
  });

  test('sign-out preparation propagates flush failure', () async {
    final runtime = RecordingRuntimeLifecycle(failFlush: true);
    final gateway = SyncAccountTransitionGateway(runtime);

    await expectLater(gateway.prepareForSignOut(), throwsA(isA<StateError>()));

    expect(runtime.calls, ['quiesce:true']);
  });

  test('account switch quiesces without flushing old identity work', () async {
    final runtime = RecordingRuntimeLifecycle();
    final gateway = SyncAccountTransitionGateway(runtime);

    await gateway.prepareForAccountSwitch();

    expect(runtime.calls, ['quiesce:false']);
  });

  test('delete account quiesces without flushing data being deleted', () async {
    final runtime = RecordingRuntimeLifecycle();
    final gateway = SyncAccountTransitionGateway(runtime);

    await gateway.prepareForDeleteAccount();

    expect(runtime.calls, ['quiesce:false']);
  });
}

class RecordingRuntimeLifecycle implements SyncRuntimeLifecycle {
  RecordingRuntimeLifecycle({this.failFlush = false});

  final bool failFlush;
  final calls = <String>[];

  @override
  Future<void> quiesce({required bool flush}) async {
    calls.add('quiesce:$flush');
    if (flush && failFlush) {
      throw StateError('flush failed');
    }
  }
}
