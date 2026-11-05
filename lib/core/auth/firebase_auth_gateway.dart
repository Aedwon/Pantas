import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/email_link_auth.dart';

class FirebaseAuthGateway
    implements AuthGateway, EmailLinkAuthGateway, GooglePopupAuthGateway {
  FirebaseAuthGateway({firebase.FirebaseAuth? auth, bool web = kIsWeb})
      : _auth = auth ?? firebase.FirebaseAuth.instance,
        _web = web;

  final firebase.FirebaseAuth _auth;
  final bool _web;
  firebase.AuthCredential? _pendingGoogleCredential;

  @override
  AuthSession? get currentSession => _sessionFromUser(_auth.currentUser);

  @override
  Stream<AuthSession?> get authStateChanges {
    final changes = _web ? _auth.idTokenChanges() : _auth.authStateChanges();
    return changes.map(_sessionFromUser);
  }

  @override
  Future<AuthSession> signInAnonymously() async {
    try {
      return _sessionFromCredential(await _auth.signInAnonymously());
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthGatewayException(error.code);
    }
  }

  @override
  Future<AuthSession> linkWithGoogleCredential(GoogleAuthTokens tokens) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthGatewayException('missing-current-user');
    }

    try {
      return _sessionFromCredential(
        await user.linkWithCredential(_googleCredential(tokens)),
      );
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthGatewayException(error.code);
    }
  }

  @override
  Future<AuthSession> signInWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {
    try {
      return _sessionFromCredential(
        await _auth.signInWithCredential(_googleCredential(tokens)),
      );
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthGatewayException(error.code);
    }
  }

  @override
  Future<void> reauthenticateWithGoogleCredential(
    GoogleAuthTokens tokens,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthGatewayException('missing-current-user');
    }

    try {
      await user.reauthenticateWithCredential(_googleCredential(tokens));
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthGatewayException(error.code);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthGatewayException(error.code);
    }
  }

  @override
  bool isSignInLink(String link) => _auth.isSignInWithEmailLink(link);

  @override
  Future<void> sendLink(String email, String continueUrl) async {
    try {
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: firebase.ActionCodeSettings(
          url: continueUrl,
          handleCodeInApp: true,
        ),
      );
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthGatewayException(error.code);
    }
  }

  @override
  Future<void> link(String email, String link) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthGatewayException('missing-current-user');
    try {
      await user.linkWithCredential(
        firebase.EmailAuthProvider.credentialWithLink(
          email: email,
          emailLink: link,
        ),
      );
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthGatewayException(error.code);
    }
  }

  @override
  Future<void> signIn(String email, String link) async {
    try {
      await _auth.signInWithEmailLink(email: email, emailLink: link);
    } on firebase.FirebaseAuthException catch (error) {
      throw AuthGatewayException(error.code);
    }
  }

  @override
  Future<void> googlePopup({required bool link}) async {
    if (link) _pendingGoogleCredential = null;
    try {
      final provider = firebase.GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      if (link) {
        final user = _auth.currentUser;
        if (user == null) {
          throw const AuthGatewayException('missing-current-user');
        }
        await user.linkWithPopup(provider);
      } else {
        final pending = _pendingGoogleCredential;
        _pendingGoogleCredential = null;
        if (pending != null) {
          await _auth.signInWithCredential(pending);
        } else {
          await _auth.signInWithPopup(provider);
        }
      }
    } on firebase.FirebaseAuthException catch (error) {
      if (link && error.code == 'credential-already-in-use') {
        _pendingGoogleCredential = error.credential;
      }
      throw AuthGatewayException(error.code);
    }
  }

  firebase.OAuthCredential _googleCredential(GoogleAuthTokens tokens) {
    return firebase.GoogleAuthProvider.credential(
      idToken: tokens.idToken,
      accessToken: tokens.accessToken,
    );
  }

  AuthSession _sessionFromCredential(firebase.UserCredential credential) {
    final session = _sessionFromUser(credential.user);
    if (session == null) {
      throw const AuthGatewayException('missing-user-credential-result');
    }
    return session;
  }

  AuthSession? _sessionFromUser(firebase.User? user) {
    if (user == null) return null;
    return AuthSession(
      uid: user.uid,
      isAnonymous: user.isAnonymous,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      lastSignInTime: user.metadata.lastSignInTime,
    );
  }
}
