import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/sync/runtime/sync_runtime_controller.dart';

class SyncAccountTransitionGateway implements AccountTransitionGateway {
  const SyncAccountTransitionGateway(this._runtime);

  final SyncRuntimeLifecycle _runtime;

  @override
  Future<void> prepareForSignOut() => _runtime.quiesce(flush: true);

  @override
  Future<void> prepareForAccountSwitch() => _runtime.quiesce(flush: false);

  @override
  Future<void> prepareForDeleteAccount() => _runtime.quiesce(flush: false);
}
