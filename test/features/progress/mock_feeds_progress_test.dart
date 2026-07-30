import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/progress/application/performance_provider.dart';
import 'package:pantas/features/progress/presentation/widgets/performance_section.dart';

import '../../helpers/in_memory_database.dart';
import '../../helpers/pump_app.dart';

const examId = 'exam_upcat';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
  });

  Future<void> seedSyllabus() async {
    await seedContentTopicWithQuestions(
      contentDb,
      examId: examId,
      subjectId: 'sci',
      topicId: 'chem',
      topicName: 'Chemistry',
      questionIds: ['q_c1', 'q_c2'],
    );
    await seedContentSubject(
      contentDb,
      subjectId: 'sci',
      examId: examId,
      name: 'Science',
      ordering: 0,
    );
    await AppPreferencesRepository(db).setSelectedExamId(examId);
  }

  Future<void> seedAttempt() async {
    await db.into(db.attemptsLocal).insertOnConflictUpdate(
          AttemptsLocalCompanion.insert(
            id: 'att_1',
            examId: examId,
            origin: const Value('practice'),
            startedAt: DateTime(2026, 8),
            completedAt: Value(DateTime(2026, 8, 1, 0, 20)),
            itemsJson: jsonEncode([
              {
                'questionId': 'q_c1',
                'questionVersion': 1,
                'chosenChoiceId': 'c_a',
                'correctChoiceId': 'c_a',
                'responseMs': 12000,
              },
            ]),
          ),
        );
  }

  Future<void> seedSubmittedMock({int timeSeconds = 600}) async {
    await db.into(db.mockAttempts).insertOnConflictUpdate(
          MockAttemptsCompanion.insert(
            id: 'mock_1',
            userId: 'local',
            examId: examId,
            blueprintId: 'bp_1',
            blueprintName: 'Full length',
            durationMinutes: 60,
            status: 'completed',
            strictMode: true,
            sampledQuestionsJson: jsonEncode([
              {
                'sectionId': 'sec_sci',
                'name': 'Science',
                'questionIds': ['q_c1', 'q_c2'],
              },
            ]),
            startedAt: DateTime(2026, 8, 2),
            lastFlushedAt: DateTime(2026, 8, 2),
            updatedAt: DateTime(2026, 8, 2),
            submittedAt: Value(DateTime(2026, 8, 2, 1)),
            totalTimeSeconds: Value(timeSeconds),
            sectionResultsJson: Value(
              jsonEncode([
                {
                  'sectionId': 'sec_sci',
                  'name': 'Science',
                  'correct': 2,
                  'total': 2,
                  'retiredCount': 0,
                  'timeSeconds': timeSeconds,
                },
              ]),
            ),
          ),
        );
  }

  testWidgets('the no-time line gives way to a Time column once a mock is sat',
      (tester) async {
    await seedSyllabus();
    await seedAttempt();

    final exam = buildExam(
      id: examId,
      code: 'UPCAT',
      name: 'UPCAT Exam',
      shortName: 'UPCAT',
    );

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
        activeExamFocusProvider
            .overrideWith((ref) async => ActiveExamFocus.selected(exam)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const Scaffold(
            body: SingleChildScrollView(child: PerformanceSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // With no mock sat: the line explaining why pace is absent is shown, and
    // there is no TIME column.
    expect(
      find.textContaining('after your first full length mock'),
      findsOneWidget,
    );
    expect(find.text('TIME'), findsNothing);

    // Now seed a submitted mock.
    await seedSubmittedMock();

    // Refresh provider and re-render.
    container.invalidate(performanceProvider);
    await tester.pumpAndSettle();

    // With one sat: the line is gone, TIME appears, and the seconds per
    // question shown is measured from that attempt. 600 seconds over two
    // questions is the 300s below, not a figure this test chose.
    expect(
      find.textContaining('after your first full length mock'),
      findsNothing,
    );
    expect(find.text('TIME'), findsOneWidget);
    expect(find.text('300s'), findsOneWidget);
  });
}
