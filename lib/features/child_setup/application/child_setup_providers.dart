import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/features/child_setup/data/child_setup_gateway.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _AuthChildSessionStarter implements ChildSessionStarter {
  const _AuthChildSessionStarter(this._auth);

  final AuthRepository _auth;

  @override
  Future<void> start({
    required String childUid,
    required String customToken,
  }) async {
    final result = await _auth.startChildSession(customToken);
    switch (result) {
      case SwitchedToExistingSignInResult():
        if (_auth.currentSession?.uid != childUid) {
          throw const AuthGatewayException('unexpected-child-session');
        }
        return;
      case FailedSignInResult(:final reason):
        throw AuthGatewayException(reason);
      case CancelledSignInResult() || LinkedExistingSignInResult():
        throw const AuthGatewayException('child-session-not-started');
    }
  }
}

final childSessionStarterProvider = Provider<ChildSessionStarter>(
  (ref) => _AuthChildSessionStarter(ref.watch(authRepositoryProvider)),
);

/// Set when the server reports child setup closed. The under-13 screen then
/// stays and drops its guardian button (Decision 9 item 9).
final childSetupClosedProvider = StateProvider<bool>((ref) => false);

/// The child just created, for the nickname step. Holds a uid only, never
/// parent details.
final pendingChildIdProvider = StateProvider<String?>((ref) => null);

/// Opens the mail app addressed to the data protection officer. Tests replace
/// it. No mail app is not a failure these screens can fix.
typedef DpoMailOpener = Future<void> Function(String email);

final dpoMailOpenerProvider = Provider<DpoMailOpener>(
  (ref) => (email) async {
    try {
      await launchUrl(
        Uri(scheme: 'mailto', path: email),
        mode: LaunchMode.externalApplication,
      );
    } on Object {
      // The address stays on screen to copy.
    }
  },
);
