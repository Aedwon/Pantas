import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();

    // Exam 1
    await seedContentExam(
      contentDb,
      examId: 'exam1',
      code: 'EX1',
      name: 'Exam 1',
      shortName: 'EX1',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sub1',
      examId: 'exam1',
      name: 'Mathematics',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top1',
      subjectId: 'sub1',
      name: 'Algebra',
    );

    // Exam 2 sharing Mathematics subject name + carrying Science subject
    await seedContentExam(
      contentDb,
      examId: 'exam2',
      code: 'EX2',
      name: 'Exam 2',
      shortName: 'EX2',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sub2',
      examId: 'exam2',
      name: 'Mathematics',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top2',
      subjectId: 'sub2',
      name: 'Geometry',
      ordering: 2,
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sub3',
      examId: 'exam2',
      name: 'Science',
      ordering: 2,
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top3',
      subjectId: 'sub3',
      name: 'Biology',
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

      var button = tester.widget<PantasButton>(
        find.widgetWithText(PantasButton, 'Continue'),
      );
      expect(button.onPressed, isNull);

      await tester.enterText(find.byType(TextField), 'PUP CET');
      await tester.pump();

      button = tester.widget<PantasButton>(
        find.widgetWithText(PantasButton, 'Continue'),
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

      final button = tester.widget<PantasButton>(
        find.widgetWithText(PantasButton, 'Continue'),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('CustomTrackSubjectsStep', () {
    Future<void> pumpSubjectsStep(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(contentDb),
          ],
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

    testWidgets('every subject arrives unticked', (tester) async {
      await pumpSubjectsStep(tester);

      final button = tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, 'Continue'));
      expect(button.onPressed, isNull);
    });

    testWidgets('continuing creates the track and sets active exam',
        (tester) async {
      await pumpSubjectsStep(tester);

      await tester.tap(find.text('Mathematics'));
      await tester.pump();
      await tester.tap(find.widgetWithText(PantasButton, 'Continue'));
      await tester.pumpAndSettle();

      final exams = await contentDb.select(contentDb.contentExams).get();
      final custom = exams.where((e) => e.isCustom).firstOrNull;
      expect(custom, isNotNull);
      expect(custom!.name, equals('PUP CET'));

      final selectedId = await AppPreferencesRepository(db).selectedExamId();
      expect(selectedId, equals(custom.id));
    });
  });
}
