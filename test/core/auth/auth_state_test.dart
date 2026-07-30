import 'package:pantas/core/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AuthState.fromSession maps null to signedOut', () {
    expect(AuthState.fromSession(null), const AuthState.signedOut());
  });

  test('AuthState.fromSession maps anonymous uid to anonymous state', () {
    final state = AuthState.fromSession(
      const AuthSession(uid: 'anon-1', isAnonymous: true),
    );

    expect(state, const AuthState.anonymous(uid: 'anon-1'));
  });

  test('AuthState.fromSession maps named user with pro claim default false',
      () {
    final state = AuthState.fromSession(
      const AuthSession(
        uid: 'user-1',
        email: 'reader@example.com',
        displayName: 'Reader',
        photoUrl: 'https://example.com/photo.png',
      ),
    );

    expect(
      state,
      const AuthState.signedIn(
        user: AuthUser(
          uid: 'user-1',
          email: 'reader@example.com',
          displayName: 'Reader',
          photoUrl: 'https://example.com/photo.png',
        ),
      ),
    );
    expect((state as SignedInAuthState).user.isPro, isFalse);
  });
}
