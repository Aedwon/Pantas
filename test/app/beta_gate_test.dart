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

  final now = DateTime.utc(2026, 11, 8, 12);
  final start = DateTime.utc(2026, 11, 8, 16);

  String? redirect(
    String path,
    AsyncValue<BetaAccess> access, {
    bool active = true,
    DateTime? at,
  }) =>
      betaGateRedirect(
        path: path,
        active: active,
        access: access,
        now: at ?? now,
      );

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
    expect(redirect('/study', const AsyncData(BetaAccess.denied)), '/beta');
    expect(redirect('/study', const AsyncData(BetaAccess.open)), isNull);
    expect(
      redirect('/study', const AsyncData(BetaAccess.denied), active: false),
      isNull,
    );
    expect(redirect('/beta', const AsyncData(BetaAccess.open)), '/home');
  });

  test('a selected tester waits on the waiting screen until the start', () {
    final waiting = AsyncData(BetaAccess(selected: true, waitUntil: start));
    expect(redirect('/study', waiting), '/beta');
    expect(redirect('/home', waiting), '/beta');
    expect(redirect('/beta', waiting), isNull);
    expect(
      redirect(
        '/beta',
        waiting,
        at: start.subtract(const Duration(seconds: 1)),
      ),
      isNull,
    );
    expect(redirect('/legal/terms', waiting), isNull);
  });

  test('at or after the start a waiting tester gets normal access', () {
    final waiting = AsyncData(BetaAccess(selected: true, waitUntil: start));
    expect(redirect('/beta', waiting, at: start), '/home');
    expect(redirect('/study', waiting, at: start), isNull);
    expect(
      redirect('/beta', waiting, at: start.add(const Duration(days: 1))),
      '/home',
    );
  });

  test('a waiting date never lets an unselected account in', () {
    final odd = AsyncData(BetaAccess(selected: false, waitUntil: start));
    expect(redirect('/study', odd, at: start), '/beta');
  });

  test('the gate waits while the sign-in screen plays its signed-in beat', () {
    final container = ProviderContainer(
      overrides: [
        betaGateActiveProvider.overrideWithValue(true),
        betaAccessProvider.overrideWith((ref) async => BetaAccess.open),
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
    Future<BetaAccess> result,
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
    final pending = Completer<BetaAccess>();
    await pump(tester, pending.future, const AuthState.anonymous(uid: 'anon'));
    expect(find.byType(SkeletonPulse), findsOneWidget);
    expect(find.text('Use Google Instead'), findsNothing);
    pending.complete(BetaAccess.open);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('anonymous gate offers the email code and Google',
      (tester) async {
    await pump(
      tester,
      Future.value(BetaAccess.denied),
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
      Future.value(BetaAccess.denied),
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
