import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_checkbox.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:cse_cet_reviewer/features/onboarding/presentation/steps/custom_track_subjects_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();

    // Exam 1
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam1',
            code: 'EX1',
            name: 'Exam 1',
            shortName: 'EX1',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'sub1',
            examId: 'exam1',
            name: 'Mathematics',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'top1',
            subjectId: 'sub1',
            name: 'Algebra',
            ordering: 1,
          ),
        );

    // Exam 2 sharing Mathematics subject name + carrying Science subject
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam2',
            code: 'EX2',
            name: 'Exam 2',
            shortName: 'EX2',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'sub2',
            examId: 'exam2',
            name: 'Mathematics',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'top2',
            subjectId: 'sub2',
            name: 'Geometry',
            ordering: 2,
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'sub3',
            examId: 'exam2',
            name: 'Science',
            ordering: 2,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'top3',
            subjectId: 'sub3',
            name: 'Biology',
            ordering: 1,
          ),
        );
  });

  tearDown(() => db.close());

  group('CustomTrackNameStep', () {
    testWidgets('the name is required', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: const CustomTrackNameStep(),
        ),
      );
      await tester.pump();

      var button = tester.widget<BoardButton>(
        find.widgetWithText(BoardButton, 'Continue'),
      );
      expect(button.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'PUP CET');
      await tester.pump();

      button = tester.widget<BoardButton>(
        find.widgetWithText(BoardButton, 'Continue'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('whitespace is not a name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: const CustomTrackNameStep(),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      final button = tester.widget<BoardButton>(
        find.widgetWithText(BoardButton, 'Continue'),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('CustomTrackSubjectsStep', () {
    Future<void> pumpSubjectsStep(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const CustomTrackSubjectsStep(name: 'PUP CET'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the subject list is the corpus, deduplicated', (tester) async {
      await pumpSubjectsStep(tester);

      expect(find.text('Mathematics'), findsOneWidget);
      expect(find.text('Science'), findsOneWidget);
    });

    testWidgets('every subject arrives ticked', (tester) async {
      await pumpSubjectsStep(tester);

      final checkboxFinder = find.byWidgetPredicate((w) => w is InkCheckbox);
      final checkboxes = tester.widgetList<InkCheckbox>(checkboxFinder);
      expect(checkboxes.length, equals(2));
      for (final cb in checkboxes) {
        expect(cb.state, equals(InkCheckState.on));
      }
    });

    testWidgets('unticking everything is allowed and creates a track',
        (tester) async {
      await pumpSubjectsStep(tester);

      // Untick Mathematics
      await tester.tap(find.text('Mathematics'));
      await tester.pump();

      // Untick Science
      await tester.tap(find.text('Science'));
      await tester.pump();

      final button = tester.widget<BoardButton>(
        find.widgetWithText(BoardButton, 'Continue'),
      );
      expect(button.onPressed, isNotNull);

      await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
      await tester.pumpAndSettle();

      final exams = await db.select(db.exams).get();
      final custom = exams.where((e) => e.isCustom).firstOrNull;
      expect(custom, isNotNull);
      expect(custom!.name, equals('PUP CET'));

      // All topics should be excluded since none were included
      final exclusions = await db.select(db.trackScopeLocal).get();
      expect(exclusions.length, equals(3));
    });

    testWidgets('continuing creates the track and sets active exam',
        (tester) async {
      await pumpSubjectsStep(tester);

      await tester.tap(find.widgetWithText(BoardButton, 'Continue'));
      await tester.pumpAndSettle();

      final exams = await db.select(db.exams).get();
      final custom = exams.where((e) => e.isCustom).firstOrNull;
      expect(custom, isNotNull);
      expect(custom!.name, equals('PUP CET'));

      final selectedId = await AppPreferencesRepository(db).selectedExamId();
      expect(selectedId, equals(custom.id));
    });
  });
}
