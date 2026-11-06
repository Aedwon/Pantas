import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/skeleton.dart';

void main() {
  test('gate requires web and the build flag until Manila midnight', () {
    final before = DateTime.parse('2026-11-15T15:59:59Z');
    expect(
      betaGateIsActive(enabled: true, web: true, now: before),
      isTrue,
    );
    expect(
      betaGateIsActive(enabled: false, web: true, now: before),
      isFalse,
    );
    expect(
      betaGateIsActive(enabled: true, web: false, now: before),
      isFalse,
    );
    expect(
      betaGateIsActive(
        enabled: true,
        web: true,
        now: DateTime.parse('2026-11-15T16:00:00Z'),
      ),
      isFalse,
    );
  });

  String? redirect(
    String path,
    AsyncValue<bool> access, {
    bool active = true,
  }) =>
      betaGateRedirect(path: path, active: active, access: access);

  for (final path in [
    '/guardian',
    '/legal/privacy',
    '/legal/terms',
    '/auth/email-link',
  ]) {
    test('$path stays reachable before selection', () {
      expect(redirect(path, const AsyncLoading()), isNull);
    });
  }

  test('unknown access waits, selected continues and disabled bypasses', () {
    expect(redirect('/study', const AsyncLoading()), '/beta');
    expect(redirect('/study', const AsyncData(false)), '/beta');
    expect(redirect('/study', const AsyncData(true)), isNull);
    expect(
      redirect('/study', const AsyncData(false), active: false),
      isNull,
    );
    expect(redirect('/beta', const AsyncData(true)), '/home');
  });

  test('the gate waits while the sign-in screen plays its signed-in beat', () {
    final container = ProviderContainer(
      overrides: [
        betaGateActiveProvider.overrideWithValue(true),
        betaAccessProvider.overrideWith((ref) async => true),
      ],
    );
    addTearDown(container.dispose);
    container.listen(betaAccessProvider, (_, __) {});
    container.read(signInHoldProvider.notifier).state = true;
    final held = container.read(betaGateStatusProvider);
    expect(held.isLoading, isTrue);
    expect(redirect('/beta', held), isNull, reason: 'stay on the sign-in');
  });

  Future<void> pump(
    WidgetTester tester,
    Future<bool> result,
    AuthState state,
  ) async {
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, __) => const BetaGatePage())],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          betaAccessProvider.overrideWith((ref) => result),
          authStateProvider.overrideWith((ref) => Stream.value(state)),
        ],
        child: MaterialApp.router(
          theme: appLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('reload shows skeleton while selection is unknown',
      (tester) async {
    final pending = Completer<bool>();
    await pump(tester, pending.future, const AuthState.anonymous(uid: 'anon'));
    expect(find.byType(SkeletonPulse), findsOneWidget);
    expect(find.text('Use Google Instead'), findsNothing);
    pending.complete(true);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('anonymous gate offers the email code and Google',
      (tester) async {
    await pump(
      tester,
      Future.value(false),
      const AuthState.anonymous(uid: 'anon'),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Use Google Instead'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text("This email isn't on the beta list"), findsNothing);
  });

  testWidgets('failed match explains the email and gives support',
      (tester) async {
    await pump(
      tester,
      Future.value(false),
      const AuthState.signedIn(
        user: AuthUser(
          uid: 'named',
          email: 'other@example.com',
          displayName: '',
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text("This email isn't on the beta list"), findsOneWidget);
    expect(find.textContaining('other@example.com'), findsOneWidget);
    expect(find.textContaining('support@pantas.study'), findsOneWidget);
  });
}
