import 'dart:async';

import 'package:pantas/core/auth/account_transition_gateway.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/email_code_auth.dart';
import 'package:pantas/core/auth/email_link_auth.dart';
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

class AuthRepository implements EmailCodeAuth {
  AuthRepository({
    required AuthGateway gateway,
    GoogleSignInGateway? googleGateway,
    AuthFunctionsGateway? functionsGateway,
    AccountTransitionGateway? accountTransitionGateway,
    LocalStateWiper? localStateWiper,
    Clock? clock,
    EmailLinkAuthGateway? emailLinkGateway,
    EmailLinkStore? emailLinkStore,
    GooglePopupAuthGateway? googlePopupGateway,
    EmailCodeGateway? emailCodeGateway,
    CustomTokenAuthGateway? customTokenGateway,
  })  : _gateway = gateway,
        _googleGateway =
            googleGateway ?? const UnconfiguredGoogleSignInGateway(),
        _functionsGateway =
            functionsGateway ?? const UnconfiguredAuthFunctionsGateway(),
        _accountTransitionGateway =
            accountTransitionGateway ?? const NoopAccountTransitionGateway(),
        _localStateWiper = localStateWiper ?? const NoopLocalStateWiper(),
        _clock = clock ?? DateTime.now,
        _emailLinkGateway = emailLinkGateway,
        _emailLinkStore = emailLinkStore ?? const BrowserEmailLinkStore(),
        _googlePopupGateway = googlePopupGateway,
        _emailCodeGateway = emailCodeGateway,
        _customTokenGateway = customTokenGateway;

  final AuthGateway _gateway;
  final GoogleSignInGateway _googleGateway;
  final AuthFunctionsGateway _functionsGateway;
  final AccountTransitionGateway _accountTransitionGateway;
  final LocalStateWiper _localStateWiper;
  final Clock _clock;
  final EmailLinkAuthGateway? _emailLinkGateway;
  final EmailLinkStore _emailLinkStore;
  final GooglePopupAuthGateway? _googlePopupGateway;
  final EmailCodeGateway? _emailCodeGateway;
  final CustomTokenAuthGateway? _customTokenGateway;

  /// Installed by the payment bootstrap without importing a feature into core.
  Future<void> Function()? beforeIdentityChange;

  AuthSession? get currentSession => _gateway.currentSession;

  Stream<AuthState> get authState {
    return _gateway.authStateChanges.map(AuthState.fromSession);
  }

  Future<void> ensureAnonymous() async {
    if (_gateway.currentSession != null) return;
    await _gateway.signInAnonymously();
  }

  Future<SignInResult> signInWithGoogle() async {
    final popup = _googlePopupGateway;
    if (popup != null) {
      return _signInWithLink(
        () => popup.googlePopup(link: true),
        () => popup.googlePopup(link: false),
      );
    }
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

  String? get pendingEmailLinkEmail => _emailLinkStore.email;

  bool isEmailSignInLink(String link) =>
      _emailLinkGateway?.isSignInLink(link) ?? false;

  void cancelEmailLink() => _emailLinkStore.email = null;

  Future<void> sendEmailLink(String email, String continueUrl) async {
    final gateway = _emailLinkGateway;
    if (gateway == null) {
      throw const AuthGatewayException('firebase-unavailable');
    }
    final normalized = email.trim().toLowerCase();
    await gateway.sendLink(normalized, continueUrl);
    _emailLinkStore.email = normalized;
  }

  Future<SignInResult> completeEmailLink(String link, {String? email}) async {
    final gateway = _emailLinkGateway;
    if (gateway == null) {
      return const SignInResult.failed(reason: 'firebase-unavailable');
    }
    if (!gateway.isSignInLink(link)) {
      cancelEmailLink();
      return const SignInResult.failed(reason: 'invalid-action-code');
    }
    final address = (email ?? _emailLinkStore.email)?.trim().toLowerCase();
    if (address == null || address.isEmpty) {
      return const SignInResult.failed(reason: 'email-required');
    }
    try {
      return await _signInWithLink(
        () => gateway.link(address, link),
        () => gateway.signIn(address, link),
      );
    } finally {
      cancelEmailLink();
    }
  }

  Future<SignInResult> _signInWithLink(
    Future<void> Function() link,
    Future<void> Function() signIn,
  ) async {
    if (_gateway.currentSession?.isAnonymous ?? false) {
      try {
        await link();
        await _functionsGateway.recordSignInEvent();
        return const SignInResult.linkedExisting();
      } on AuthGatewayException catch (error) {
        if (error.code == 'popup-closed-by-user' ||
            error.code == 'cancelled-popup-request') {
          return const SignInResult.cancelled();
        }
        if (error.code != 'credential-already-in-use' &&
            error.code != 'email-already-in-use') {
          return SignInResult.failed(reason: error.code);
        }
      }
    }
    return _switchAccount(signIn);
  }

  /// Leaves the current account and signs in as another one.
  Future<SignInResult> _switchAccount(Future<void> Function() signIn) async {
    _identityEpoch++;
    await _accountTransitionGateway.prepareForAccountSwitch();
    await beforeIdentityChange?.call();
    try {
      if (_gateway.currentSession != null) await _gateway.signOut();
      await signIn();
      await _functionsGateway.recordSignInEvent();
      return const SignInResult.switchedToExisting();
    } on AuthGatewayException catch (error) {
      await ensureAnonymous();
      if (error.code == 'popup-closed-by-user' ||
          error.code == 'cancelled-popup-request') {
        return const SignInResult.cancelled();
      }
      return SignInResult.failed(reason: error.code);
    }
  }

  @override
  Future<EmailCodeRequest> requestCode(String email) {
    final gateway = _emailCodeGateway;
    if (gateway == null) {
      throw const EmailCodeException(EmailCodeFailure.unavailable);
    }
    return gateway.requestCode(email.trim().toLowerCase());
  }

  // Bumped by every identity change this repository makes and by
  // [cancelVerification]. A code check that began under an older value must
  // not sign anyone in when its token comes back.
  int _identityEpoch = 0;
  Future<void> _verifyTail = Future<void>.value();

  @override
  void cancelVerification() => _identityEpoch++;

  @override
  Future<SignInResult> verifyCode(String challengeId, String code) async {
    final gateway = _emailCodeGateway;
    final signIn = _customTokenGateway;
    if (gateway == null || signIn == null) {
      throw const EmailCodeException(EmailCodeFailure.unavailable);
    }
    // One check at a time. A check cancelled while it waits its turn is
    // discarded when the turn comes.
    final epoch = _identityEpoch;
    final previous = _verifyTail;
    final turn = Completer<void>();
    _verifyTail = turn.future;
    try {
      await previous;
      if (epoch != _identityEpoch) return const SignInResult.cancelled();
      final uidBefore = _gateway.currentSession?.uid;
      final token = await gateway.verifyCode(challengeId, code);
      // The server answered for the user who asked. If that user is gone, or
      // the flow was cancelled, the token is not for the current user: drop it.
      final session = _gateway.currentSession;
      if (epoch != _identityEpoch || session?.uid != uidBefore) {
        return const SignInResult.cancelled();
      }
      Future<void> signInWithToken() => signIn.signInWithCustomToken(token);
      // The server upgrades an anonymous caller in place when the email is
      // new. The token then names the caller's own uid, and its progress stays.
      if (session != null && customTokenUid(token) == session.uid) {
        try {
          await signInWithToken();
          await _functionsGateway.recordSignInEvent();
          return const SignInResult.linkedExisting();
        } on AuthGatewayException catch (error) {
          return SignInResult.failed(reason: error.code);
        }
      }
      return await _switchAccount(signInWithToken);
    } finally {
      turn.complete();
    }
  }

  Future<void> signOut() async {
    _identityEpoch++;
    cancelEmailLink();
    await _accountTransitionGateway.prepareForSignOut();
    await beforeIdentityChange?.call();
    await _localStateWiper.wipeAll();
    await _gateway.signOut();
    await _signOutGoogleBestEffort();
    await ensureAnonymous();
  }

  Future<Uri> exportData() {
    return _functionsGateway.exportData();
  }

  Future<void> deleteAccount() async {
    _identityEpoch++;
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
    await beforeIdentityChange?.call();
    await _localStateWiper.wipeAll();
    await _gateway.signOut();
    await _signOutGoogleBestEffort();
    await ensureAnonymous();
  }

  Future<SignInResult> _switchToExistingGoogleAccount(
    GoogleAuthTokens tokens,
  ) async {
    _identityEpoch++;
    await _accountTransitionGateway.prepareForAccountSwitch();
    await beforeIdentityChange?.call();
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

  Future<void> _signOutGoogleBestEffort() async {
    if (_googlePopupGateway != null) return;
    try {
      await _googleGateway.signOut();
    } catch (_) {
      // Firebase sign-out already succeeded. Google cleanup must not prevent
      // the app from returning to a usable anonymous session.
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
