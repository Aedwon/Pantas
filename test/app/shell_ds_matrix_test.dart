import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/app/beta_waiting_page.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/app/web_route_shell.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/auth/beta_access.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../helpers/ds_matrix.dart';

class _Gateway extends Mock implements AuthGateway {}

class _Codes implements EmailCodeAuth {
  @override
  Future<EmailCodeRequest> requestCode(String email) async =>
      const EmailCodeRequest(resendAfterSeconds: 42, challengeId: 'c1');

  @override
  Future<SignInResult> verifyCode(String challengeId, String code) =>
      Completer<SignInResult>().future;

  @override
  void cancelVerification() {}
}

class _Repository extends AuthRepository {
  _Repository() : super(gateway: _Gateway());
}

Widget _scope(Widget child, {AsyncValue<BetaAccess>? access}) => ProviderScope(
      overrides: [
        emailCodeAuthProvider.overrideWithValue(_Codes()),
        authRepositoryProvider.overrideWithValue(_Repository()),
        betaAccessProvider.overrideWith((ref) async {
          if (access == null || access.hasError) {
            throw StateError('beta check failed');
          }
          return access.requireValue;
        }),
      ],
      child: child,
    );

/// Family C screens outside the shell frame on the design system matrix:
/// 390, 900, 1100 and 1440 wide, light and dark, text scale 1.0 and 2.0.
/// A layout overflow fails every cell.
void main() {
  setUpAll(loadDsFonts);

  dsMatrix(
    'beta sign-in (email step) fits and keeps its controls',
    (context) => _scope(const EmailSignInPage(beta: true)),
    scroll: false,
    cells: dsShellCells,
    check: (tester, cell) async {
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Continue'), findsWidgets);
    },
  );

  dsMatrix(
    'beta waiting page fits and keeps the countdown and sign-out',
    (context) => _scope(
      BetaWaitingPage(
        until: DateTime.now().toUtc().add(const Duration(days: 1, hours: 9)),
        email: 'juan@gmail.com',
      ),
    ),
    scroll: false,
    cells: dsShellCells,
    check: (tester, cell) async {
      expect(find.byKey(const ValueKey('beta-days')), findsOneWidget);
      expect(find.text('Use a Different Email'), findsOneWidget);
    },
  );

  dsMatrix(
    'beta gate error state fits and keeps Try again',
    (context) => _scope(const BetaGatePage()),
    scroll: false,
    cells: dsShellCells,
    check: (tester, cell) async {
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Try again'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final (path, sidebar) in [
    ('/home', true),
    ('/settings', true),
    ('/assessment/cse', false),
    ('/beta', false),
    ('/auth/email-link', false),
  ]) {
    dsMatrix(
      'route shell for $path',
      (context) => ProviderScope(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          height: 700,
          child: WebRouteShell(
            path: path,
            child: const Center(child: Text('Page')),
          ),
        ),
      ),
      scroll: false,
      web: true,
      cells: dsShellCells,
      check: (tester, cell) async {
        await tester.pumpAndSettle();
        // The sidebar is the navigation from 1024 on the sidebar families;
        // the TabBar belongs to AppShell, never to this frame.
        expect(
          find.byType(WebSidebar),
          sidebar && cell.width >= PantasLayout.bpTabletLandscape
              ? findsOneWidget
              : findsNothing,
        );
        expect(find.byType(AppNavBar), findsNothing);
        expect(find.text('Page'), findsOneWidget);
      },
    );
  }
}
