import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/centered_dialog.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/presentation/pages/delete_account_page.dart';
import 'package:pantas/features/settings/presentation/pages/exam_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../helpers/custom_subject_tiers_fixture.dart';
import '../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

void main() {
  test('every settings row has a route to land on', () {
    const required = [
      '/settings',
      '/settings/exam',
      '/settings/exam/change',
      '/settings/exam/included',
      '/settings/pro',
      '/settings/account',
      '/settings/backup',
      '/settings/about',
    ];

    final paths = collectRoutePaths();

    for (final path in required) {
      expect(paths, contains(path), reason: 'missing route $path');
    }
  });

  test('the retired subscription path is absent', () {
    expect(collectRoutePaths(), isNot(contains('/settings/subscription')));
  });

  Future<SettingsEntitlementSnapshot> deletionSnapshot(
    WidgetTester tester,
    Entitlement entitlement,
  ) async {
    final routes = Provider(
      (ref) => GoRouter(
        initialLocation: '/settings/account/delete',
        routes: settingsRoutes(ref),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        entitlementProvider.overrideWith((_) => Stream.value(entitlement)),
        isAnonymousProvider.overrideWith((_) async => false),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(routes);
    addTearDown(router.dispose);
    await container.read(entitlementProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: appLightTheme(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return tester
        .widget<DeleteAccountPage>(find.byType(DeleteAccountPage))
        .entitlement;
  }

  testWidgets(
      'non-subscription coverage never becomes a renewing deletion plan',
      (tester) async {
    final end = DateTime.utc(2030);
    for (final entitlement in [
      Entitlement(plan: EntitlementPlan.free, passes: {'exam_cse_pro': end}),
      Entitlement(
        plan: EntitlementPlan.free,
        promotions: [CoveragePeriod(id: 'promo_student', endsAt: end)],
      ),
      Entitlement.activeUnknown(productId: 'future-product', expiresAt: end),
    ]) {
      final snapshot = await deletionSnapshot(tester, entitlement);
      expect(snapshot.plan, SettingsEntitlementPlan.free);
      expect(snapshot.willRenew, isFalse);
      expect(snapshot.expiresAt, isNull);
      expect(deleteAccountBillingLine(snapshot), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('canceled paid period survives the deletion route conversion',
      (tester) async {
    final end = DateTime.utc(2030);
    final snapshot = await deletionSnapshot(
      tester,
      Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_cs_monthly',
        expiresAt: end,
        willRenew: false,
      ),
    );
    expect(snapshot.plan, SettingsEntitlementPlan.monthly);
    expect(snapshot.willRenew, isFalse);
    expect(snapshot.expiresAt, end);
  });

  group('your own exam from the Settings picker', () {
    late AppDatabase db;
    late ContentDatabase contentDb;

    setUp(() async {
      db = inMemoryDatabase();
      contentDb = openTestContentDatabase();
      await DriftSettingsRepository(db).recordPolicyAcceptance();
      final prefs = AppPreferencesRepository(db);
      await prefs.setPassedAgeGate(value: true);
      await prefs.setSelectedExamId('exam_cse_pro');
      await prefs.setCompletedOnboarding(value: true);
      await seedContentExam(
        contentDb,
        examId: 'exam_cse_pro',
        code: 'CSE',
        name: 'Civil Service Exam',
        shortName: 'CSE Professional',
      );
      await seedContentSubject(
        contentDb,
        subjectId: 's1',
        examId: 'exam_cse_pro',
        name: 'Mathematics',
      );
      await seedContentTopic(
        contentDb,
        topicId: 't1',
        subjectId: 's1',
        name: 'Algebra',
      );
      // Only a topic that holds a question is offered.
      await seedContentQuestion(
        contentDb,
        questionId: 'q1',
        topicId: 't1',
        examId: 'exam_cse_pro',
      );
    });

    tearDown(() => db.close());

    Future<GoRouter> pumpSettingsPicker(
      WidgetTester tester, {
      Entitlement entitlement = const Entitlement.free(),
    }) async {
      final catalog = await tester
          .runAsync(() => ExamCatalogRepository(contentDb).watchAll().first);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(contentDb),
            examPickerCatalogProvider
                .overrideWith((ref) => Stream.value(catalog!)),
            entitlementProvider.overrideWith((_) => Stream.value(entitlement)),
            carryableCountProvider.overrideWith((ref, id) async => 0),
            shippedCustomSubjectTiers(studentTopics: ['t1']),
          ],
          child: const App(flavor: Flavor.dev),
        ),
      );
      await tester.pumpAndSettle();
      final router = ProviderScope.containerOf(
        tester.element(find.byType(App)),
      ).read(routerProvider);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
      unawaited(router.push<Object?>('/settings/exam'));
      await tester.pumpAndSettle();
      unawaited(router.push<Object?>('/settings/exam/change'));
      await tester.pumpAndSettle();
      return router;
    }

    // Pushed pages do not change the router's address, so read the top page.
    String location(GoRouter router) =>
        router.routerDelegate.currentConfiguration.last.matchedLocation;

    testWidgets('the row opens the Settings name step, not onboarding',
        (tester) async {
      final router = await pumpSettingsPicker(tester);
      expect(location(router), '/settings/exam/change');
      await tester.tap(find.text("My exam isn't listed"));
      await tester.pumpAndSettle();
      expect(location(router), '/settings/exam/custom/name');
      expect(find.byType(CustomTrackNameStep), findsOneWidget);
      expect(find.text('What are you studying for?'), findsOneWidget);
    });

    testWidgets(
        'the subjects step with no name goes to the exam change page, and '
        'the name step passes the name without putting it in the address',
        (tester) async {
      final router = await pumpSettingsPicker(tester);
      unawaited(router.push<String>('/settings/exam/custom/subjects'));
      await tester.pumpAndSettle();
      expect(location(router), '/settings/exam/change');
      expect(find.text('What does it cover?'), findsNothing);
      await tester.tap(find.text("My exam isn't listed"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My Exam');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(location(router), '/settings/exam/custom/subjects');
      expect(find.text('What does it cover?'), findsOneWidget);
      expect(
        GoRouterState.of(tester.element(find.text('What does it cover?')))
            .uri
            .toString(),
        '/settings/exam/custom/subjects',
      );
    });

    /// Name, then subjects, then Continue: the whole new-exam path.
    Future<void> makeExam(WidgetTester tester, GoRouter router) async {
      final prefs = AppPreferencesRepository(db);
      await tester.tap(find.text("My exam isn't listed"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My Exam');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(location(router), '/settings/exam/custom/subjects');
      expect(find.text('What does it cover?'), findsOneWidget);
      await tester.tap(find.text('Mathematics'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      // Whatever the steps did, onboarding is still done.
      expect(await prefs.hasCompletedOnboarding(), isTrue);
    }

    testWidgets(
        'a free student makes an exam, onboarding stays complete, and Settings '
        'is shown again with it chosen', (tester) async {
      final router = await pumpSettingsPicker(tester);
      final prefs = AppPreferencesRepository(db);
      await makeExam(tester, router);
      expect(find.byType(CenteredDialog), findsNothing);
      expect(location(router), '/settings/exam');
      expect(find.byType(ExamPage), findsOneWidget);
      expect(await prefs.hasCompletedOnboarding(), isTrue);
      final saved = await prefs.selectedExamId();
      expect(saved, startsWith('exam_custom_'));
      final tracks = await db.select(db.customTrackMetaLocal).get();
      expect(tracks.map((t) => (t.examId, t.name)), [(saved, 'My Exam')]);
    });

    final paying = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_cs_monthly',
      expiresAt: DateTime.utc(2030),
    );
    final studentPlan = Entitlement(
      plan: EntitlementPlan.monthly,
      productId: 'pantas_pro_monthly',
      expiresAt: DateTime.utc(2030),
    );
    // The old "On <name> you'll be on Free" dialog is gone for every case.
    const oldWarning = 'Your plan stays with your account';

    testWidgets(
        'a paying student making a Student-level exam on a Civil Service plan '
        'switches with no warning', (tester) async {
      final router = await pumpSettingsPicker(tester, entitlement: paying);
      final prefs = AppPreferencesRepository(db);
      await makeExam(tester, router);
      expect(find.text(oldWarning), findsNothing);
      expect(find.byType(CenteredDialog), findsNothing);
      expect(location(router), '/settings/exam');
      expect(await prefs.selectedExamId(), startsWith('exam_custom_'));
      expect(await prefs.hasCompletedOnboarding(), isTrue);
    });

    group('an exam already under Your exams', () {
      setUp(() async {
        await seedContentExam(
          contentDb,
          examId: 'exam_custom_x',
          code: 'custom',
          name: 'Bar Exam',
          shortName: 'Bar Exam',
          isCustom: true,
        );
        await db.into(db.customTrackMetaLocal).insert(
              CustomTrackMetaLocalCompanion.insert(
                examId: 'exam_custom_x',
                name: 'Bar Exam',
              ),
            );
      });

      /// Gives Bar Exam a General Information topic, which lifts it to Civil
      /// Service. The topic id is the one the shipped table places there.
      Future<void> addCivilServiceTopic() async {
        await seedContentSubject(
          contentDb,
          subjectId: 's_gi',
          examId: 'exam_cse_pro',
          name: 'General Information',
        );
        await seedContentTopic(
          contentDb,
          topicId: 'topic_upcat_philippine_constitution',
          subjectId: 's_gi',
          name: 'Philippine Constitution',
        );
        await seedContentQuestion(
          contentDb,
          questionId: 'q_gi',
          topicId: 'topic_upcat_philippine_constitution',
          examId: 'exam_cse_pro',
        );
      }

      Future<void> startOnUpcat() async {
        await seedContentExam(
          contentDb,
          examId: 'exam_upcat',
          code: 'UPCAT',
          name: 'UPCAT',
          shortName: 'UPCAT',
        );
        await AppPreferencesRepository(db).setSelectedExamId('exam_upcat');
      }

      testWidgets(
          'a lower or same tier keeps Pro with no warning on a Civil Service '
          'plan', (tester) async {
        final router = await pumpSettingsPicker(tester, entitlement: paying);
        await tester.tap(find.text('Bar Exam'));
        await tester.pumpAndSettle();
        expect(find.text(oldWarning), findsNothing);
        expect(find.byType(CenteredDialog), findsNothing);
        expect(location(router), '/settings/exam');
        expect(
          await AppPreferencesRepository(db).selectedExamId(),
          'exam_custom_x',
        );
      });

      testWidgets('the same tier on a Civil Service exam shows nothing',
          (tester) async {
        await addCivilServiceTopic();
        final router = await pumpSettingsPicker(tester, entitlement: paying);
        await tester.tap(find.text('Bar Exam'));
        await tester.pumpAndSettle();
        expect(find.byType(CenteredDialog), findsNothing);
        expect(location(router), '/settings/exam');
        expect(
          await AppPreferencesRepository(db).selectedExamId(),
          'exam_custom_x',
        );
      });

      testWidgets('a Student plan moving to a Student-level exam sees nothing',
          (tester) async {
        await startOnUpcat();
        final router =
            await pumpSettingsPicker(tester, entitlement: studentPlan);
        await tester.tap(find.text('Bar Exam'));
        await tester.pumpAndSettle();
        expect(find.byType(CenteredDialog), findsNothing);
        expect(location(router), '/settings/exam');
        expect(
          await AppPreferencesRepository(db).selectedExamId(),
          'exam_custom_x',
        );
      });

      testWidgets(
          'a higher-tier custom exam shows the upgrade path, and Switch on '
          'Free completes the switch', (tester) async {
        await addCivilServiceTopic();
        await startOnUpcat();
        final router =
            await pumpSettingsPicker(tester, entitlement: studentPlan);
        await tester.tap(find.text('Bar Exam'));
        await tester.pumpAndSettle();
        expect(location(router), startsWith('/settings/exam/upgrade'));
        expect(find.text('Bar Exam has its own price tier'), findsOneWidget);
        expect(find.byType(CenteredDialog), findsNothing);
        expect(
          await AppPreferencesRepository(db).selectedExamId(),
          'exam_upcat',
        );
        await tester.tap(find.text('Switch on Free'));
        await tester.pumpAndSettle();
        expect(location(router), '/settings/exam');
        expect(
          await AppPreferencesRepository(db).selectedExamId(),
          'exam_custom_x',
        );
      });

      testWidgets('a pass holder still sees the pass warning', (tester) async {
        final router = await pumpSettingsPicker(
          tester,
          entitlement: Entitlement(
            plan: EntitlementPlan.free,
            passes: {'exam_cse_pro': DateTime.utc(2030)},
          ),
        );
        await tester.tap(find.text('Bar Exam'));
        await tester.pumpAndSettle();
        expect(
          find.text('Your pass stays with CSE Professional'),
          findsOneWidget,
        );
        expect(
          find.textContaining("On Bar Exam you'll be on Free."),
          findsOneWidget,
        );
        expect(
          await AppPreferencesRepository(db).selectedExamId(),
          'exam_cse_pro',
        );
        await tester.tap(
          find.descendant(
            of: find.byType(CenteredDialog),
            matching: find.text('Switch'),
          ),
        );
        await tester.pumpAndSettle();
        expect(location(router), '/settings/exam');
        expect(
          await AppPreferencesRepository(db).selectedExamId(),
          'exam_custom_x',
        );
        expect(location(router), isNot(startsWith('/settings/exam/upgrade')));
      });

      testWidgets('a free student is not warned', (tester) async {
        final router = await pumpSettingsPicker(tester);
        await tester.tap(find.text('Bar Exam'));
        await tester.pumpAndSettle();
        expect(find.byType(CenteredDialog), findsNothing);
        expect(location(router), '/settings/exam');
        expect(
          await AppPreferencesRepository(db).selectedExamId(),
          'exam_custom_x',
        );
      });
    });
  });
}
