import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/subject.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/scope_picker.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
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
        'Untick what you don’t need. It gets removed from your plan, '
        'and your answers on it won’t be deleted.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('everything is ticked for a listed exam with no exclusions',
      (tester) async {
    await pumpPage(tester);

    final picker = tester.widget<ScopePicker>(find.byType(ScopePicker));
    expect(picker.selectedIds, {'les_1', 'top_2'});
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
    expect(picker.selectedIds, {'top_2'});
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
}
