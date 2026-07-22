import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:cse_cet_reviewer/features/settings/application/settings_providers.dart';
import 'package:cse_cet_reviewer/features/settings/data/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = inMemoryDatabase();
  });

  tearDown(() => db.close());

  Future<void> pumpStep(
    WidgetTester tester, {
    VoidCallback? onCompleted,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          settingsRepositoryProvider.overrideWithValue(
            DriftSettingsRepository(db),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: Scaffold(
            body: OnboardingNameStep(onCompleted: onCompleted ?? () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the step asks for a name and offers a skip', (tester) async {
    await pumpStep(tester);

    expect(find.text('What should we call you?'), findsOneWidget);
    expect(
      find.text(
        "We'll use this to greet you across the app. A nickname is fine.",
      ),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('Done is disabled until something is typed', (tester) async {
    await pumpStep(tester);

    final doneButton =
        tester.widget<BoardButton>(find.widgetWithText(BoardButton, 'Done'));
    expect(doneButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Aedwon');
    await tester.pump();

    final enabledDoneButton =
        tester.widget<BoardButton>(find.widgetWithText(BoardButton, 'Done'));
    expect(enabledDoneButton.onPressed, isNotNull);
  });

  testWidgets('Done stores the name and completes onboarding', (tester) async {
    var completed = false;
    await pumpStep(tester, onCompleted: () => completed = true);

    await tester.enterText(find.byType(TextField), 'Aedwon');
    await tester.pump();

    await tester.tap(find.widgetWithText(BoardButton, 'Done'));
    await tester.pumpAndSettle();

    final repo = DriftSettingsRepository(db);
    final settings = await repo.readUserSettings();
    expect(settings.name, 'Aedwon');

    final appPrefsRepo = AppPreferencesRepository(db);
    expect(await appPrefsRepo.hasCompletedOnboarding(), isTrue);
    expect(completed, isTrue);
  });

  testWidgets('Skip completes onboarding and stores no name', (tester) async {
    var completed = false;
    await pumpStep(tester, onCompleted: () => completed = true);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    final repo = DriftSettingsRepository(db);
    final settings = await repo.readUserSettings();
    expect(settings.name, isNull);

    final appPrefsRepo = AppPreferencesRepository(db);
    expect(await appPrefsRepo.hasCompletedOnboarding(), isTrue);
    expect(completed, isTrue);
  });
}
