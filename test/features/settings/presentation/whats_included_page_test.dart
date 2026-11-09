import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/custom_track_repository.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/settings/presentation/pages/whats_included_page.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'exam_1',
      code: 'EX1',
      name: 'Civil Service Exam',
      shortName: 'CSE',
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sub_1',
      examId: 'exam_1',
      name: 'Mathematics',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top_1',
      subjectId: 'sub_1',
      name: 'Algebra',
    );
    await seedContentTopic(
      contentDb,
      topicId: 'top_2',
      subjectId: 'sub_1',
      name: 'Geometry',
      ordering: 2,
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'les_1',
      topicId: 'top_1',
      title: 'Linear Equations',
      bodyJson: '[]',
      ordering: 1,
    );
    await seedContentLesson(
      contentDb,
      lessonId: 'les_2',
      topicId: 'top_2',
      title: 'Angles',
    );
    for (final (topicId, lessonId) in [
      ('top_1', 'les_1'),
      ('top_2', 'les_2'),
    ]) {
      await seedContentQuestion(
        contentDb,
        questionId: 'question_$lessonId',
        topicId: topicId,
        examId: 'exam_1',
        lessonId: lessonId,
      );
    }

    await AppPreferencesRepository(db).setSelectedExamId('exam_1');
  });

  tearDown(() => db.close());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          contentDatabaseProvider.overrideWithValue(contentDb),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(
              Exam(
                id: 'exam_1',
                code: 'EX1',
                name: 'Civil Service Exam',
                shortName: 'CSE',
                language: 'en',
                isActive: true,
                subjects: [
                  Subject(
                    id: 'sub_1',
                    examId: 'exam_1',
                    name: 'Mathematics',
                    ordering: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const WhatsIncludedPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the last included topic stays selected', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Geometry'));
    await tester.pumpAndSettle();
    final exclusions = await db.select(db.trackScopeLocal).get();
    expect(exclusions.map((e) => e.topicId), ['top_1']);
    expect(find.text('At least one topic stays ticked.'), findsOneWidget);
  });

  testWidgets('the screen has the approved scope footer', (tester) async {
    await pumpPage(tester);

    expect(
      find.text(
        "Untick what you don't need. It gets removed from your plan, "
        "and your answers on it won't be deleted.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('everything is ticked for a listed exam with no exclusions',
      (tester) async {
    await pumpPage(tester);

    final picker = tester.widget<ScopePicker>(find.byType(ScopePicker));
    expect(picker.selectedIds, {'les_1', 'les_2'});
  });

  testWidgets('unticking a topic writes an exclusion', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    final exclusions = await db.select(db.trackScopeLocal).get();
    expect(exclusions.length, equals(1));
    expect(exclusions.first.examId, equals('exam_1'));
    expect(exclusions.first.topicId, equals('top_1'));
  });

  testWidgets('unticking one topic keeps the other topic selected',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    final picker = tester.widget<ScopePicker>(find.byType(ScopePicker));
    expect(picker.selectedIds, {'les_2'});
  });

  testWidgets('re-ticking removes the exclusion', (tester) async {
    await pumpPage(tester);

    // Untick
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    // Re-tick
    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    final exclusions = await db.select(db.trackScopeLocal).get();
    expect(exclusions, isEmpty);
  });

  testWidgets('narrowing deletes no attempt', (tester) async {
    await db.into(db.attemptsLocal).insert(
          AttemptsLocalCompanion.insert(
            id: 'attempt_1',
            examId: 'exam_1',
            startedAt: DateTime.now(),
            completedAt: Value(DateTime.now()),
            itemsJson: jsonEncode([]),
          ),
        );

    await pumpPage(tester);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    final attempts = await db.select(db.attemptsLocal).get();
    expect(attempts.length, equals(1));
  });

  testWidgets('there are no lesson rows', (tester) async {
    await pumpPage(tester);

    expect(find.text('Linear Equations'), findsNothing);
  });

  group('a custom exam', () {
    late String customId;
    late List<(String, Map<String, Object?>)> calls;

    setUp(() async {
      calls = [];
      // Only a topic that holds a question is listed. Trigonometry holds none,
      // and neither does the whole of Verbal Ability.
      await seedContentQuestion(
        contentDb,
        questionId: 'q_1',
        topicId: 'top_1',
        examId: 'exam_1',
      );
      await seedContentQuestion(
        contentDb,
        questionId: 'q_2',
        topicId: 'top_2',
        examId: 'exam_1',
      );
      await seedContentTopic(
        contentDb,
        topicId: 'top_3',
        subjectId: 'sub_1',
        name: 'Trigonometry',
        ordering: 3,
      );
      await seedContentSubject(
        contentDb,
        subjectId: 'sub_2',
        examId: 'exam_1',
        name: 'Verbal Ability',
        ordering: 2,
      );
      await seedContentTopic(
        contentDb,
        topicId: 'top_4',
        subjectId: 'sub_2',
        name: 'Analogies',
      );
      final repo = CustomTrackRepository(db, contentDb);
      customId = await repo.create(
        name: 'PUP CET',
        includedTopicIds: {'top_1', 'top_2', 'top_3', 'top_4'},
      );
      // The student unticked Geometry. Trigonometry was left out when the
      // exam was made, and the picker never shows it.
      await repo.setExcluded(
        examId: customId,
        topicIds: {'top_2', 'top_3'},
      );
      await AppPreferencesRepository(db).setSelectedExamId(customId);
    });

    Future<void> pumpCustomPage(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            contentDatabaseProvider.overrideWithValue(contentDb),
            authStateProvider.overrideWith(
              (ref) => Stream.value(const AuthState.anonymous(uid: 'u1')),
            ),
            studyApiProvider.overrideWithValue(
              StudyApi((name, data) async {
                calls.add((name, data));
                return <String, Object?>{};
              }),
            ),
            activeExamFocusProvider.overrideWith(
              (ref) async => ActiveExamFocus.selected(
                Exam(
                  id: customId,
                  code: customId,
                  name: 'PUP CET',
                  shortName: 'PUP CET',
                  language: 'en',
                  isActive: true,
                  isCustom: true,
                  subjects: [],
                ),
              ),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            home: const WhatsIncludedPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
          .read(authStateProvider.future);
    }

    testWidgets('lists only the topics that hold a question', (tester) async {
      await pumpCustomPage(tester);

      expect(find.text('Algebra'), findsOneWidget);
      expect(find.text('Geometry'), findsOneWidget);
      expect(find.text('Trigonometry'), findsNothing);
      expect(find.text('Verbal Ability'), findsNothing);
      expect(find.text('Analogies'), findsNothing);
    });

    testWidgets('a topic the student excluded is listed, unticked',
        (tester) async {
      await pumpCustomPage(tester);

      final picker = tester.widget<ScopePicker>(find.byType(ScopePicker));
      expect(picker.selectedIds, {'les_1'});
    });

    testWidgets('saving publishes the exam block and keeps what stays hidden',
        (tester) async {
      await pumpCustomPage(tester);

      await tester.tap(find.text('Geometry'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        for (var i = 0; i < 100; i++) {
          if (calls.any((c) => c.$1 == 'setExamSettings')) break;
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
      });

      final sent = calls.firstWhere((c) => c.$1 == 'setExamSettings').$2;
      expect(sent['examId'], customId);
      expect(sent['expectedUid'], 'u1');
      expect(sent['customTrack'], {'name': 'PUP CET'});
      // Geometry is ticked again. Trigonometry has no questions and the
      // student never saw it, so it stays out.
      expect(sent['excludedTopicIds'], ['top_3']);
      expect(
        (await db.select(db.trackScopeLocal).get()).map((e) => e.topicId),
        ['top_3'],
      );
    });
  });
}
