import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/child_setup/application/child_account_closer.dart';
import 'package:pantas/features/child_setup/application/child_setup_providers.dart';
import 'package:pantas/features/child_setup/presentation/parent_delete_link_screen.dart';

import '../../helpers/child_setup_harness.dart';

LinkedChild _child(String uid, String nickname) =>
    (uid: uid, nickname: nickname, siblingOpenWithoutCode: false);

void main() {
  late MockAuthRepository auth;
  late FakeChildSetupGateway gateway;
  var childSession = 0;
  var signIn = 0;
  var anotherEmail = 0;

  setUp(() {
    auth = fakeAuth();
    gateway = FakeChildSetupGateway();
    childSession = 0;
    signIn = 0;
    anotherEmail = 0;
    when(auth.listChildren).thenAnswer(
      (_) async => (
        children: [_child('child-1', 'Kiko'), _child('child-2', 'Bea')],
        maskedHolderEmail: 'p***@example.test',
      ),
    );
  });

  Future<void> pump(WidgetTester tester, AuthState state) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          authStateProvider.overrideWith((ref) => Stream.value(state)),
          childSetupGatewayProvider.overrideWithValue(gateway),
          childAccountCloserProvider
              .overrideWithValue(FakeChildAccountCloser()),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: ParentDeleteLinkScreen(
            childId: 'child-2',
            onChildSession: () => childSession++,
            onSignIn: () => signIn++,
            onUseAnotherEmail: () async => anotherEmail++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets("the child's own session opens the For parents page",
      (tester) async {
    await pump(
      tester,
      const AuthState.signedIn(
        user: AuthUser(uid: 'child-2', email: '', displayName: ''),
      ),
    );
    expect(childSession, 1);
    expect(signIn, 0);
  });

  testWidgets('signed out goes to the parent sign-in', (tester) async {
    await pump(tester, const AuthState.signedOut());
    expect(signIn, 1);
    expect(childSession, 0);
  });

  testWidgets('an anonymous device goes to the parent sign-in', (tester) async {
    await pump(tester, const AuthState.anonymous(uid: 'anon'));
    expect(signIn, 1);
  });

  testWidgets('the parent who holds the child sees the delete confirm',
      (tester) async {
    await pump(
      tester,
      const AuthState.signedIn(
        user: AuthUser(uid: 'holder', email: 'p@example.test', displayName: ''),
      ),
    );
    expect(find.byType(CenteredDialog), findsOneWidget);
    expect(find.text('Delete this account?'), findsOneWidget);
    expect(childSession, 0);
    expect(signIn, 0);
  });

  testWidgets('a parent who does not hold the child is told so',
      (tester) async {
    when(auth.listChildren).thenAnswer(
      (_) async => (
        children: [_child('child-9', 'Zed')],
        maskedHolderEmail: 'p***@example.test',
      ),
    );
    await pump(
      tester,
      const AuthState.signedIn(
        user: AuthUser(uid: 'holder', email: 'p@example.test', displayName: ''),
      ),
    );
    expect(find.byType(CenteredDialog), findsNothing);
    expect(
      find.text(
        'This link is for another account. Sign in with the email that set '
        'up this child.',
      ),
      findsOneWidget,
    );
    expect(find.byType(NoticeStrip), findsOneWidget);
    await tester.tap(find.text('Use Another Email'));
    await tester.pump();
    expect(anotherEmail, 1);
  });

  testWidgets("another child's session is told the link is for another account",
      (tester) async {
    await pump(
      tester,
      const AuthState.signedIn(
        user: AuthUser(uid: 'child-1', email: '', displayName: ''),
      ),
    );
    expect(find.byType(CenteredDialog), findsNothing);
    expect(
      find.textContaining('This link is for another account'),
      findsOneWidget,
    );
    verifyNever(auth.listChildren);
  });
}
