import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/email_code_auth.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';

import '../../helpers/child_setup_harness.dart';

void main() {
  late MockAuthRepository auth;
  late ChildSessionStarter starter;

  setUp(() {
    auth = MockAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(auth)],
    );
    addTearDown(container.dispose);
    starter = container.read(childSessionStarterProvider);
  });

  test('erases holder state and restores the child before setup continues',
      () async {
    const holder = AuthSession(uid: 'holder');
    const child = AuthSession(uid: 'child');
    AuthSession? session = holder;
    final calls = <String>[];
    final gateway = _AuthGateway();
    final tokenGateway = _TokenGateway();
    when(() => gateway.currentSession).thenAnswer((_) => session);
    when(gateway.signOut).thenAnswer((_) async {
      calls.add('sign out holder');
      session = null;
    });
    when(() => tokenGateway.signInWithCustomToken('token')).thenAnswer(
      (_) async {
        calls.add('sign in child');
        session = child;
      },
    );
    final repository = AuthRepository(
      gateway: gateway,
      customTokenGateway: tokenGateway,
      readAgeGroup: (session) async => session == child ? 'child' : 'adult',
      eraseHolderState: () async => calls.add('erase holder'),
      restoreDeviceState: (session, group) async {
        expect(session, child);
        expect(group, 'child');
        calls.add('restore child device state');
      },
      completeGuardianSetup: () async => calls.add('complete setup'),
    );
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(childSessionStarterProvider).start(
          childUid: child.uid,
          customToken: 'token',
        );

    expect(repository.currentSession, child);
    expect(calls, [
      'erase holder',
      'sign out holder',
      'sign in child',
      'restore child device state',
      'complete setup',
    ]);
  });

  test('does not continue setup after a failed transition', () async {
    when(() => auth.startChildSession('token')).thenAnswer(
      (_) async => const SignInResult.failed(reason: 'missing-child-claim'),
    );
    await expectLater(
      starter.start(childUid: 'child', customToken: 'token'),
      throwsA(isA<AuthGatewayException>()),
    );
  });

  test('does not continue setup after a canceled transition', () async {
    when(() => auth.startChildSession('token')).thenAnswer(
      (_) async => const SignInResult.cancelled(),
    );
    await expectLater(
      starter.start(childUid: 'child', customToken: 'token'),
      throwsA(isA<AuthGatewayException>()),
    );
  });
}

class _AuthGateway extends Mock implements AuthGateway {}

class _TokenGateway extends Mock implements CustomTokenAuthGateway {}
