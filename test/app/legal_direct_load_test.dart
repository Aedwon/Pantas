import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/app/app.dart';
import 'package:pantas/app/flavor.dart';
import 'package:pantas/app/router.dart';
import 'package:pantas/app/start_location.dart';
import 'package:pantas/app/startup_gates.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/legal/presentation/legal_document_page.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';

import '../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

/// Outside sites can link straight to a legal page. It opens as the first
/// page, so the visitor's onboarding state decides its layout and Back.
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

  /// Starts the app the way the web build does for [address]: the start is
  /// remembered, the gates settle, and only then does the first page mount.
  Future<ProviderContainer> openDirectly(
    WidgetTester tester,
    String address, {
    required bool wide,
  }) async {
    final catalog = await tester
        .runAsync(() => ExamCatalogRepository(contentDb).watchAll().first);
    if (wide) {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        examPickerCatalogProvider.overrideWith((ref) => Stream.value(catalog!)),
        contentDatabaseProvider.overrideWithValue(contentDb),
        entitlementProvider.overrideWith(
          (_) => Stream.value(const Entitlement.free()),
        ),
      ],
    );
    addTearDown(container.dispose);
    rememberStartLocation(
      Uri.parse('https://app.example.test$address'),
      isWeb: true,
    );
    await tester.runAsync(
      () => settleGatesBeforeFirstPage(
        container,
        startLocation: initialRouterLocation,
      ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
    return container;
  }

  String pathOf(ProviderContainer container) => container
      .read(routerProvider)
      .routerDelegate
      .currentConfiguration
      .last
      .matchedLocation;

  group('a visitor who has not finished onboarding', () {
    testWidgets('on a phone sees the onboarding Back and goes to onboarding',
        (tester) async {
      final container = await openDirectly(tester, '/legal/terms', wide: false);
      expect(pathOf(container), '/legal/terms');
      expect(find.text('Use of the app'), findsOneWidget);
      expect(find.text('About'), findsNothing);
      await tester.tap(find.text('Back'));
      // Onboarding animates without end, so settle by time.
      await tester.pump(const Duration(seconds: 1));
      expect(pathOf(container), '/onboarding');
    });

    testWidgets('on wide web sees the onboarding layout and goes to onboarding',
        (tester) async {
      final container = await openDirectly(tester, '/legal/terms', wide: true);
      expect(find.byType(OnboardingLegalPage), findsOneWidget);
      expect(find.byType(SettingsPanePage), findsNothing);
      await tester.tap(find.text('Back'));
      // Onboarding animates without end, so settle by time.
      await tester.pump(const Duration(seconds: 1));
      expect(pathOf(container), '/onboarding');
    });
  });

  group('a student who has finished onboarding', () {
    setUp(finishOnboarding);

    testWidgets('on a phone keeps Back to About and goes to About',
        (tester) async {
      final container = await openDirectly(tester, '/legal/terms', wide: false);
      expect(pathOf(container), '/legal/terms');
      expect(find.text('Use of the app'), findsOneWidget);
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(pathOf(container), '/settings/about');
    });

    testWidgets('on wide web keeps the Settings layout and goes to About',
        (tester) async {
      final container = await openDirectly(tester, '/legal/terms', wide: true);
      expect(find.byType(SettingsPanePage), findsOneWidget);
      expect(find.byType(OnboardingLegalPage), findsNothing);
      await tester.tap(find.text('About').first);
      await tester.pumpAndSettle();
      expect(pathOf(container), '/settings/about');
    });

    testWidgets(
        'the teen notice address opens the Privacy Policy, not not-found',
        (tester) async {
      final container = await openDirectly(tester, '/legal/teens', wide: false);
      expect(pathOf(container), '/legal/privacy');
      expect(find.text('Legal page not found'), findsNothing);
      expect(find.text('What we collect'), findsOneWidget);
    });

    testWidgets('an unknown document says so and still leads out',
        (tester) async {
      final container =
          await openDirectly(tester, '/legal/not-a-document', wide: false);
      expect(find.text('Legal page not found'), findsOneWidget);
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(pathOf(container), '/settings/about');
    });
  });
}
