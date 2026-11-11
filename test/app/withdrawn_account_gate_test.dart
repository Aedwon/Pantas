import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/beta_gate.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/start_location.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/platform/account_access.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/domain/guardian_copy.dart';
import 'package:pantas/features/guardian/presentation/guardian_screen.dart';
import 'package:pantas/features/legal/presentation/legal_document_page.dart';
import 'package:pantas/features/lesson/presentation/widgets/web_lesson_search.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/shell/presentation/app_shell.dart';
import 'package:pantas/features/shell/presentation/web_shell.dart';

import '../core/auth/auth_repository_sign_out_test.dart'
    show SignOutAuthGateway;
import '../features/guardian/fake_guardian_gateway.dart';
import '../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late FakeGuardianGateway guardian;
  late SignOutAuthGateway auth;
  late AccountAccess access;
  late List<String> operations;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    guardian = FakeGuardianGateway()
      ..current = const GuardianStatus(status: GuardianConsentStatus.confirmed);
    operations = [];
    auth = SignOutAuthGateway(operations);
    access = AccountAccess();
    final prefs = AppPreferencesRepository(db);
    await prefs.setAgeGroup('minor');
    await prefs.setPassedAgeGate(value: true);
    await prefs.setSelectedExamId('cse');
    await prefs.setCompletedOnboarding(value: true);
    await prefs.setGuardianStatusCache('confirmed');
    await DriftSettingsRepository(db).recordPolicyAcceptance();
  });

  tearDown(() async {
    forgetStartLocation();
    await access.dispose();
    await contentDb.close();
    await db.close();
  });

  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    bool failSignOut = false,
    AppPreferencesRepository? preferences,
    bool settle = true,
    bool webLegalRoute = false,
  }) async {
    final repo = AuthRepository(gateway: auth);
    if (failSignOut) {
      repo.beforeIdentityChange = () async => throw StateError('offline');
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (webLegalRoute)
            routerProvider.overrideWith((ref) {
              final router = GoRouter(
                initialLocation: '/legal/privacy',
                routes: buildAppRoutes(ref, web: true),
              );
              ref.onDispose(router.dispose);
              return router;
            }),
          appDatabaseProvider.overrideWithValue(db),
          if (preferences != null)
            appPreferencesRepositoryProvider.overrideWithValue(preferences),
          contentDatabaseProvider.overrideWithValue(contentDb),
          examPickerCatalogProvider.overrideWith((ref) => Stream.value([])),
          authRepositoryProvider.overrideWithValue(repo),
          accountAccessProvider.overrideWithValue(access),
          guardianGatewayProvider.overrideWithValue(guardian),
          entitlementProvider.overrideWith(
            (ref) => Stream.value(const Entitlement.free()),
          ),
          betaGateActiveProvider.overrideWithValue(false),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    if (settle) await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
    return ProviderScope.containerOf(tester.element(find.byType(App)));
  }

  testWidgets('a cleared minor is signed out when the next status is withdrawn',
      (tester) async {
    final container = await pumpApp(tester);
    guardian.current = GuardianStatus.fromJson({'status': 'withdrawn'});
    final refreshed = container.read(guardianControllerProvider).refresh();
    await tester.pumpAndSettle();
    await refreshed;
    await tester.pumpAndSettle();
    expect(operations, contains('firebaseSignOut'));
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
    expect(find.text(GuardianCopy.withdrawnTitle), findsOneWidget);
    expect(find.text('Check Again'), findsNothing);
    container.read(routerProvider).go('/home');
    await tester.pumpAndSettle();
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/guardian/withdrawn',
    );
  });

  testWidgets(
      'a callable refusal closes only its owner and survives failed sign-out',
      (tester) async {
    final container = await pumpApp(tester, failSignOut: true);
    access.close('previous-user');
    await tester.pumpAndSettle();
    expect(container.read(guardianAccountClosedProvider), isNull);
    final refusal = FirebaseFunctionsException(
      code: 'permission-denied',
      message: 'This account is being deleted.',
      details: const {'reason': 'account-closed'},
    );
    await expectLater(
      access.run<void>('user-1', () async => throw refusal),
      throwsA(same(refusal)),
    );
    await tester.pumpAndSettle();
    expect(auth.currentSession?.uid, 'user-1');
    expect(container.read(guardianAccountClosedProvider), 'user-1');
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
    guardian.failure = const GuardianGatewayException('unavailable');
    container.invalidate(guardianGateProvider);
    container.read(routerProvider).go('/onboarding');
    await tester.pumpAndSettle();
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
  });

  testWidgets(
      'an offline start restores closure instead of cached confirmation',
      (tester) async {
    await AppPreferencesRepository(db)
        .setDeviceValue('guardian_closed_uid', 'user-1');
    guardian.failure = const GuardianGatewayException('unavailable');
    final container = await pumpApp(tester, failSignOut: true);
    expect(
      await container.read(guardianGateProvider.future),
      GuardianGate.withdrawn,
    );
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
  });

  testWidgets('a new uid never inherits an offline withdrawal cache',
      (tester) async {
    final prefs = AppPreferencesRepository(db);
    await prefs.setDeviceValue('guardian_closed_uid', 'previous-user');
    await prefs.setGuardianStatusCache('withdrawn');
    guardian.failure = const GuardianGatewayException('unavailable');
    final container = await pumpApp(tester, failSignOut: true);
    expect(
      await container.read(guardianGateProvider.future),
      isNot(GuardianGate.withdrawn),
    );
    expect(container.read(guardianAccountClosedProvider), isNull);
    expect(await prefs.deviceValue('guardian_closed_uid'), '');
    expect(find.byType(GuardianWithdrawnPage), findsNothing);
  });

  testWidgets('slow closure restore never renders a private route first',
      (tester) async {
    final restore = Completer<void>();
    final prefs = _SlowClosurePreferences(db, restore.future);
    await prefs.setDeviceValue('guardian_closed_uid', 'user-1');
    guardian.failure = const GuardianGatewayException('unavailable');
    final container = await pumpApp(
      tester,
      failSignOut: true,
      preferences: prefs,
      settle: false,
    );
    for (var frame = 0; frame < 10; frame++) {
      await tester.pump(const Duration(milliseconds: 500));
      expect(
        find.byType(AppShell),
        findsNothing,
        reason: 'private shell mounted before closure restoration',
      );
      final route =
          container.read(routerProvider).routerDelegate.currentConfiguration;
      expect(
        route.isEmpty || route.uri.path == '/startup',
        isTrue,
        reason: 'only a neutral route may render before closure is known',
      );
    }
    restore.complete();
    await tester.pumpAndSettle();
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
  });

  testWidgets('slow closure restore drops the old uid after an identity switch',
      (tester) async {
    final restore = Completer<void>();
    final prefs = _SlowClosurePreferences(db, restore.future);
    await prefs.setDeviceValue('guardian_closed_uid', 'user-1');
    final container = await pumpApp(
      tester,
      failSignOut: true,
      preferences: prefs,
      settle: false,
    );
    await tester.pump();
    expect(find.byType(AppShell), findsNothing);
    auth.currentSession = const AuthSession(uid: 'user-2');
    container.invalidate(guardianGateProvider);
    await tester.pump();
    restore.complete();
    await tester.pumpAndSettle();
    expect(auth.currentSession?.uid, 'user-2');
    expect(container.read(guardianAccountClosedProvider), isNull);
    expect(access.isClosed('user-1'), isFalse);
    expect(
      await container.read(guardianGateProvider.future),
      GuardianGate.cleared,
    );
    expect(find.byType(GuardianWithdrawnPage), findsNothing);
  });

  testWidgets(
      'legal content stays public during slow or failed closure restore',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final restore = Completer<void>();
    final prefs = _SlowClosurePreferences(db, restore.future);
    await prefs.setDeviceValue('guardian_closed_uid', 'user-1');
    await DriftSettingsRepository(db).updateName('Retained Student');
    final container = await pumpApp(
      tester,
      failSignOut: true,
      preferences: prefs,
      webLegalRoute: true,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 4));
    expect(container.read(guardianGateProvider).isLoading, isTrue);
    expect(find.text('What we collect'), findsOneWidget);
    expect(find.byType(WebShellFrame), findsNothing);
    expect(find.byType(SettingsPanePage), findsNothing);
    expect(find.textContaining('Retained Student'), findsNothing);
    prefs.failure = StateError('storage unavailable');
    restore.complete();
    await tester.pumpAndSettle();
    expect(container.read(guardianGateProvider).hasError, isTrue);
    for (final width in [1440.0, 390.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpAndSettle();
      expect(find.text('What we collect'), findsOneWidget);
      expect(find.byType(WebShellFrame), findsNothing);
      expect(find.byType(SettingsPanePage), findsNothing);
      expect(find.textContaining('Retained Student'), findsNothing);
      expect(find.byType(WebLessonSearch), findsNothing);
    }
    prefs.failure = null;
    container.invalidate(guardianGateProvider);
    await tester.pumpAndSettle();
    expect(container.read(guardianAccountClosedProvider), 'user-1');
    expect(find.text('What we collect'), findsOneWidget);
    expect(find.byType(WebShellFrame), findsNothing);
    expect(find.byType(SettingsPanePage), findsNothing);
  });

  for (final width in [390.0, 768.0, 1200.0, 1440.0]) {
    testWidgets('closed account legal content stays private at width $width',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await DriftSettingsRepository(db).updateName('Retained Student');
      await AppPreferencesRepository(db)
          .setDeviceValue('guardian_closed_uid', 'user-1');
      final container = await pumpApp(
        tester,
        failSignOut: true,
        webLegalRoute: true,
      );
      expect(container.read(guardianAccountClosedProvider), 'user-1');
      expect(auth.currentSession?.uid, 'user-1');
      expect(find.byType(WebShellFrame), findsNothing);
      expect(find.byType(SettingsPanePage), findsNothing);
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpAndSettle();
      for (final (document, heading) in [
        ('privacy', 'What we collect'),
        ('terms', 'Use of the app'),
        ('teens', 'Who this is for'),
      ]) {
        container.read(routerProvider).go('/legal/$document');
        await tester.pumpAndSettle();
        expect(find.text(heading), findsOneWidget);
        expect(find.byType(AppShell), findsNothing);
        expect(find.byType(WebShellFrame), findsNothing);
        expect(find.byType(SettingsPanePage), findsNothing);
        expect(find.textContaining('Retained Student'), findsNothing);
        expect(find.textContaining('CSE'), findsNothing);
        expect(find.text('Pro'), findsNothing);
        expect(find.text('Free'), findsNothing);
        expect(find.text('Search'), findsNothing);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();
        await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
        await tester.pumpAndSettle();
        expect(find.byType(WebLessonSearch), findsNothing);
        expect(find.text('Recently Opened'), findsNothing);
        expect(find.byType(LegalDocumentPage), findsOneWidget);
      }
    });
  }

  testWidgets('failed closure restoration stays on a neutral recovery route',
      (tester) async {
    final restore = Completer<void>();
    final prefs = _SlowClosurePreferences(db, restore.future);
    final container = await pumpApp(
      tester,
      preferences: prefs,
      settle: false,
    );
    await tester.pump();
    prefs.failure = StateError('storage unavailable');
    restore.complete();
    await tester.pumpAndSettle();
    expect(find.byType(AppShell), findsNothing);
    expect(
      container
          .read(routerProvider)
          .routerDelegate
          .currentConfiguration
          .uri
          .path,
      '/startup',
    );
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Try Again'), findsOneWidget);
    prefs.failure = null;
    await prefs.setDeviceValue('guardian_closed_uid', 'user-1');
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
  });

  testWidgets('only a different signed-in uid clears the persisted closure',
      (tester) async {
    final prefs = AppPreferencesRepository(db);
    await prefs.setDeviceValue('guardian_closed_uid', 'previous-user');
    final container = await pumpApp(tester);
    expect(
      await container.read(guardianGateProvider.future),
      GuardianGate.cleared,
    );
    expect(await prefs.deviceValue('guardian_closed_uid'), '');
    expect(find.byType(GuardianWithdrawnPage), findsNothing);
  });

  testWidgets(
      'closure is persisted before sign-out and survives a fresh app offline',
      (tester) async {
    final container = await pumpApp(tester, failSignOut: true);
    final prefs = AppPreferencesRepository(db);
    final repo = container.read(authRepositoryProvider);
    String? savedBeforeSignOut;
    repo.beforeIdentityChange = () async {
      savedBeforeSignOut = await prefs.deviceValue('guardian_closed_uid');
      throw StateError('offline');
    };
    access.close('user-1');
    await tester.pumpAndSettle();
    expect(savedBeforeSignOut, 'user-1');
    expect(await prefs.guardianStatusCache(), 'confirmed');
    expect(auth.currentSession?.uid, 'user-1');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await access.dispose();
    access = AccountAccess();
    guardian.failure = const GuardianGatewayException('unavailable');
    final reloaded = await pumpApp(tester, failSignOut: true);
    expect(identical(container, reloaded), isFalse);
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
    expect(await prefs.deviceValue('guardian_closed_uid'), 'user-1');
    reloaded.invalidate(guardianGateProvider);
    await tester.pumpAndSettle();
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
  });

  testWidgets('a structured server refusal signs out and holds the end state',
      (tester) async {
    await pumpApp(tester);
    final refusal = FirebaseFunctionsException(
      code: 'permission-denied',
      message: 'This account is being deleted.',
      details: const {'reason': 'account-closed'},
    );
    await expectLater(
      access.run<void>('user-1', () async => throw refusal),
      throwsA(same(refusal)),
    );
    await tester.pumpAndSettle();
    expect(operations, contains('firebaseSignOut'));
    expect(auth.currentSession?.isAnonymous, isTrue);
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
    expect(find.text('Try Again'), findsNothing);
  });

  testWidgets('returning to the app refreshes an already confirmed minor',
      (tester) async {
    await pumpApp(tester);
    guardian.current = GuardianStatus.fromJson({'status': 'withdrawn'});
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(operations, contains('firebaseSignOut'));
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
  });

  testWidgets('a refusal received before bootstrap still closes the account',
      (tester) async {
    access.close('user-1');
    final container = await pumpApp(tester);
    expect(operations, contains('firebaseSignOut'));
    expect(container.read(guardianAccountClosedProvider), 'user-1');
    expect(find.byType(GuardianWithdrawnPage), findsOneWidget);
    container.read(routerProvider).go('/guardian/manage?token=token');
    await tester.pumpAndSettle();
    expect(
      container.read(routerProvider).routeInformationProvider.value.uri.path,
      '/guardian/manage',
    );
  });
}

class _SlowClosurePreferences extends AppPreferencesRepository {
  _SlowClosurePreferences(super.db, this.restore);

  final Future<void> restore;
  StateError? failure;

  @override
  Future<String?> deviceValue(String key) async {
    if (key == 'guardian_closed_uid') {
      await restore;
      if (failure case final error?) throw error;
    }
    return super.deviceValue(key);
  }
}
