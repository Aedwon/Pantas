import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/data/repos/practice_preferences_repository.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_screen.dart';

import '../../../helpers/in_memory_database.dart';
import 'practice_picker_screen_test.dart' show index;

void main() {
  for (final dark in [false, true]) {
    testWidgets('wide picker selection and split dark=$dark', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            practicePreferencesRepositoryProvider
                .overrideWithValue(PracticePreferencesRepository(db)),
            practiceIndexProvider('e').overrideWith((_) async => index),
            practicePaceProvider('e').overrideWith((_) async => 50000),
          ],
          child: MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.fromLTRB(288, 28, 44, 44),
                child: PracticePickerScreen(examId: 'e'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nothing picked yet'), findsOneWidget);
      await tester.tap(find.text('Algebra'));
      await tester.pumpAndSettle();
      expect(find.text('2 lessons picked'), findsOneWidget);
      expect(find.text('Split by lesson'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Your quiz')).dx,
        greaterThan(tester.getTopLeft(find.text('MATHEMATICS')).dx),
      );
      await tester.tap(find.text('Total time'));
      await tester.pumpAndSettle();
      expect(find.text('You set the time. Questions follow.'), findsOneWidget);
      await tester.tap(find.text('Adjust'));
      await tester.pumpAndSettle();
      expect(find.text('Reset'), findsOneWidget);
      expect(find.byTooltip('Increase Algebra'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
