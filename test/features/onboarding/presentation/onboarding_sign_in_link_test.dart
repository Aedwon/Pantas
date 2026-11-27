import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  Future<void> pumpPage(WidgetTester tester, AuthState auth) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const OnboardingPage()),
        GoRoute(
          path: '/auth/email-link',
          builder: (context, state) =>
              const Scaffold(body: Text('email sign-in page')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authStateProvider.overrideWith((ref) => Stream.value(auth)),
          onboardingProgressProvider
              .overrideWith((ref) async => OnboardingProgress()),
          settingsRepositoryProvider
              .overrideWithValue(DriftSettingsRepository(db)),
          passedAgeGateProvider.overrideWith((ref) async => false),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'Sign in on Welcome opens the email sign-in page and Back returns',
      (tester) async {
    await pumpPage(tester, const SignedOutAuthState());
    expect(find.text('Welcome to Pantas'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('email sign-in page'), findsOneWidget);
    GoRouter.of(tester.element(find.text('email sign-in page'))).pop();
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Pantas'), findsOneWidget);
  });

  testWidgets('a signed-in student skips Welcome and starts at the age step',
      (tester) async {
    await pumpPage(
      tester,
      const SignedInAuthState(
        user: AuthUser(
          uid: 'u1',
          email: 'a@example.com',
          displayName: 'Ana',
        ),
      ),
    );
    expect(find.text('Welcome to Pantas'), findsNothing);
    expect(find.text('Already have an account?'), findsNothing);
    expect(find.text('How old are you?'), findsOneWidget);
  });
}
