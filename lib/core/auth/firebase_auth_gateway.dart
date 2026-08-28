import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway({firebase.FirebaseAuth? auth})
      : _auth = auth ?? firebase.FirebaseAuth.instance;

  final firebase.FirebaseAuth _auth;

  @override
  AuthSession? get currentSession => _sessionFromUser(_auth.currentUser);

  @override
  Stream<AuthSession?> get authStateChanges {
    return _auth.authStateChanges().map(_sessionFromUser);
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
  Future<AuthSession> signInWithGoogleCredential(GoogleAuthTokens tokens) async {
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
      isPro: false,
      lastSignInTime: user.metadata.lastSignInTime,
    );
  }
}
