import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/board_button.dart';
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

  Future<void> pumpPage(WidgetTester tester) async {
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
          home: const OnboardingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the flow runs welcome, age gate, picker, date, name',
      (tester) async {
    await pumpPage(tester);

    // Step 1: Welcome
    expect(find.text('Build your study plan'), findsOneWidget);
    await tester.tap(find.widgetWithText(BoardButton, 'Get started'));
    await tester.pumpAndSettle();

    // Step 2: Age gate
    expect(find.text('Quick check'), findsOneWidget);
    final agePicker = find.byType(CupertinoPicker);
    await tester.drag(agePicker, const Offset(0, -32));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    // Step 3: Exam picker
    expect(find.text('Choose your exam'), findsOneWidget);
    await tester.tap(find.text('Civil Service Exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    // Step 4: Exam date
    expect(find.text('When is your exam?'), findsOneWidget);
    await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
    await tester.pumpAndSettle();

    // Step 5: Name
    expect(find.text('What should we call you?'), findsOneWidget);
  });
}
