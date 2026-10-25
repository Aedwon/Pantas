import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/presentation/onboarding_name_step.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';

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

  testWidgets('the step requires a name without Skip', (tester) async {
    await pumpStep(tester);

    expect(find.text('What should we call you?'), findsOneWidget);
    expect(
      find.text(
        "We'll use this to greet you across the app. A nickname is fine.",
      ),
      findsOneWidget,
    );
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
  });

  testWidgets('the name field has a programmatic label', (tester) async {
    await pumpStep(tester);

    expect(find.bySemanticsLabel('Name'), findsOneWidget);
  });

  testWidgets('Done is disabled until something is typed', (tester) async {
    await pumpStep(tester);

    final doneButton =
        tester.widget<PantasButton>(find.widgetWithText(PantasButton, 'Done'));
    expect(doneButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Aedwon');
    await tester.pump();

    final enabledDoneButton =
        tester.widget<PantasButton>(find.widgetWithText(PantasButton, 'Done'));
    expect(enabledDoneButton.onPressed, isNotNull);
  });

  testWidgets('Done stores the name without completing onboarding',
      (tester) async {
    var completed = false;
    await pumpStep(tester, onCompleted: () => completed = true);

    await tester.enterText(find.byType(TextField), 'Aedwon');
    await tester.pump();

    await tester.tap(find.widgetWithText(PantasButton, 'Done'));
    await tester.pumpAndSettle();

    final repo = DriftSettingsRepository(db);
    final settings = await repo.readUserSettings();
    expect(settings.name, 'Aedwon');

    final appPrefsRepo = AppPreferencesRepository(db);
    expect(await appPrefsRepo.hasCompletedOnboarding(), isFalse);
    expect(completed, isTrue);
  });

  testWidgets('name is trimmed and limits input to forty characters',
      (tester) async {
    await pumpStep(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.maxLength, 40);
    expect(field.textCapitalization, TextCapitalization.words);
    await tester.enterText(find.byType(TextField), '  Aedwon  ');
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(
      (await DriftSettingsRepository(db).readUserSettings()).name,
      'Aedwon',
    );
  });
  testWidgets('returning to Name restores the saved name', (tester) async {
    await DriftSettingsRepository(db).updateName('Aedwon');
    await pumpStep(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Aedwon',
    );
  });
}
