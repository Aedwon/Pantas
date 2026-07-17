import 'dart:convert';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_checkbox.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/whats_included_page.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'exam_1',
            code: 'EX1',
            name: 'Civil Service Exam',
            shortName: 'CSE',
            language: 'en',
          ),
        );
    await db.into(db.subjects).insert(
          SubjectsCompanion.insert(
            id: 'sub_1',
            examId: 'exam_1',
            name: 'Mathematics',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'top_1',
            subjectId: 'sub_1',
            name: 'Algebra',
            ordering: 1,
          ),
        );
    await db.into(db.topics).insert(
          TopicsCompanion.insert(
            id: 'top_2',
            subjectId: 'sub_1',
            name: 'Geometry',
            ordering: 2,
          ),
        );
    await db.into(db.lessons).insert(
          LessonsCompanion.insert(
            id: 'les_1',
            topicId: 'top_1',
            title: 'Linear Equations',
            summary: 'Summary',
            bodyJson: '[]',
            estimatedMinutes: 5,
            ordering: const Value(1),
          ),
        );

    await AppPreferencesRepository(db).setSelectedExamId('exam_1');
  });

  tearDown(() => db.close());

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          activeExamFocusProvider.overrideWith(
            (ref) async => ActiveExamFocus.selected(
              const Exam(
                id: 'exam_1',
                code: 'EX1',
                name: 'Civil Service Exam',
                shortName: 'CSE',
                language: 'en',
                isActive: true,
                isCustom: false,
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

  testWidgets('the screen states the rule before the list', (tester) async {
    await pumpPage(tester);

    expect(
      find.text(
        "Unticking something hides it. Nothing you've done is deleted.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('everything is ticked for a listed exam with no exclusions',
      (tester) async {
    await pumpPage(tester);

    final checkboxFinder = find.byWidgetPredicate((w) => w is InkCheckbox);
    final checkboxes = tester.widgetList<InkCheckbox>(checkboxFinder);
    for (final cb in checkboxes) {
      expect(cb.state, equals(InkCheckState.on));
    }
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

  testWidgets('unticking one topic drops its subject to the dash',
      (tester) async {
    await pumpPage(tester);

    await tester.tap(find.text('Algebra'));
    await tester.pumpAndSettle();

    final checkboxFinder = find.byWidgetPredicate((w) => w is InkCheckbox);
    final checkboxes = tester.widgetList<InkCheckbox>(checkboxFinder).toList();
    // Subject row checkbox is index 0
    expect(checkboxes[0].state, equals(InkCheckState.partial));
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
