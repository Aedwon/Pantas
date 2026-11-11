import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/guardian/data/guardian_gateway.dart';
import 'package:pantas/features/guardian/domain/guardian_consent.dart';
import 'package:pantas/features/guardian/domain/guardian_copy.dart';
import 'package:pantas/features/guardian/presentation/guardian_screen.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

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
  }) async {
    final repo = AuthRepository(gateway: auth);
    if (failSignOut) {
      repo.beforeIdentityChange = () async => throw StateError('offline');
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
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
    await tester.pumpAndSettle();
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
