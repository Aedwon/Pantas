import 'package:cse_cet_reviewer/core/auth/auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.uid,
    this.isAnonymous = false,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isPro = false,
    this.lastSignInTime,
  });

  final String uid;
  final bool isAnonymous;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isPro;
  final DateTime? lastSignInTime;
}

sealed class AuthState {
  const AuthState();

  static const unknown = UnknownAuthState();

  const factory AuthState.anonymous({required String uid}) = AnonymousAuthState;

  const factory AuthState.signedIn({required AuthUser user}) =
      SignedInAuthState;

  const factory AuthState.signedOut() = SignedOutAuthState;

  static AuthState fromSession(AuthSession? session) {
    if (session == null) return const AuthState.signedOut();
    if (session.isAnonymous) {
      return AuthState.anonymous(uid: session.uid);
    }
    return AuthState.signedIn(
      user: AuthUser(
        uid: session.uid,
        email: session.email ?? '',
        displayName: session.displayName ?? '',
        photoUrl: session.photoUrl,
        isPro: session.isPro,
      ),
    );
  }
}

class UnknownAuthState extends AuthState {
  const UnknownAuthState();

  @override
  bool operator ==(Object other) => other is UnknownAuthState;

  @override
  int get hashCode => Object.hash(UnknownAuthState, 0);
}

class AnonymousAuthState extends AuthState {
  const AnonymousAuthState({required this.uid});

  final String uid;

  @override
  bool operator ==(Object other) {
    return other is AnonymousAuthState && other.uid == uid;
  }

  @override
  int get hashCode => Object.hash(AnonymousAuthState, uid);
}

class SignedInAuthState extends AuthState {
  const SignedInAuthState({required this.user});

  final AuthUser user;

  @override
  bool operator ==(Object other) {
    return other is SignedInAuthState && other.user == user;
  }

  @override
  int get hashCode => Object.hash(SignedInAuthState, user);
}

class SignedOutAuthState extends AuthState {
  const SignedOutAuthState();

  @override
  bool operator ==(Object other) => other is SignedOutAuthState;

  @override
  int get hashCode => Object.hash(SignedOutAuthState, 0);
}
