import 'package:cse_cet_reviewer/app/app.dart';
import 'package:cse_cet_reviewer/app/flavor.dart';
import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';

void main() {
  testWidgets('App boots and renders the navigation shell', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'cse',
            code: 'CSE',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await AppPreferencesRepository(db).setPassedAgeGate(value: true);
    await AppPreferencesRepository(db).setSelectedExamId('cse');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Study'), findsWidgets);
    expect(find.text('Quiz'), findsWidgets);
    expect(find.text('More'), findsWidgets);
    expect(find.text('Learn'), findsNothing);
  });

  testWidgets('App applies selected device theme mode', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await DriftSettingsRepository(db).updateThemePreference(
      ThemePreference.dark,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const App(flavor: Flavor.dev),
      ),
    );
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
