import 'dart:io';

import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/data/repos/app_preferences_repository.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_tab_home.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/today_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = inMemoryDatabase();
    await db.into(db.exams).insert(
          ExamsCompanion.insert(
            id: 'e1',
            code: 'UPCAT',
            name: 'UP College Admission Test',
            shortName: 'UPCAT',
            language: 'en',
          ),
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
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('UPCAT'), findsOneWidget);
    expect(find.text('UP College Admission Test'), findsNothing);
  });

  testWidgets('the tab no longer offers a Study row', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Study'), findsNothing);
  });

  testWidgets('the tab no longer offers a Drill a topic row', (tester) async {
    await tester.pumpAppWithProviders(
      const QuizTabHome(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
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
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('More ways to practice'), findsOneWidget);
  });
}
