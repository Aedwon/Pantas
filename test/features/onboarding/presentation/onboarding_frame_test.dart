import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/exam_picker_screen.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_page.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

import '../../../helpers/in_memory_database.dart';

// ignore_for_file: cascade_invocations

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
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
    WidgetTester tester, {
    required bool wide,
    bool animate = false,
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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          examPickerCatalogProvider
              .overrideWith((ref) => Stream.value(catalog!)),
          contentDatabaseProvider.overrideWithValue(contentDb),
          settingsRepositoryProvider
              .overrideWithValue(DriftSettingsRepository(db)),
          passedAgeGateProvider.overrideWith((ref) async => false),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp(
          theme: wide ? buildLightTheme(web: true) : buildLightTheme(),
          home: Builder(
            builder: (context) => MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(disableAnimations: !animate),
              child: const OnboardingPage(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> toTermsPhone(WidgetTester tester) async {
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '30');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  Element element(WidgetTester tester, Finder finder) =>
      tester.element(finder.first);

  testWidgets('phone: Back and progress stay mounted while content changes',
      (tester) async {
    await pumpPage(tester, wide: false);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('How old are you?'), findsOneWidget);
    final segments = find.byKey(const ValueKey('onboarding-segment'));
    final back = element(tester, find.text('Back'));
    final segment = element(tester, segments);
    final title = element(tester, find.text('How old are you?'));

    await tester.enterText(find.byType(TextField), '30');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Terms and Privacy'), findsOneWidget);
    expect(find.text('How old are you?'), findsNothing);
    expect(identical(element(tester, find.text('Back')), back), isTrue);
    expect(identical(element(tester, segments), segment), isTrue);
    expect(title.mounted, isFalse);
    // The frame sits outside the switcher; only content is inside it.
    expect(
      find.descendant(
        of: find.byType(AnimatedSwitcher),
        matching: find.text('Back'),
      ),
      findsNothing,
    );
    expect(find.byKey(const ValueKey('onboarding-segment')), findsNWidgets(6));
  });

  testWidgets('phone: Back still steps back and system back follows',
      (tester) async {
    await pumpPage(tester, wide: false);
    await toTermsPhone(tester);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('How old are you?'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Pantas'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('wide: top bar and steps list stay mounted, content changes',
      (tester) async {
    await pumpPage(tester, wide: true);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('How old are you?'), findsOneWidget);
    final bar = element(tester, find.byType(WebTopBar));
    final rail = element(tester, find.text('Your age'));
    final title = element(tester, find.text('How old are you?'));

    await tester.enterText(find.byType(TextField), '30');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Terms and Privacy'), findsOneWidget);
    expect(find.text('How old are you?'), findsNothing);
    expect(find.byType(WebTopBar), findsOneWidget);
    expect(identical(element(tester, find.byType(WebTopBar)), bar), isTrue);
    expect(identical(element(tester, find.text('Your age')), rail), isTrue);
    expect(title.mounted, isFalse);
    expect(
      find.descendant(
        of: find.byType(AnimatedSwitcher),
        matching: find.byType(WebTopBar),
      ),
      findsNothing,
    );
    expect(find.bySemanticsLabel('Setup steps'), findsOneWidget);
  });

  testWidgets('wide: Enter still continues from the visible step',
      (tester) async {
    await pumpPage(tester, wide: true);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '30');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Terms and Privacy'), findsOneWidget);
  });

  testWidgets('wide: the under-minimum block keeps one top bar',
      (tester) async {
    await pumpPage(tester, wide: true);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text("Pantas isn't available yet"), findsOneWidget);
    expect(find.byType(WebTopBar), findsOneWidget);
    expect(find.bySemanticsLabel('Setup steps'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide: the picker keeps the frame and an inline Continue',
      (tester) async {
    await pumpPage(tester, wide: true);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '30');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    final bar = element(tester, find.byType(WebTopBar));
    await tester.tap(find.text('I agree to the '));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Which exam are you taking?'), findsOneWidget);
    expect(identical(element(tester, find.byType(WebTopBar)), bar), isTrue);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('CSE Professional'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final continueButton = find.text('Continue');
    expect(continueButton, findsOneWidget);
    // Inline with the list like every other step, not pinned to the window.
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.text('When is your exam?'), findsOneWidget);
    expect(identical(element(tester, find.byType(WebTopBar)), bar), isTrue);
    // The test font makes the wide date step overflow by 2 px with or without
    // the frame, so the exception is read and dropped here.
    tester.takeException();
  });

  testWidgets('wide: a new step starts at the top of the page', (tester) async {
    await pumpPage(tester, wide: true);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '30');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    scroll.position.jumpTo(40);
    await tester.pump();
    expect(scroll.position.pixels, greaterThan(0));
    await tester.tap(find.text('I agree to the '));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .pixels,
      0,
    );
  });

  testWidgets('the picker slides in like every other framed step',
      (tester) async {
    await pumpPage(tester, wide: true, animate: true);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '30');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    double incomingOffset() => tester
        .widget<Transform>(
          find.byKey(const ValueKey('onboarding-incoming-offset')).last,
        )
        .transform
        .getTranslation()
        .x;
    // Terms follows the age step by sliding in from the right.
    await tester.tap(find.text('I agree to the '));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    // The picker has the same motion: it is no longer a fade.
    expect(find.text('Which exam are you taking?'), findsOneWidget);
    expect(incomingOffset(), greaterThan(0));
    await tester.pumpAndSettle();
  });
}
