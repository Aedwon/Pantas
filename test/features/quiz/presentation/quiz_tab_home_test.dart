import 'dart:io';

import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:pantas/features/quiz/presentation/practice_row_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_home.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;
  late ContentDatabase contentDb;

  setUp(() async {
    db = inMemoryDatabase();
    contentDb = openTestContentDatabase();
    await seedContentExam(
      contentDb,
      examId: 'e1',
      code: 'UPCAT',
      name: 'UP College Admission Test',
      shortName: 'UPCAT',
    );
    await AppPreferencesRepository(db).setSelectedExamId('e1');
  });

  tearDown(() => db.close());

  testWidgets('the error state never shows the exception', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [
        activeExamFocusProvider.overrideWith(
          (ref) => Future.error(
            const SocketException('Failed host lookup: api.example.com'),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Could not load your practice. Pull down to try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('SocketException'), findsNothing);
  });

  testWidgets('the tab shows the exam short name, not the long name',
      (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('UPCAT'), findsOneWidget);
    expect(find.text('UP College Admission Test'), findsNothing);
  });

  testWidgets('the tab no longer offers a Study row', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Study'), findsNothing);
  });

  testWidgets('the tab no longer offers a Drill a topic row', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Drill a topic'), findsNothing);
  });

  testWidgets('the tab renders whatever mock panel it is handed',
      (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(mockPanel: Text('MOCK PANEL HERE')),
      overrides: [
        sessionPanelProvider('e1').overrideWith(
          (ref) => const SessionPanelCaughtUp(
            answeredToday: 5,
            correctToday: 4,
          ),
        ),
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('MOCK PANEL HERE'), findsOneWidget);
  });

  testWidgets('the tab renders without a mock panel', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [
        sessionPanelProvider('e1').overrideWith(
          (ref) => const SessionPanelCaughtUp(
            answeredToday: 5,
            correctToday: 4,
          ),
        ),
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('More ways to practice'), findsOneWidget);
  });

  testWidgets('the flagged section counts what is kept', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [
        sessionPanelProvider('e1').overrideWith(
          (ref) => const SessionPanelCaughtUp(
            answeredToday: 5,
            correctToday: 4,
          ),
        ),
        flagSummaryProvider.overrideWith(
          (ref) => const FlagSummary(count: 12, topicCount: 4),
        ),
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Flagged'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Questions you flagged'), findsOneWidget);
    expect(find.text('12 kept, across 4 topics'), findsOneWidget);
  });

  testWidgets('an empty flagged section invites the first flag',
      (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [
        sessionPanelProvider('e1').overrideWith(
          (ref) => const SessionPanelCaughtUp(
            answeredToday: 5,
            correctToday: 4,
          ),
        ),
        flagSummaryProvider.overrideWith(
          (ref) => FlagSummary.empty,
        ),
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Flag anything you want to come back to'),
      findsOneWidget,
    );
  });

  testWidgets('the flagged row opens the flagged list', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [
        sessionPanelProvider('e1').overrideWith(
          (ref) => const SessionPanelCaughtUp(
            answeredToday: 5,
            correctToday: 4,
          ),
        ),
        flagSummaryProvider.overrideWith(
          (ref) => const FlagSummary(count: 12, topicCount: 4),
        ),
        appDatabaseProvider.overrideWithValue(db),
        contentDatabaseProvider.overrideWithValue(contentDb),
      ],
    );
    await tester.pumpAndSettle();

    final row = tester.widget<InkTableRow>(
      find.widgetWithText(InkTableRow, 'Questions you flagged'),
    );
    // The flagged list exists now. This row was deliberately dead until it
    // did, because a chevron onto nothing is worse than no chevron.
    expect(row.onTap, isNotNull);
  });
}
