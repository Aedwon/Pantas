import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';

AuthRepository buildUnavailableAuthRepository() {
  return AuthRepository(
    gateway: const UnavailableAuthGateway(),
    googleGateway: const UnavailableGoogleSignInGateway(),
    functionsGateway: const UnavailableAuthFunctionsGateway(),
  );
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => buildUnavailableAuthRepository(),
);

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authState;
});

final currentUserProvider = FutureProvider<AuthUser?>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  return switch (state) {
    SignedInAuthState(:final user) => user,
    _ => null,
  };
});

final isAnonymousProvider = FutureProvider<bool>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  return state is AnonymousAuthState;
});

final isSignedInProvider = FutureProvider<bool>((ref) async {
  final state = await ref.watch(authStateProvider.future);
  return state is SignedInAuthState;
});

class UnavailableAuthGateway implements AuthGateway {
  const UnavailableAuthGateway();

  Never _unavailable() {
    throw const AuthGatewayException('firebase-unavailable');
  }

  @override
  AuthSession? get currentSession => null;

  @override
  Stream<AuthSession?> get authStateChanges => Stream.value(null);

  @override
  Future<AuthSession> signInAnonymously() async => _unavailable();

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) async =>
      _unavailable();

  @override
  Future<void> reauthenticateWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async =>
      _unavailable();

  @override
  Future<AuthSession> signInWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async =>
      _unavailable();

  @override
  Future<void> signOut() async => _unavailable();
}

class UnavailableGoogleSignInGateway implements GoogleSignInGateway {
  const UnavailableGoogleSignInGateway();

  @override
  Future<GoogleAuthTokens?> signIn() async {
    throw const AuthGatewayException('firebase-unavailable');
  }

  @override
  Future<void> signOut() async {}
}

class UnavailableAuthFunctionsGateway implements AuthFunctionsGateway {
  const UnavailableAuthFunctionsGateway();

  Never _unavailable() {
    throw const AuthGatewayException('firebase-unavailable');
  }

  @override
  Future<void> recordSignInEvent() async => _unavailable();

  @override
  Future<void> deleteAccount() async => _unavailable();

  @override
  Future<Uri> exportData() async => _unavailable();
}
