import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/card_footer.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_tag.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_name_step.dart';
import 'package:pantas/features/onboarding/presentation/steps/custom_track_subjects_step.dart';

import '../../../helpers/custom_subject_tiers_fixture.dart';
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
    // Only a topic that holds a question is offered.
    for (final (id, topic, exam) in [
      ('q1', 'top1', 'exam1'),
      ('q2', 'top2', 'exam2'),
      ('q3', 'top3', 'exam2'),
    ]) {
      await seedContentQuestion(
        contentDb,
        questionId: id,
        topicId: topic,
        examId: exam,
      );
    }
    // A subject the tier table places above Student.
    await seedContentSubject(
      contentDb,
      subjectId: 'sub5',
      examId: 'exam2',
      name: 'General Information',
      ordering: 4,
    );
    await seedContentTopic(
      contentDb,
      topicId: 'topic_upcat_philippine_constitution',
      subjectId: 'sub5',
      name: 'Constitution',
    );
    await seedContentQuestion(
      contentDb,
      questionId: 'q5',
      topicId: 'topic_upcat_philippine_constitution',
      examId: 'exam2',
    );
    // Held in the catalog with no questions: a topic inside Mathematics, and
    // a whole subject.
    await seedContentTopic(
      contentDb,
      topicId: 'top4',
      subjectId: 'sub1',
      name: 'Trigonometry',
      ordering: 2,
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sub4',
      examId: 'exam1',
      name: 'Verbal Ability',
      ordering: 3,
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top5',
      subjectId: 'sub4',
      name: 'Analogies',
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

    testWidgets('a name holds at most 60 characters and shows no counter',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: const CustomTrackNameStep(),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'A' * 70);
      await tester.pump();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'A' * 60,
      );
      expect(find.text('60/60'), findsNothing);
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

    testWidgets('a subject with no questions is not offered', (tester) async {
      await pumpSubjectsStep(tester);

      expect(find.text('Verbal Ability'), findsNothing);
    });

    testWidgets('a topic with no questions is left out of the track',
        (tester) async {
      await pumpSubjectsStep(tester);

      await tester.tap(find.text('Mathematics'));
      await tester.pump();
      await tester.tap(find.widgetWithText(PantasButton, 'Continue'));
      await tester.pumpAndSettle();

      final id = (await db.select(db.customTrackMetaLocal).get()).single.examId;
      final excluded =
          await CustomTrackRepository(db, contentDb).excludedTopicIds(id);
      expect(excluded, containsAll(['top3', 'top4', 'top5']));
      expect(excluded, isNot(contains('top1')));
      expect(excluded, isNot(contains('top2')));
    });

    testWidgets('no questions at all shows the error, not an empty list',
        (tester) async {
      // The catalog is there, but no question has loaded.
      await contentDb.delete(contentDb.contentQuestions).go();
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

      expect(find.text('Could not load your subjects.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.text('Mathematics'), findsNothing);
      final button = tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, 'Continue'));
      expect(button.onPressed, isNull);
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

  group('CustomTrackSubjectsStep tier', () {
    const student = 'Studying is free. For Pro, this is a Student-level exam.';
    const civil =
        'Studying is free. For Pro, this is a Civil Service-level exam.';

    Future<void> pumpStep(WidgetTester tester, {required bool wide}) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize =
          wide ? const Size(1440, 900) : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(contentDb),
            shippedCustomSubjectTiers(
              studentTopics: ['top1', 'top2', 'top3', 'top4', 'top5'],
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: wide),
            home: const CustomTrackSubjectsStep(name: 'PUP CET'),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final wide in [true, false]) {
      final layout = wide ? 'wide' : 'phone';

      testWidgets('$layout: tiles sit in a card closed by the footer',
          (tester) async {
        await pumpStep(tester, wide: wide);

        expect(find.byType(SelectableTile), findsNWidgets(3));
        expect(
          find.descendant(
            of: find.byType(WebCard),
            matching: find.byType(SelectableTile),
          ),
          findsNWidgets(3),
        );
        expect(
          find.descendant(
            of: find.byType(CardFooter),
            matching: find.text('Continue'),
          ),
          findsOneWidget,
        );
        expect(find.byType(ListRow), findsNothing);
      });

      testWidgets('$layout: only General Information adds the level mark',
          (tester) async {
        await pumpStep(tester, wide: wide);

        expect(find.text('2 topics'), findsOneWidget);
        expect(find.text('1 topic'), findsOneWidget); // Science
        expect(find.text('1 topic · Civil Service-level'), findsOneWidget);
        expect(find.textContaining('Student-level'), findsNothing);
        expect(find.byType(PantasTag), findsNothing);
      });

      testWidgets('$layout: the footer line follows the ticks', (tester) async {
        await pumpStep(tester, wide: wide);
        expect(find.text('Studying is free.'), findsOneWidget);

        await tester.tap(find.text('Mathematics'));
        await tester.pumpAndSettle();
        expect(find.text(student), findsOneWidget);

        await tester.tap(find.text('General Information'));
        await tester.pumpAndSettle();
        expect(find.text(civil), findsOneWidget);
        expect(find.text(student), findsNothing);

        await tester.tap(find.text('General Information'));
        await tester.pumpAndSettle();
        expect(find.text(student), findsOneWidget);
      });
    }

    testWidgets('phone: the footer button keeps its natural width',
        (tester) async {
      await pumpStep(tester, wide: false);
      await tester.tap(find.text('Mathematics'));
      await tester.pumpAndSettle();

      final button = tester.getSize(find.byType(PantasButton));
      final footer = tester.getSize(find.byType(CardFooter));
      expect(button.width, lessThan(footer.width * 0.7));
    });
  });
}
