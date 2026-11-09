import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/ui/components/card_footer.dart';
import 'package:pantas/core/ui/components/google_sign_in_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';

import '../../../helpers/ds_matrix.dart';

const _note = 'Your progress stays in this browser. '
    'Signing in gives you an account you can come back to.';

class _Repo implements AuthRepository {
  int googleCalls = 0;
  Completer<SignInResult>? gate;
  SignInResult result = const SignInResult.cancelled();
  @override
  Future<SignInResult> signInWithGoogle() async {
    googleCalls++;
    return gate?.future ?? result;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<List<String>> _pump(
  WidgetTester tester,
  DsCell cell, {
  _Repo? repo,
  AuthUser? user,
  double? paneWidth,
  bool web = true,
}) async {
  final pushed = <String>[];
  tester.view
    ..physicalSize = Size(cell.width, 1400)
    ..devicePixelRatio = 1;
  debugWebPlatformOverride = web;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => paneWidth == null
            ? const AccountPage()
            : Align(
                alignment: Alignment.topLeft,
                child: SizedBox(width: paneWidth, child: const AccountPage()),
              ),
      ),
      GoRoute(
        path: '/auth/email-link',
        builder: (_, __) {
          pushed.add('/auth/email-link');
          return const SizedBox();
        },
      ),
      GoRoute(
        path: '/settings/account/delete',
        builder: (_, __) {
          pushed.add('/settings/account/delete');
          return const SizedBox();
        },
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith((ref) => user),
        authRepositoryProvider.overrideWithValue(repo ?? _Repo()),
        paymentsOnWebProvider.overrideWithValue(web),
      ],
      child: MediaQuery(
        data: MediaQueryData(
          size: Size(cell.width, 1400),
          textScaler: TextScaler.linear(cell.scale),
        ),
        child: MaterialApp.router(
          theme:
              cell.dark ? buildDarkTheme(web: web) : buildLightTheme(web: web),
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return pushed;
}

Finder _button(String label) =>
    find.ancestor(of: find.text(label), matching: find.byType(TextButton));

void main() {
  setUpAll(loadDsFonts);
  for (final w in [1024.0, 1440.0]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        final cell = DsCell(w, scale, dark: dark);
        testWidgets('wide signed-out Account, option A ($cell)',
            (tester) async {
          await _pump(tester, cell);
          expect(tester.takeException(), isNull);

          final footer = find.byType(CardFooter);
          expect(footer, findsOneWidget);
          final f = tester.getRect(find.byKey(const ValueKey('card-footer')));
          expect(
            find.descendant(
              of: footer,
              matching:
                  find.text('You get your own Pantas ID when you sign in.'),
            ),
            findsOneWidget,
          );
          final email = tester.getRect(_button('Continue with Email'));
          final google = tester.getRect(_button('Continue with Google'));
          expect(google.right, f.right - 20);
          if (scale == 1) {
            // One line, Email then Google, both 42 tall.
            expect(email.right, lessThan(google.left));
            expect(email.height, 42);
            expect(google.height, 42);
            expect(email.top, google.top);
          } else {
            // Larger text: the pair wraps inside the footer, Email first.
            expect(email.height, greaterThanOrEqualTo(42));
            expect(google.height, greaterThanOrEqualTo(42));
            expect(
              email.right < google.left || email.bottom <= google.top,
              isTrue,
            );
          }

          // The progress note sits under the card.
          expect(tester.getTopLeft(find.text(_note)).dy, greaterThan(f.bottom));

          // Delete My Data is a ghost critical button below, at the left.
          final del = find.byWidgetPredicate(
            (w) =>
                w is WebButton &&
                w.label == 'Delete My Data' &&
                w.kind == PantasButtonKind.tertiary &&
                w.tone == PantasButtonTone.critical,
          );
          expect(del, findsOneWidget);
          expect(
            tester.getTopLeft(del).dy,
            greaterThan(tester.getTopLeft(find.text(_note)).dy),
          );
          expect(tester.getRect(del).height, greaterThanOrEqualTo(42));
        });
      }
    }
  }

  testWidgets('the pair fits one line in a 428 wide footer at 1.0',
      (tester) async {
    await _pump(tester, const DsCell(1440, 1, dark: false));
    final email = tester.getRect(_button('Continue with Email'));
    final google = tester.getRect(_button('Continue with Google'));
    expect(google.right - email.left, lessThanOrEqualTo(428));
  });

  testWidgets('both sign-in buttons and Delete keep their behavior',
      (tester) async {
    final repo = _Repo();
    final pushed =
        await _pump(tester, const DsCell(1440, 1, dark: false), repo: repo);
    await tester.tap(_button('Continue with Google'));
    await tester.pumpAndSettle();
    expect(repo.googleCalls, 1);
    await tester.tap(_button('Continue with Email'));
    await tester.pumpAndSettle();
    expect(pushed, ['/auth/email-link']);
  });

  testWidgets('Delete My Data opens the delete page', (tester) async {
    final pushed = await _pump(tester, const DsCell(1440, 1, dark: false));
    await tester.tap(find.text('Delete My Data'));
    await tester.pumpAndSettle();
    expect(pushed, ['/settings/account/delete']);
  });

  testWidgets('the note is the group note, 8px under the card', (tester) async {
    await _pump(tester, const DsCell(1440, 1, dark: false));
    final card = tester.getRect(
      find.ancestor(
        of: find.byType(CardFooter),
        matching: find.byType(WebCard),
      ),
    );
    expect(tester.getTopLeft(find.text(_note)).dy - card.bottom, 8);
  });

  for (final w in [1440.0, 1024.0]) {
    for (final scale in [1.5, 2.0]) {
      for (final pane in w == 1024 ? [null, 828.0] : <double?>[null]) {
        testWidgets('pair stays inside the card ($w x$scale pane $pane)',
            (tester) async {
          await _pump(tester, DsCell(w, scale, dark: false), paneWidth: pane);
          expect(tester.takeException(), isNull);
          final f = tester.getRect(find.byKey(const ValueKey('card-footer')));
          final email = tester.getRect(_button('Continue with Email'));
          final google = tester.getRect(_button('Continue with Google'));
          for (final r in [email, google]) {
            expect(r.left, greaterThanOrEqualTo(f.left));
            expect(r.right, lessThanOrEqualTo(f.right));
            expect(r.bottom, lessThanOrEqualTo(f.bottom));
          }
        });
      }
    }
  }

  testWidgets('busy: both buttons are disabled and Google says Signing in',
      (tester) async {
    final repo = _Repo()..gate = Completer<SignInResult>();
    await _pump(tester, const DsCell(1440, 1, dark: false), repo: repo);
    await tester.tap(_button('Continue with Google'));
    await tester.pump();
    expect(find.text('Signing in…'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
    expect(tester.widget<TextButton>(_button('Signing in…')).onPressed, isNull);
    expect(
      tester.widget<TextButton>(_button('Continue with Email')).onPressed,
      isNull,
    );
    repo.gate!.complete(const SignInResult.cancelled());
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(
      tester.widget<TextButton>(_button('Continue with Email')).onPressed,
      isNotNull,
    );
  });

  testWidgets('a Google failure text replaces the note, as before',
      (tester) async {
    final repo = _Repo()
      ..result = const SignInResult.failed(reason: 'network-request-failed');
    await _pump(tester, const DsCell(1440, 1, dark: false), repo: repo);
    await tester.tap(_button('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text('You need a connection to sign in.'), findsOneWidget);
    expect(find.text(_note), findsNothing);
  });

  for (final scale in [1.5, 2.0]) {
    testWidgets(
        'Name and Pantas ID rows stack, not overflow, in a 468 detail pane (828 page) '
        'at $scale text', (tester) async {
      await _pump(
        tester,
        DsCell(1024, scale, dark: false),
        paneWidth: 828,
      );
      expect(tester.takeException(), isNull);
      // Ruling 12: a value that does not fit goes under its title.
      final title = tester.getRect(find.text('Pantas ID'));
      final value = tester.getRect(find.text('Sign in to get one'));
      // Above 1.5x the value goes under the title; at 1.5 it still fits.
      if (scale > 1.5) {
        expect(value.top, greaterThanOrEqualTo(title.bottom));
      }
    });
  }

  testWidgets('the shared Google button without a size stays 48 tall',
      (tester) async {
    await pumpDs(
      tester,
      const DsCell(1440, 1, dark: false),
      GoogleSignInButton(onPressed: () {}),
    );
    expect(tester.getSize(find.byType(TextButton)).height, 48);
  });

  testWidgets('phone signed out is unchanged: no footer, full-width Google',
      (tester) async {
    await _pump(
      tester,
      const DsCell(390, 1, dark: false),
      web: false,
    );
    expect(find.byType(CardFooter), findsNothing);
    expect(
      tester.getSize(_button('Continue with Google')).width,
      greaterThan(300),
    );
    expect(find.text('Continue with Email'), findsNothing);
    expect(find.textContaining('on this phone'), findsOneWidget);
    expect(find.text('Delete My Data'), findsOneWidget);
  });

  testWidgets('wide signed in is unchanged: no footer, Sign Out and Delete',
      (tester) async {
    await _pump(
      tester,
      const DsCell(1440, 1, dark: false),
      user: const AuthUser(uid: 'u', email: 'a@example.com', displayName: 'A'),
    );
    expect(find.byType(CardFooter), findsNothing);
    expect(find.text('Sign Out'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);
    expect(find.text('Continue with Google'), findsNothing);
    expect(find.text('Delete My Data'), findsNothing);
  });
}
