import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/ui/components/card_footer.dart';
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
  @override
  Future<SignInResult> signInWithGoogle() async {
    googleCalls++;
    return const SignInResult.cancelled();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<List<String>> _pump(
  WidgetTester tester,
  DsCell cell, {
  _Repo? repo,
}) async {
  final pushed = <String>[];
  tester.view
    ..physicalSize = Size(cell.width, 1400)
    ..devicePixelRatio = 1;
  debugWebPlatformOverride = true;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const AccountPage()),
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
        currentUserProvider.overrideWith((ref) => null),
        authRepositoryProvider.overrideWithValue(repo ?? _Repo()),
        paymentsOnWebProvider.overrideWithValue(true),
      ],
      child: MediaQuery(
        data: MediaQueryData(
          size: Size(cell.width, 1400),
          textScaler: TextScaler.linear(cell.scale),
        ),
        child: MaterialApp.router(
          theme: cell.dark
              ? buildDarkTheme(web: true)
              : buildLightTheme(web: true),
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
}
