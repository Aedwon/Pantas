import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/sign_in/email_sign_in_page.dart';
import 'package:pantas/app/start_location.dart';
import 'package:pantas/app/startup_gates.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/child_setup/presentation/for_parents_page.dart';
import 'package:pantas/features/child_setup/presentation/parent_delete_link_screen.dart';
import 'package:pantas/features/onboarding/presentation/child/parent_sign_in_screen.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';

import '../helpers/in_memory_database.dart';

/// The receipt email's delete link and the code gate (`/parents/*`) open for a
/// parent on a device that has not finished onboarding, and the routes pass
/// the child along.
/// The router's pages animate in, and onboarding never stops animating, so
/// settle by time.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 500));
  }
}

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'cse',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
  });

  tearDown(() async {
    forgetStartLocation();
    await db.close();
  });

  Future<void> finishOnboarding() async {
    final prefs = AppPreferencesRepository(db);
    await prefs.setPassedAgeGate(value: true);
    await prefs.setSelectedExamId('cse');
    await prefs.setCompletedOnboarding(value: true);
  }

  Future<ProviderContainer> openDirectly(
    WidgetTester tester,
    String address, {
    AuthState? auth,
    bool wide = false,
  }) async {
    if (wide) {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }
    final catalog = await tester
        .runAsync(() => ExamCatalogRepository(contentDb).watchAll().first);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        examPickerCatalogProvider.overrideWith((ref) => Stream.value(catalog!)),
        contentDatabaseProvider.overrideWithValue(contentDb),
        entitlementProvider.overrideWith(
          (_) => Stream.value(const Entitlement.free()),
        ),
        if (auth != null)
          authStateProvider.overrideWith((ref) => Stream.value(auth)),
      ],
    );
    addTearDown(container.dispose);
    rememberStartLocation(
      Uri.parse('https://app.example.test$address'),
      isWeb: true,
    );
    await tester.runAsync(() => settleGatesBeforeFirstPage(container));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const App(flavor: Flavor.dev),
      ),
    );
    await settle(tester);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
    return container;
  }

  Uri locationOf(ProviderContainer container) => container
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .last
      .matchedLocation
      .let(Uri.parse);

  group('a device that has not finished onboarding', () {
    testWidgets('the delete link is not sent to onboarding', (tester) async {
      final container = await openDirectly(
        tester,
        '/parents/delete?child=child-2',
      );
      // Signed out, so the link leads on to the parent sign-in. The router did
      // not take it to onboarding on the way.
      expect(locationOf(container).path, parentDeleteSignInPath);
      expect(find.byType(ParentSignInScreen), findsOneWidget);
    });

    testWidgets('the parent sign-in keeps the child for the way back',
        (tester) async {
      final container = await openDirectly(
        tester,
        '/parents/delete/sign-in?child=child-2',
      );
      expect(find.byType(ParentSignInScreen), findsOneWidget);
      await tester.tap(find.text('Continue with Email'));
      await settle(tester);
      expect(locationOf(container).path, parentDeleteEmailPath);
      final email =
          tester.widget<EmailSignInPage>(find.byType(EmailSignInPage));
      expect(email.returnTo, '/parents/delete?child=child-2');
    });

    testWidgets('the email step opened by address returns to the link',
        (tester) async {
      await openDirectly(
        tester,
        '/parents/delete/sign-in/email?child=child-2',
      );
      final email =
          tester.widget<EmailSignInPage>(find.byType(EmailSignInPage));
      expect(email.returnTo, '/parents/delete?child=child-2');
    });

    for (final path in [
      '/parents/delete',
      '/parents/delete/sign-in',
      '/parents/delete/sign-in/email',
    ]) {
      testWidgets('$path with no child goes Home, not to a blank page',
          (tester) async {
        final container = await openDirectly(tester, path);
        expect(locationOf(container).path, isNot(startsWith('/parents/')));
        expect(find.byType(ParentDeleteLinkScreen), findsNothing);
      });
    }

    testWidgets('other addresses still go to onboarding', (tester) async {
      final container = await openDirectly(tester, '/settings/parents');
      expect(locationOf(container).path, '/onboarding');
    });
  });

  group('a device signed in as the child', () {
    setUp(finishOnboarding);

    testWidgets('the delete link opens For parents with the delete confirm',
        (tester) async {
      final container = await openDirectly(
        tester,
        '/parents/delete?child=child-2',
        auth: const AuthState.signedIn(
          user: AuthUser(uid: 'child-2', email: '', displayName: ''),
        ),
      );
      await settle(tester);
      expect(locationOf(container).path, forParentsPath);
      expect(find.byType(ForParentsPage), findsOneWidget);
      expect(find.byType(CenteredDialog), findsOneWidget);
      expect(find.text('Delete this account?'), findsOneWidget);
    });

    testWidgets('For parents opened by address shows no confirm',
        (tester) async {
      await openDirectly(
        tester,
        '/settings/parents',
        auth: const AuthState.signedIn(
          user: AuthUser(uid: 'child-2', email: '', displayName: ''),
        ),
      );
      expect(find.byType(ForParentsPage), findsOneWidget);
      expect(find.byType(CenteredDialog), findsNothing);
    });

    testWidgets('the code gate opened by address returns to For parents',
        (tester) async {
      final container = await openDirectly(
        tester,
        '/parents/code',
        auth: const AuthState.signedIn(
          user: AuthUser(uid: 'child-2', email: '', displayName: ''),
        ),
      );
      expect(locationOf(container).path, forParentsPath);
    });
  });

  group('wide web', () {
    const child = AuthState.signedIn(
      user: AuthUser(uid: 'child-2', email: '', displayName: ''),
    );

    testWidgets('For parents is in the Settings list for a child',
        (tester) async {
      await finishOnboarding();
      await AppPreferencesRepository(db).setAgeGroup('child');
      await openDirectly(tester, '/settings', auth: child, wide: true);
      expect(find.text('For parents'), findsOneWidget);
      expect(
        find.text('This account is managed by a parent or guardian.'),
        findsOneWidget,
      );
    });

    testWidgets('For parents is not in the list for an adult', (tester) async {
      await finishOnboarding();
      await AppPreferencesRepository(db).setAgeGroup('adult');
      await openDirectly(tester, '/settings', auth: child, wide: true);
      expect(find.text('For parents'), findsNothing);
    });

    testWidgets('the page is drawn in the Settings pane', (tester) async {
      await finishOnboarding();
      await AppPreferencesRepository(db).setAgeGroup('child');
      await openDirectly(tester, '/settings/parents', auth: child, wide: true);
      expect(find.byType(SettingsPanePage), findsOneWidget);
      expect(find.byType(ForParentsPage), findsOneWidget);
      expect(find.text('Delete this account'), findsOneWidget);
      expect(find.text('Settings'), findsWidgets);
    });
  });
}

extension<T> on T {
  R let<R>(R Function(T value) block) => block(this);
}
