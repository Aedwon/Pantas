import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/email_link_auth.dart';
import 'package:pantas/core/auth/sign_in_result.dart';

class _Auth extends Mock implements AuthGateway {}

class _Email extends Mock implements EmailLinkAuthGateway {}

class _Popup extends Mock implements GooglePopupAuthGateway {}

class _Store implements EmailLinkStore {
  @override
  String? email;
}

void main() {
  late _Auth auth;
  late _Email email;
  late _Store store;
  late AuthRepository repository;
  setUp(() {
    auth = _Auth();
    email = _Email();
    store = _Store();
    repository = AuthRepository(
      gateway: auth,
      emailLinkGateway: email,
      emailLinkStore: store,
    );
    when(() => auth.currentSession).thenReturn(
      const AuthSession(uid: 'anon', isAnonymous: true),
    );
    when(() => email.isSignInLink(any())).thenReturn(true);
  });

  test('web Google links the session without native authentication', () async {
    final popup = _Popup();
    when(() => popup.googlePopup(link: true)).thenAnswer((_) async {});
    final repository = AuthRepository(gateway: auth, googlePopupGateway: popup);
    expect(
      await repository.signInWithGoogle(),
      const SignInResult.linkedExisting(),
    );
    verify(() => popup.googlePopup(link: true)).called(1);
    verifyNever(() => popup.googlePopup(link: false));
  });

  test('sending normalizes and remembers email only after success', () async {
    when(() => email.sendLink(any(), any())).thenAnswer((_) async {});
    await repository.sendEmailLink(
      ' Tester@Example.COM ',
      'https://app.test/auth/email-link',
    );
    expect(store.email, 'tester@example.com');
    verify(
      () => email.sendLink(
        'tester@example.com',
        'https://app.test/auth/email-link',
      ),
    ).called(1);
  });

  test('same-device completion links progress and clears saved email',
      () async {
    store.email = 'tester@example.com';
    when(() => email.link('tester@example.com', 'link'))
        .thenAnswer((_) async {});
    expect(
      await repository.completeEmailLink('link'),
      const SignInResult.linkedExisting(),
    );
    expect(store.email, isNull);
    verifyNever(() => auth.signOut());
  });

  test('another device requires the email to complete the link', () async {
    expect(
      await repository.completeEmailLink('link'),
      const SignInResult.failed(reason: 'email-required'),
    );
    verifyNever(() => email.link(any(), any()));
    when(() => email.link('tester@example.com', 'link'))
        .thenAnswer((_) async {});
    expect(
      await repository.completeEmailLink('link', email: 'Tester@Example.COM'),
      const SignInResult.linkedExisting(),
    );
  });

  test('collision switches identity without wiping local progress', () async {
    when(() => email.link(any(), any())).thenThrow(
      const AuthGatewayException('credential-already-in-use'),
    );
    when(() => auth.signOut()).thenAnswer((_) async {});
    when(() => email.signIn(any(), any())).thenAnswer((_) async {});
    expect(
      await repository.completeEmailLink('link', email: 'tester@example.com'),
      const SignInResult.switchedToExisting(),
    );
    verifyInOrder([
      () => email.link('tester@example.com', 'link'),
      () => auth.signOut(),
      () => email.signIn('tester@example.com', 'link'),
    ]);
  });

  test('expired link reports failure and clears saved email', () async {
    store.email = 'tester@example.com';
    when(() => email.link(any(), any())).thenThrow(
      const AuthGatewayException('expired-action-code'),
    );
    expect(
      await repository.completeEmailLink('link'),
      const SignInResult.failed(reason: 'expired-action-code'),
    );
    expect(store.email, isNull);
  });
}
