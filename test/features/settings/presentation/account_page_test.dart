import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/pages/backup_page.dart';

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

  testWidgets('the phone Continue with Google button carries the Google G',
      (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: null,
    );
    final button = find.ancestor(
      of: find.text('Continue with Google'),
      matching: find.byType(TextButton),
    );
    expect(
      find.descendant(of: button.first, matching: find.byType(SvgPicture)),
      findsOneWidget,
    );
  });

  testWidgets('on the web a phone-size window still says browser, not phone',
      (tester) async {
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: null,
      web: true,
    );
    expect(
      find.text(
        'Your progress stays in this browser. Signing in gives you an '
        'account you can come back to.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('this phone'), findsNothing);
    expect(find.text('Continue with Email'), findsOneWidget);
  });

  testWidgets('email accounts show their email on web', (tester) async {
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: const AuthUser(
        uid: 'email-user',
        email: 'tester@example.com',
        displayName: '',
      ),
      web: true,
    );
    // The account header and the Email row both show it.
    expect(find.text('tester@example.com'), findsWidgets);
    expect(find.text('Google'), findsNothing);
  });

  testWidgets('web shows Backup with the browser copy on Free', (tester) async {
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: const AuthUser(
        uid: 'user-1',
        email: 'reader@example.com',
        displayName: 'Reader',
      ),
      web: true,
    );
    expect(find.text('This browser only'), findsOneWidget);
    expect(find.text(webFreeBackupNote), findsOneWidget);
    expect(find.text('Back Up with Pro'), findsNothing);
    expect(find.textContaining('this phone'), findsNothing);
  });

  testWidgets('web shows Backup status and Details for Pro', (tester) async {
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: const AuthUser(
        uid: 'user-1',
        email: 'reader@example.com',
        displayName: 'Reader',
      ),
      web: true,
      extra: [
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.monthly)),
        ),
        syncStatusProvider
            .overrideWith((ref) => Stream.value(const SyncUpToDate())),
      ],
    );
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
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

  const reader = AuthUser(
    uid: 'user-1',
    email: 'reader@example.com',
    displayName: 'Reader',
  );
  final pro = entitlementProvider.overrideWith(
    (ref) => Stream.value(const Entitlement(plan: EntitlementPlan.monthly)),
  );

  testWidgets('the Pro sign-out dialog says progress is saved, plainly',
      (tester) async {
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: reader,
      extra: [pro],
    );

    await tester.ensureVisible(find.text('Sign Out'));
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your progress is saved to your account.'),
      findsOneWidget,
    );
    expect(find.textContaining('comes back'), findsNothing);
    expect(_confirm(tester).variant, isNot(PantasButtonVariant.destructive));
  });

  testWidgets('the Free sign-out dialog says what is deleted, and is red',
      (tester) async {
    await _pumpAccount(
      tester,
      repository: SequencedAuthRepository(const []),
      user: reader,
    );

    await tester.ensureVisible(find.text('Sign Out'));
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your study history on this device will be deleted.'),
      findsOneWidget,
    );
    expect(find.textContaining('saved to your account'), findsNothing);
    expect(find.textContaining('comes back'), findsNothing);
    expect(_confirm(tester).variant, PantasButtonVariant.destructive);
  });

  testWidgets('a sign-out blocked by unsent data shows the connection line',
      (tester) async {
    await _pumpAccount(
      tester,
      repository: BlockedSignOutRepository(),
      user: reader,
      extra: [pro],
    );

    await tester.ensureVisible(find.text('Sign Out'));
    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PantasButton, 'Sign Out'));
    await tester.pumpAndSettle();

    expect(find.text('You need a connection to sign out.'), findsOneWidget);
  });
}

Future<void> _pumpAccount(
  WidgetTester tester, {
  required AuthRepository repository,
  required AuthUser? user,
  bool web = false,
  List<Override> extra = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => user),
        authRepositoryProvider.overrideWithValue(repository),
        if (web) paymentsOnWebProvider.overrideWithValue(true),
        ...extra,
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

PantasButton _confirm(WidgetTester tester) => tester.widget<PantasButton>(
      find.descendant(
        of: find.byType(CenteredDialog),
        matching: find.widgetWithText(PantasButton, 'Sign Out'),
      ),
    );

class BlockedSignOutRepository extends SequencedAuthRepository {
  BlockedSignOutRepository() : super(const []);

  @override
  Future<void> signOut() async =>
      throw const AuthGatewayException('network-request-failed');
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
