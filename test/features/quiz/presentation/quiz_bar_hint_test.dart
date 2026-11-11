// The question bar's hint (design system 4.0, FloatingBar): before a pick
// "Pick one answer"; after a pick "Check when you are ready"; "Correct" or
// "Not this one" once checked. The phone and the wide bar use the same words.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedSession;

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session, {String? selected}) {
    state = QuizRunning(
      session: session,
      questionShownAt: DateTime.utc(2026),
      selectedChoiceId: selected,
    );
  }

  @override
  Future<void> start({
    required String examId,
    String? topicId,
    int count = 10,
    int? randomSeed,
  }) async {}
}

Future<void> _pump(
  WidgetTester tester,
  DsCell cell, {
  String? selected,
  int answered = 3,
  int wrongAt = -1,
}) async {
  await tester.runAsync(loadDsFonts);
  final web = cell.width >= 1024;
  debugWebPlatformOverride = web;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = Size(cell.width, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final completed = completedSession(batch: true);
  final outcomes = completed.outcomes.take(answered).toList();
  if (wrongAt >= 0 && wrongAt < outcomes.length) {
    final o = outcomes[wrongAt];
    outcomes[wrongAt] = AnswerOutcome(
      questionId: o.questionId,
      questionVersion: o.questionVersion,
      chosenChoiceId: 'b',
      correctChoiceId: 'a',
      responseMs: o.responseMs,
    );
  }
  final session = completed.copyWith(currentIndex: 3, outcomes: outcomes);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        flaggedIdsProvider.overrideWith((_) async => <String>{}),
        quizControllerProvider.overrideWith(
          (ref) => _Controller(ref, session, selected: selected),
        ),
      ],
      child: MaterialApp(
        theme: cell.dark ? buildDarkTheme(web: web) : buildLightTheme(web: web),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(cell.scale),
          ),
          child: child!,
        ),
        home: const QuizPage(examId: 'e', proIsActive: false),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in [390.0, 1440.0]) {
    for (final scale in [1.0, 2.0]) {
      final cell = DsCell(width, scale, dark: false);
      testWidgets('the bar says "Pick one answer" before a pick ($cell)',
          (tester) async {
        await _pump(tester, cell);
        expect(find.text('Pick one answer'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
      testWidgets(
          'the bar says "Check when you are ready" after a pick '
          '($cell)', (tester) async {
        await _pump(tester, cell, selected: 'a');
        expect(find.text('Check when you are ready'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
      testWidgets('the bar says "Correct" once checked right ($cell)',
          (tester) async {
        await _pump(tester, cell, answered: 4);
        expect(find.text('Correct'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
      testWidgets('the bar says "Not this one" once checked wrong ($cell)',
          (tester) async {
        await _pump(tester, cell, answered: 4, wrongAt: 3);
        expect(find.text('Not this one'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
