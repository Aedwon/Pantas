import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/core/auth/auth_state.dart';

void main() {
  final signedIn = AuthState.fromSession(const AuthSession(uid: 'user-a'));

  test('a signed-in user is sent Home, so no account switch starts there', () {
    expect(emailSignInRedirect(auth: signedIn, holding: false), '/home');
  });

  test('the screen stays while it plays its signed-in beat', () {
    expect(emailSignInRedirect(auth: signedIn, holding: true), isNull);
  });

  test('a guest, a signed-out session or an unknown one opens the screen', () {
    for (final auth in <AuthState?>[
      const AuthState.anonymous(uid: 'guest'),
      const AuthState.signedOut(),
      AuthState.unknown,
      null,
    ]) {
      expect(emailSignInRedirect(auth: auth, holding: false), isNull);
    }
  });
}
