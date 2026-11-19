import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/features/child_setup/data/child_setup_gateway.dart';

final childSetupGatewayProvider = Provider<ChildSetupGateway>(
  (ref) => const CallableChildSetupGateway(),
);

/// Starts the child's own session once the server has created the child. It
/// signs in with the custom token, drops the parent's session and switches the
/// device to the child.
// Single-method interface is intentional so tests can fake the session.
// ignore: one_member_abstracts
abstract interface class ChildSessionStarter {
  Future<void> start({required String childUid, required String customToken});
}

/// Does nothing yet.
// TODO(T6): the device-state task replaces this with the real session switch
// (sign in with the custom token, drop the parent session, wipe local state,
// isolate the child's records).
class PendingChildSessionStarter implements ChildSessionStarter {
  const PendingChildSessionStarter();

  @override
  Future<void> start({
    required String childUid,
    required String customToken,
  }) async {}
}

final childSessionStarterProvider = Provider<ChildSessionStarter>(
  (ref) => const PendingChildSessionStarter(),
);

/// Set when the server reports child setup closed. The under-13 screen then
/// stays and drops its guardian button (Decision 9 item 9).
final childSetupClosedProvider = StateProvider<bool>((ref) => false);

/// The child just created, for the nickname step. Holds a uid only, never
/// parent details.
final pendingChildIdProvider = StateProvider<String?>((ref) => null);
