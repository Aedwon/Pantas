import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_repository.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/auth/sign_in_result.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';

class FailingAuthRepository implements AuthRepository {
  @override
  Future<SignInResult> signInWithGoogle() async {
    return const SignInResult.failed(reason: 'network_error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AccountPage offline copy', () {
    testWidgets('shows failure line when sign in fails', (tester) async {
      final repo = FailingAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWith((ref) => null),
            isAnonymousProvider.overrideWith((ref) => true),
            syncStatusProvider.overrideWith(
              (ref) => Stream.value(const SyncIdle()),
            ),
            authRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const AccountPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = find.text('Continue with Google');
      expect(button, findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();

      final status = find.bySemanticsLabel(
        'You need a connection to sign in.',
      );
      expect(status, findsOneWidget);
      expect(
        tester.getSemantics(status).flagsCollection.isLiveRegion,
        isTrue,
      );
    });
  });
}
