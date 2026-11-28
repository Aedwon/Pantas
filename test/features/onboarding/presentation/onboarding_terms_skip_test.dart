import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/application/onboarding_flow.dart';
import 'package:pantas/features/onboarding/application/setup_acceptance.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

class _Gateway implements SetupAcceptanceGateway {
  AccountAcceptance? stored;
  Exception? readFailure;
  Completer<AccountAcceptance?>? readGate;
  int reads = 0;
  final recorded = <String>[];

  @override
  Future<void> record(String version) async => recorded.add(version);

  @override
  Future<AccountAcceptance?> read() async {
    reads++;
    if (readFailure != null) throw readFailure!;
    if (readGate != null) return readGate!.future;
    return stored;
  }
}

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;
  late _Gateway gateway;
  final acceptedAt = DateTime.utc(2026, 11, 9, 2);
  const named = SignedInAuthState(
    user: AuthUser(uid: 'u1', email: 'a@example.com', displayName: 'Ana'),
  );

  setUp(() async {
    db = inMemoryDatabase();
    gateway = _Gateway();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'exam_cse_pro',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
  });
  tearDown(() => db.close());

  Future<void> pumpPage(
    WidgetTester tester,
    AuthState auth, {
    bool settle = true,
  }) async {
    final catalog = await tester
        .runAsync(() => ExamCatalogRepository(contentDb).watchAll().first);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          authStateProvider.overrideWith((ref) => Stream.value(auth)),
          setupAcceptanceGatewayProvider.overrideWithValue(gateway),
          onboardingProgressProvider.overrideWith(
            (ref) async => OnboardingProgress(agePassed: true),
          ),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(catalog!)),
          contentDatabaseProvider.overrideWithValue(contentDb),
          settingsRepositoryProvider
              .overrideWithValue(DriftSettingsRepository(db)),
          passedAgeGateProvider.overrideWith((ref) async => true),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: OnboardingPage(),
          ),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
  }

  testWidgets('a named account with a current record skips Terms',
      (tester) async {
    gateway.stored = AccountAcceptance(
      version: SetupAcceptance.version,
      acceptedAt: acceptedAt,
    );
    // The student's own sharing choice from before stays as it is.
    await DriftSettingsRepository(db).updateHelpImproveApp(enabled: true);
    await pumpPage(tester, named);
    expect(find.text('Terms and Privacy'), findsNothing);
    expect(find.text('Which exam are you taking?'), findsOneWidget);
    final settings = await tester.runAsync(
      () => DriftSettingsRepository(db).readUserSettings(),
    );
    expect(settings!.acceptedTermsAt, acceptedAt);
    expect(settings.helpImproveApp, isTrue);
    final marker = await tester.runAsync(
      () => AppPreferencesRepository(db).setupAcceptanceRecordedFor(),
    );
    expect(marker, 'u1|${SetupAcceptance.version}');
    expect(gateway.recorded, isEmpty);
  });

  testWidgets('Back from the picker goes to the age step, not Terms again',
      (tester) async {
    gateway.stored = AccountAcceptance(
      version: SetupAcceptance.version,
      acceptedAt: acceptedAt,
    );
    await pumpPage(tester, named);
    expect(find.text('Which exam are you taking?'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('How old are you?'), findsOneWidget);
  });

  testWidgets('an older record shows Terms', (tester) async {
    gateway.stored =
        AccountAcceptance(version: '2026-10-01', acceptedAt: acceptedAt);
    await pumpPage(tester, named);
    expect(find.text('Terms and Privacy'), findsOneWidget);
  });

  testWidgets('no record shows Terms', (tester) async {
    await pumpPage(tester, named);
    expect(find.text('Terms and Privacy'), findsOneWidget);
    expect(gateway.reads, 1);
  });

  testWidgets('a failed read shows Terms', (tester) async {
    gateway.readFailure = Exception('offline');
    await pumpPage(tester, named);
    expect(find.text('Terms and Privacy'), findsOneWidget);
  });

  testWidgets('the loading state shows while the read runs, not Terms',
      (tester) async {
    gateway.readGate = Completer<AccountAcceptance?>();
    await pumpPage(tester, named, settle: false);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(gateway.reads, 1);
    expect(find.text('Terms and Privacy'), findsNothing);
    expect(find.text('Which exam are you taking?'), findsNothing);
    gateway.readGate!.complete(null);
    await tester.pumpAndSettle();
    expect(find.text('Terms and Privacy'), findsOneWidget);
  });

  testWidgets('an anonymous account shows Terms without reading',
      (tester) async {
    gateway.stored = AccountAcceptance(
      version: SetupAcceptance.version,
      acceptedAt: acceptedAt,
    );
    await pumpPage(tester, const AuthState.anonymous(uid: 'anon'));
    expect(find.text('Terms and Privacy'), findsOneWidget);
    expect(gateway.reads, 0);
  });
}
