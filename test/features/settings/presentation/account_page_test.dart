import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';

void main() {
  testWidgets('user == null is local-only even without anonymous state',
      (tester) async {
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: null,
    );

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(
      find.text(
        'Your progress stays on this phone. Signing in gives you an '
        'account you can come back to.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('named Free account keeps local-only Pro-aware copy',
      (tester) async {
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: const AuthUser(
        uid: 'user-1',
        email: 'reader@example.com',
        displayName: 'Reader',
      ),
    );

    expect(find.text('Add your name'), findsNWidgets(2));
    expect(
      find.text(
        "Your progress stays on this phone only. With Pro, it's "
        'backed up and syncs across your devices.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('cancelled Google sign-in clears prior error silently',
      (tester) async {
    final repository = SequencedAuthRepository([
      const SignInResult.failed(reason: 'network-request-failed'),
      const SignInResult.cancelled(),
    ]);
    await _pumpAccount(tester, repository: repository, user: null);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text('You need a connection to sign in.'), findsOneWidget);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text('You need a connection to sign in.'), findsNothing);
  });

  testWidgets('switched-to-existing is a successful no-prompt outcome',
      (tester) async {
    final repository = SequencedAuthRepository(
      const [SignInResult.switchedToExisting()],
    );
    await _pumpAccount(tester, repository: repository, user: null);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('You need a connection to sign in.'), findsNothing);
    expect(find.textContaining('merge'), findsNothing);
  });

  testWidgets('sign-out dialog explains account restore', (tester) async {
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: const AuthUser(
        uid: 'user-1',
        email: 'reader@example.com',
        displayName: 'Reader',
      ),
    );

    await tester.ensureVisible(find.text('Sign Out'));
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Your progress is saved to your account. '
        'It comes back when you sign in again.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('restore it'), findsNothing);
  });
}

Future<void> _pumpAccount(
  WidgetTester tester, {
  required AuthRepository repository,
  required AuthUser? user,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => user),
        authRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: buildLightTheme().copyWith(
          splashFactory: InkRipple.splashFactory,
        ),
        home: const AccountPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class SequencedAuthRepository implements AuthRepository {
  SequencedAuthRepository(List<SignInResult> results)
      : _results = List.of(results);

  final List<SignInResult> _results;

  @override
  Future<SignInResult> signInWithGoogle() async {
    if (_results.isEmpty) return const SignInResult.cancelled();
    return _results.removeAt(0);
  }

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
