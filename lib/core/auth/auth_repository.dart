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

/// Google returned a verified address that already belongs to a Pantas account
/// with no Google link, so Firebase refused to link or sign in.
///
/// [idToken] is Google's proof for that address. It stays in memory, is only
/// handed to [GoogleAccountExchangeGateway.exchange], and is never in the
/// exception text.
class GoogleAccountExistsException extends AuthGatewayException {
  const GoogleAccountExistsException(this.idToken)
      : super('google-account-exists');

  final String idToken;
}

/// Trades Google's proof of an address for a custom token for the existing
/// account. The server checks the proof and links Google to that account.
// Single-method interface keeps the callable injectable.
// ignore: one_member_abstracts
abstract interface class GoogleAccountExchangeGateway {
  Future<String> exchange(String idToken);
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
    GoogleAccountExchangeGateway? googleExchangeGateway,
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
        _customTokenGateway = customTokenGateway,
        _googleExchangeGateway = googleExchangeGateway;

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
  final GoogleAccountExchangeGateway? _googleExchangeGateway;

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

  // Bumped when an identity change is requested and when a code sign-in
  // completes, and by [cancelVerification]. A code check that began under an
  // older value must not sign anyone in when its token comes back.
  int _identityEpoch = 0;

  // Every change of identity runs one at a time, in the order it was asked.
  Future<void> _identityTail = Future<void>.value();

  Future<T> _exclusive<T>(Future<T> Function() action) async {
    final previous = _identityTail;
    final turn = Completer<void>();
    _identityTail = turn.future;
    try {
      await previous;
      return await action();
    } finally {
      turn.complete();
    }
  }

  Future<SignInResult> signInWithGoogle() {
    final epoch = ++_identityEpoch;
    return _exclusive(() => _signInWithGoogle(epoch));
  }

  Future<SignInResult> _signInWithGoogle(int epoch) async {
    final popup = _googlePopupGateway;
    if (popup != null) {
      return _signInWithLink(
        () => popup.googlePopup(link: true),
        () => popup.googlePopup(link: false),
        epoch,
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
    final epoch = ++_identityEpoch;
    try {
      return await _exclusive(
        () => _signInWithLink(
          () => gateway.link(address, link),
          () => gateway.signIn(address, link),
          epoch,
        ),
      );
    } finally {
      cancelEmailLink();
    }
  }

  Future<SignInResult> _signInWithLink(
    Future<void> Function() link,
    Future<void> Function() signIn,
    int epoch,
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
        if (error is GoogleAccountExistsException) {
          return _signInToExistingGoogleAddress(error.idToken, epoch);
        }
        if (error.code != 'credential-already-in-use' &&
            error.code != 'email-already-in-use') {
          return SignInResult.failed(reason: error.code);
        }
      }
    }
    return _switchAccount(signIn);
  }

  /// Signs in to the account that already has the address Google proved.
  ///
  /// The server call needs the signed-in (anonymous) caller, so it runs before
  /// the switch. If it fails nothing has changed and the anonymous session
  /// stays usable. The switch then follows the email code path and records the
  /// sign-in event. There is no second Google pop-up.
  ///
  /// [epoch] is the identity epoch this operation was asked under. The call
  /// can take a while, so the result is used only if the flow was not
  /// cancelled and the same user is still signed in, exactly as for the email
  /// code. Otherwise the token is dropped before anything is touched.
  Future<SignInResult> _signInToExistingGoogleAddress(
    String idToken,
    int epoch,
  ) async {
    final exchange = _googleExchangeGateway;
    final signIn = _customTokenGateway;
    if (exchange == null || signIn == null) {
      return const SignInResult.failed(reason: 'firebase-unavailable');
    }
    final uidBefore = _gateway.currentSession?.uid;
    final String token;
    try {
      token = await exchange.exchange(idToken);
    } on AuthGatewayException catch (error) {
      return SignInResult.failed(reason: error.code);
    }

    bool wanted({required bool signedOut}) {
      if (epoch != _identityEpoch) return false;
      final uid = _gateway.currentSession?.uid;
      return uid == uidBefore || (signedOut && uid == null);
    }

    if (!wanted(signedOut: false)) return const SignInResult.cancelled();

    final target = customTokenUid(token);
    Future<bool> undoIfCancelled() => _undoIfCancelled(
          epoch: epoch,
          uidBefore: uidBefore,
          target: target,
        );

    return _switchAccount(
      () => signIn.signInWithCustomToken(token),
      valid: wanted,
      undoIfCancelled: undoIfCancelled,
    );
  }

  /// Whether the flow was cancelled while a custom token was being exchanged.
  ///
  /// The exchange then leaves the cancelled account signed in: undo it, but
  /// only if the signed-in user is the one this exchange installed. A user
  /// who is not that account is left alone.
  Future<bool> _undoIfCancelled({
    required int epoch,
    required String? uidBefore,
    required String? target,
  }) async {
    if (epoch == _identityEpoch) return false;
    final uid = _gateway.currentSession?.uid;
    final installed =
        uid != null && uid != uidBefore && (target == null || uid == target);
    if (installed) {
      try {
        await _gateway.signOut();
        await ensureAnonymous();
      } on AuthGatewayException {
        // Best effort: the caller still learns the flow was cancelled.
      }
    }
    return true;
  }

  /// Leaves the current account and signs in as another one.
  ///
  /// [valid] says whether the change is still wanted. It is asked after each
  /// step that waits, and `signedOut` is true once this call has signed the
  /// old account out. If it says no, nothing more is touched and the session
  /// is returned to an anonymous one if this call had ended the old one.
  ///
  /// [undoIfCancelled] runs right after [signIn] and before the sign-in event
  /// is recorded. If it returns true, the flow was cancelled during the
  /// exchange and it has already undone it.
  Future<SignInResult> _switchAccount(
    Future<void> Function() signIn, {
    bool Function({required bool signedOut})? valid,
    Future<bool> Function()? undoIfCancelled,
  }) async {
    bool wanted({required bool signedOut}) =>
        valid?.call(signedOut: signedOut) ?? true;
    await _accountTransitionGateway.prepareForAccountSwitch();
    if (!wanted(signedOut: false)) return const SignInResult.cancelled();
    await beforeIdentityChange?.call();
    if (!wanted(signedOut: false)) return const SignInResult.cancelled();
    try {
      if (_gateway.currentSession != null) await _gateway.signOut();
      if (!wanted(signedOut: true)) {
        await ensureAnonymous();
        return const SignInResult.cancelled();
      }
      await signIn();
      if (await (undoIfCancelled?.call() ?? Future.value(false))) {
        return const SignInResult.cancelled();
      }
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
      // The token is for the user who asked. The sign-in waits its turn behind
      // any other change of identity, and re-checks, before every step that
      // touches auth, that the same user is still here and the flow was not
      // cancelled. If not, the token is dropped.
      return await _exclusive(() async {
        bool wanted({required bool signedOut}) {
          if (epoch != _identityEpoch) return false;
          final uid = _gateway.currentSession?.uid;
          return uid == uidBefore || (signedOut && uid == null);
        }

        if (!wanted(signedOut: false)) return const SignInResult.cancelled();

        final target = customTokenUid(token);
        Future<bool> undoIfCancelled() => _undoIfCancelled(
              epoch: epoch,
              uidBefore: uidBefore,
              target: target,
            );

        Future<void> signInWithToken() => signIn.signInWithCustomToken(token);
        final session = _gateway.currentSession;
        SignInResult result;
        if (session != null && customTokenUid(token) == session.uid) {
          // A token for the user already signed in: no switch is needed.
          try {
            await signInWithToken();
            if (await undoIfCancelled()) return const SignInResult.cancelled();
            await _functionsGateway.recordSignInEvent();
            result = const SignInResult.linkedExisting();
          } on AuthGatewayException catch (error) {
            return SignInResult.failed(reason: error.code);
          }
        } else {
          result = await _switchAccount(
            signInWithToken,
            valid: wanted,
            undoIfCancelled: undoIfCancelled,
          );
        }
        // Checks that started before this sign-in belong to the old user.
        if (result is! FailedSignInResult && result is! CancelledSignInResult) {
          _identityEpoch++;
        }
        return result;
      });
    } finally {
      turn.complete();
    }
  }

  Future<void> signOut() {
    _identityEpoch++;
    return _exclusive(_signOut);
  }

  Future<void> _signOut() async {
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

  Future<void> deleteAccount() {
    _identityEpoch++;
    return _exclusive(_deleteAccount);
  }

  Future<void> _deleteAccount() async {
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
