import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/app_preferences_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/first_run/application/first_run_data.dart';
import 'package:pantas/features/notifications/application/notifications_providers.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../features/first_run/first_run_harness.dart';
import '../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

String _path(GoRouter r) => r.routerDelegate.currentConfiguration.uri.path;

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await DriftSettingsRepository(db).recordPolicyAcceptance();
    await seedContentExam(
      contentDb,
      examId: 'exam_upcat',
      code: 'UPCAT',
      name: 'UPCAT',
      shortName: 'UPCAT',
    );
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_upcat',
            code: 'UPCAT',
            name: 'UPCAT',
            shortName: 'UPCAT',
            language: 'en',
          ),
        );
    final prefs = AppPreferencesRepository(db);
    await prefs.setPassedAgeGate(value: true);
    await prefs.setSelectedExamId('exam_upcat');
    await prefs.setCompletedOnboarding(value: true);
    await NotificationRationaleRepository(db).markShown();
  });

  tearDown(() => db.close());

  Future<GoRouter> pump(WidgetTester tester, {required bool open}) async {
    if (open) {
      await AppPreferencesRepository(db).setDeviceValue(
        'first_run_open_v1',
        '{"uid":"u1","examId":"exam_upcat","step":"intro",'
            '"picks":{},"checked":[]}',
      );
    }
    final catalog = await tester
        .runAsync(() => ExamCatalogRepository(contentDb).watchAll().first);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(catalog!)),
          contentDatabaseProvider.overrideWithValue(contentDb),
          authStateProvider.overrideWith(
            (ref) => Stream.value(
              const AuthState.signedIn(
                user: AuthUser(uid: 'u1', email: '', displayName: ''),
              ),
            ),
          ),
          firstRunDataProvider.overrideWith((ref, examId) async => fixtureData),
          entitlementProvider.overrideWith(
            (_) => Stream.value(const Entitlement.free()),
          ),
        ],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
    final container =
        ProviderScope.containerOf(tester.element(find.byType(App)));
    return container.read(routerProvider);
  }

  testWidgets('a cold start that would land on Home opens the open run',
      (tester) async {
    final router = await pump(tester, open: true);
    expect(_path(router), '/try');
    expect(find.text('Try Pantas first'), findsOneWidget);
  });

  testWidgets('Home stays Home when no run is open', (tester) async {
    final router = await pump(tester, open: false);
    expect(_path(router), '/home');
  });

  testWidgets('/try with no open run goes to Home', (tester) async {
    final router = await pump(tester, open: false);
    router.go('/try');
    await tester.pumpAndSettle();
    expect(_path(router), '/home');
  });
}
