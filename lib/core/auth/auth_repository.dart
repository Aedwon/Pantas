import 'package:cse_cet_reviewer/core/auth/auth_state.dart';

abstract interface class AuthGateway {
  AuthSession? get currentSession;

  Stream<AuthSession?> get authStateChanges;

  Future<AuthSession> signInAnonymously();
}

class AuthRepository {
  const AuthRepository({required AuthGateway gateway}) : _gateway = gateway;

  final AuthGateway _gateway;

  Stream<AuthState> get authState {
    return _gateway.authStateChanges.map(AuthState.fromSession);
  }

  Future<void> ensureAnonymous() async {
    if (_gateway.currentSession != null) return;
    await _gateway.signInAnonymously();
  }
}
