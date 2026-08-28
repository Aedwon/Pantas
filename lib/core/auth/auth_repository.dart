import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/sign_in_result.dart';

typedef Clock = DateTime Function();

class GoogleAuthTokens {
  const GoogleAuthTokens({this.idToken, this.accessToken});

  final String? idToken;
  final String? accessToken;
}

class AuthGatewayException implements Exception {
  const AuthGatewayException(this.code);

  final String code;
}

abstract interface class AuthGateway {
  AuthSession? get currentSession;

  Stream<AuthSession?> get authStateChanges;

  Future<AuthSession> signInAnonymously();

  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens);

  Future<AuthSession> signInWithGoogleCredential(GoogleAuthTokens tokens);

  Future<void> reauthenticateWithGoogleCredential(GoogleAuthTokens tokens);

  Future<void> signOut();
}

class AuthRepository {
  AuthRepository({
    required AuthGateway gateway,
    GoogleSignInGateway? googleGateway,
    AuthFunctionsGateway? functionsGateway,
    AccountTransitionGateway? accountTransitionGateway,
    LocalStateWiper? localStateWiper,
    Clock? clock,
  })  : _gateway = gateway,
        _googleGateway =
            googleGateway ?? const UnconfiguredGoogleSignInGateway(),
        _functionsGateway =
            functionsGateway ?? const UnconfiguredAuthFunctionsGateway(),
        _accountTransitionGateway =
            accountTransitionGateway ?? const NoopAccountTransitionGateway(),
        _localStateWiper = localStateWiper ?? const NoopLocalStateWiper(),
        _clock = clock ?? DateTime.now;

  final AuthGateway _gateway;
  final GoogleSignInGateway _googleGateway;
  final AuthFunctionsGateway _functionsGateway;
  final AccountTransitionGateway _accountTransitionGateway;
  final LocalStateWiper _localStateWiper;
  final Clock _clock;

  Stream<AuthState> get authState {
    return _gateway.authStateChanges.map(AuthState.fromSession);
  }

  Future<void> ensureAnonymous() async {
    if (_gateway.currentSession != null) return;
    await _gateway.signInAnonymously();
  }

  Future<SignInResult> signInWithGoogle() async {
    final tokens = await _googleGateway.signIn();
    if (tokens == null) return const SignInResult.cancelled();

    try {
      await _gateway.linkWithGoogleCredential(tokens);
      await _functionsGateway.recordSignInEvent();
      return const SignInResult.linkedExisting();
    } on AuthGatewayException catch (error) {
      if (error.code != 'credential-already-in-use') {
        return SignInResult.failed(reason: error.code);
      }
      return _switchToExistingGoogleAccount(tokens);
    }
  }

  Future<void> signOut() async {
    await _accountTransitionGateway.prepareForSignOut();
    await _localStateWiper.wipeAll();
    await _gateway.signOut();
    await _googleGateway.signOut();
    await ensureAnonymous();
  }

  Future<Uri> exportData() {
    return _functionsGateway.exportData();
  }

  Future<void> deleteAccount() async {
    final session = _gateway.currentSession;
    final lastSignInTime = session?.lastSignInTime;
    if (lastSignInTime == null ||
        _clock().difference(lastSignInTime) > const Duration(minutes: 5)) {
      final tokens = await _googleGateway.signIn();
      if (tokens == null) {
        throw const AuthGatewayException('requires-recent-login');
      }
      await _gateway.reauthenticateWithGoogleCredential(tokens);
    }

    await _accountTransitionGateway.prepareForDeleteAccount();
    await _functionsGateway.deleteAccount();
    await _localStateWiper.wipeAll();
    await _gateway.signOut();
    await _googleGateway.signOut();
    await ensureAnonymous();
  }

  Future<SignInResult> _switchToExistingGoogleAccount(
    GoogleAuthTokens tokens,
  ) async {
    await _accountTransitionGateway.prepareForAccountSwitch();
    try {
      await _gateway.signOut();
      await _gateway.signInWithGoogleCredential(tokens);
      await _functionsGateway.recordSignInEvent();
      return const SignInResult.switchedToExisting();
    } on AuthGatewayException catch (error) {
      await ensureAnonymous();
      return SignInResult.failed(reason: error.code);
    }
  }
}

abstract interface class GoogleSignInGateway {
  Future<GoogleAuthTokens?> signIn();

  Future<void> signOut();
}

abstract interface class AuthFunctionsGateway {
  Future<void> recordSignInEvent();

  Future<Uri> exportData();

  Future<void> deleteAccount();
}

abstract interface class LocalStateWiper {
  Future<bool> hasMeaningfulProgress();

  Future<void> wipeAll();
}

// Temporary compatibility declaration for Sync. AuthRepository does not use it.
// Wave 2E owns relocating this interface into the Sync domain.
// ignore: one_member_abstracts
abstract interface class CloudProgressGateway {
  Future<bool> hasMeaningfulProgress(String uid);
}

class UnconfiguredGoogleSignInGateway implements GoogleSignInGateway {
  const UnconfiguredGoogleSignInGateway();

  @override
  Future<GoogleAuthTokens?> signIn() async => null;

  @override
  Future<void> signOut() async {}
}

class UnconfiguredAuthFunctionsGateway implements AuthFunctionsGateway {
  const UnconfiguredAuthFunctionsGateway();

  @override
  Future<void> recordSignInEvent() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<Uri> exportData() async {
    throw StateError('exportData callable is not configured');
  }
}

class NoopLocalStateWiper implements LocalStateWiper {
  const NoopLocalStateWiper();

  @override
  Future<bool> hasMeaningfulProgress() async => false;

  @override
  Future<void> wipeAll() async {}
}

class EmptyCloudProgressGateway implements CloudProgressGateway {
  const EmptyCloudProgressGateway();

  @override
  Future<bool> hasMeaningfulProgress(String uid) async => false;
}
