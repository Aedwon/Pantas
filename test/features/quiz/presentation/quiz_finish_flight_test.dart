// The last Finish hands the end page where the marks of the answer track are
// (core loops B2), so they can fly into the results. Next, in the middle of a
// session, hands over nothing.
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
import 'package:pantas/features/quiz/presentation/quiz_session_end_page.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedAttempt, completedSession;

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session) {
    state = QuizRunning(
      session: session,
      questionShownAt: DateTime.utc(2026),
    );
  }

  int nexts = 0;

  @override
  Future<void> next() async {
    nexts++;
    final s = state;
    if (s is! QuizRunning) return;
    if (s.session.isComplete) {
      state = QuizComplete(
        attempt: completedAttempt(s.session),
        session: s.session,
      );
    }
  }

  @override
  Future<void> start({
    required String examId,
    String? topicId,
    int count = 10,
    int? randomSeed,
  }) async {}
}

Future<_Controller> _pump(
  WidgetTester tester, {
  required double width,
  required int total,
  required int answered,
  int correct = 7,
}) async {
  await tester.runAsync(loadDsFonts);
  final web = width >= 1024;
  debugWebPlatformOverride = web;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = Size(width, 900)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = inMemoryDatabase();
  addTearDown(db.close);
  final completed = completedSession(total: total, correct: correct);
  final session = completed.copyWith(
    currentIndex: answered - 1,
    outcomes: completed.outcomes.take(answered).toList(),
  );
  late _Controller controller;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        flaggedIdsProvider.overrideWith((_) async => <String>{}),
        quizControllerProvider.overrideWith(
          (ref) => controller = _Controller(ref, session),
        ),
      ],
      child: MaterialApp(
        theme: web ? buildLightTheme(web: true) : buildLightTheme(web: false),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const QuizPage(examId: 'e', proIsActive: false),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  for (final width in [390.0, 1440.0]) {
    final name = width < 1024 ? 'phone' : 'wide';

    testWidgets('$name: Finish hands over where the marks are', (tester) async {
      await _pump(tester, width: width, total: 10, answered: 10);
      final marks = [
        for (var i = 0; i < 10; i++)
          tester.getRect(find.byKey(ValueKey('answer-track-mark-$i'))),
      ];
      await tester.tap(find.text('Finish'));
      await tester.pump();
      final flight =
          tester.widget<QuizSessionEndPage>(find.byType(QuizSessionEndPage));
      expect(flight.flight, isNotNull);
      expect(flight.flight!.from, marks);
      expect(flight.flight!.correct, [
        for (var i = 0; i < 10; i++) i < 7,
      ]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name: over 20 questions Finish hands over no marks',
        (tester) async {
      await _pump(tester, width: width, total: 25, answered: 25, correct: 20);
      await tester.tap(find.text('Finish'));
      await tester.pump();
      final page =
          tester.widget<QuizSessionEndPage>(find.byType(QuizSessionEndPage));
      expect(page.flight, isNotNull);
      expect(page.flight!.from, isEmpty);
      expect(page.flight!.correct.length, 25);
      expect(tester.takeException(), isNull);
    });

    testWidgets('$name: Next in the middle hands over nothing', (tester) async {
      final controller =
          await _pump(tester, width: width, total: 10, answered: 4);
      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(controller.nexts, 1);
      expect(find.byType(QuizSessionEndPage), findsNothing);
    });
  }
}
