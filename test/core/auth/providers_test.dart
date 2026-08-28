import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';

void main() {
  test('authRepositoryProvider is non-throwing and signed out by default',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(authRepositoryProvider), isA<AuthRepository>());
    expect(
      await container.read(authStateProvider.future),
      const AuthState.signedOut(),
    );
  });

  test('currentUserProvider returns null for unknown and signedOut', () async {
    final unknownContainer = ProviderContainer(
      overrides: [
        authStateProvider
            .overrideWith((ref) => Stream.value(AuthState.unknown)),
      ],
    );
    addTearDown(unknownContainer.dispose);

    expect(await unknownContainer.read(currentUserProvider.future), isNull);

    final signedOutContainer = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AuthState.signedOut()),
        ),
      ],
    );
    addTearDown(signedOutContainer.dispose);

    expect(await signedOutContainer.read(currentUserProvider.future), isNull);
  });

  test('isSignedInProvider is true only for named users', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => Stream.value(
            const AuthState.signedIn(
              user: AuthUser(
                uid: 'user-1',
                email: 'reader@example.com',
                displayName: 'Reader',
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(isSignedInProvider.future), isTrue);
  });

  test('isAnonymousProvider is true only for anonymous users', () async {
    final container = ProviderContainer(
      overrides: [
        authStateProvider.overrideWith(
          (ref) => Stream.value(const AuthState.anonymous(uid: 'anon-1')),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(isAnonymousProvider.future), isTrue);
    expect(await container.read(isSignedInProvider.future), isFalse);
  });
}
