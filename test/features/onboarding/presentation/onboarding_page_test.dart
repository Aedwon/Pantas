import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
      examId: 'cse',
      code: 'CSE',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
  });

  tearDown(() => db.close());

  Future<void> pumpPage(
    WidgetTester tester, {
    bool disableAnimations = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          settingsRepositoryProvider.overrideWithValue(
            DriftSettingsRepository(db),
          ),
          passedAgeGateProvider.overrideWith((ref) async => false),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.needsSelection(),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: disableAnimations),
            child: const OnboardingPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the flow runs welcome, age gate, consent, picker, date, name',
      (tester) async {
    await pumpPage(tester);

    // Step 1: Welcome
    expect(find.text('Welcome to Pantas'), findsOneWidget);
    await tester.tap(find.widgetWithText(PantasButton, 'Get Started'));
    await tester.pumpAndSettle();

    // Step 2: Age gate
    expect(find.text('When were you born?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 3: Consent
    expect(find.text('Terms and Privacy'), findsOneWidget);
    await tester.tap(find.text('I agree to the '));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 4: Exam picker
    expect(find.text('Choose your exam'), findsOneWidget);
    await tester.tap(find.text('Civil Service Exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    // Step 5: Exam date
    expect(find.text('When is your exam?'), findsOneWidget);
    // Pick next year so this flow remains valid even on the last day of a
    // month.
    await tester.drag(
      find.byKey(const ValueKey('year_picker')),
      const Offset(0, -32),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    // Step 6: Name
    expect(find.text('What should we call you?'), findsOneWidget);
  });

  testWidgets('Age and Terms Back links match system back', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Pantas'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Terms and Privacy'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('When were you born?'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('When were you born?'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Pantas'), findsOneWidget);
  });

  testWidgets('step push follows the 380ms O_Flow curve', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Get Started'));
    await tester.pump();
    expect(
      tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
      const Duration(milliseconds: 380),
    );
    await tester.pump(const Duration(milliseconds: 190));
    final move = tester.widget<Transform>(
      find.byKey(const ValueKey('onboarding-incoming-offset')).last,
    );
    expect(move.transform.storage[12], closeTo(2.00213, .03));
    await tester.pump(const Duration(milliseconds: 190));
    expect(
      tester
          .widget<Transform>(
            find.byKey(const ValueKey('onboarding-incoming-offset')).last,
          )
          .transform
          .storage[12],
      0,
    );
  });

  testWidgets('step transitions are instant when animations are disabled',
      (tester) async {
    await pumpPage(tester, disableAnimations: true);

    final switcher = tester.widget<AnimatedSwitcher>(
      find.byType(AnimatedSwitcher),
    );
    expect(switcher.duration, Duration.zero);
  });
}
