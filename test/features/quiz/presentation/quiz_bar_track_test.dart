// The session bar carries the answer track instead of a hint (core loops B2
// and B5): no "Pick one answer", no "Check when you are ready", no printed
// "Correct" or "Not this one". The result is read once as a status, and the
// bar does not change width between a pick and a check.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/answer_track.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_components.dart';
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
  int total = 10,
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
  final completed = completedSession(total: total, batch: true);
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

Color _mark(WidgetTester tester, int i) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byKey(ValueKey('answer-track-mark-$i')),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (box.decoration as BoxDecoration).color!;
}

void main() {
  for (final cell in dsCells) {
    final colors = cell.dark ? PantasColors.dark : PantasColors.light;
    testWidgets('the bar has no hint line before a pick ($cell)',
        (tester) async {
      await _pump(tester, cell);
      expect(find.text('Pick one answer'), findsNothing);
      expect(find.text('Pick with A, B, C or D'), findsNothing);
      expect(find.byType(AnswerTrack), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('the bar has no hint line after a pick ($cell)',
        (tester) async {
      await _pump(tester, cell, selected: 'a');
      expect(find.text('Check when you are ready'), findsNothing);
      expect(find.textContaining('Change your pick'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('the track shows the checked answers ($cell)', (tester) async {
      await _pump(tester, cell, wrongAt: 1);
      expect(_mark(tester, 0), colors.accent);
      expect(_mark(tester, 1), colors.danger);
      expect(_mark(tester, 2), colors.accent);
      expect(_mark(tester, 3), colors.textPrimary);
      expect(_mark(tester, 4), colors.dividerStrong);
      expect(tester.takeException(), isNull);
    });
    testWidgets('a checked answer is a mark, not a printed word ($cell)',
        (tester) async {
      await _pump(tester, cell, answered: 4, wrongAt: 3);
      expect(find.text('Correct'), findsNothing);
      expect(find.text('Not this one'), findsNothing);
      expect(_mark(tester, 3), colors.danger);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a right answer is still read once as a status', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester, const DsCell(1440, 1, dark: false), answered: 4);
    expect(
      tester.getSemantics(find.byType(AnswerTrack)).label,
      contains('Correct.'),
    );
    handle.dispose();
  });

  testWidgets('a wrong answer is still read once as a status', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      const DsCell(1440, 1, dark: false),
      answered: 4,
      wrongAt: 3,
    );
    expect(
      tester.getSemantics(find.byType(AnswerTrack)).label,
      contains('Not this one.'),
    );
    handle.dispose();
  });

  testWidgets('the phone bar reads the result as a status', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(
      tester,
      const DsCell(390, 1, dark: false),
      answered: 4,
      wrongAt: 3,
    );
    expect(find.bySemanticsLabel('Not this one'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the wide bar keeps its width from pick to check',
      (tester) async {
    const cell = DsCell(1440, 1, dark: false);
    await _pump(tester, cell);
    final before = tester.getSize(find.byType(WebBottomBar)).width;
    await _pump(tester, cell, selected: 'a');
    final picked = tester.getSize(find.byType(WebBottomBar)).width;
    await _pump(tester, cell, answered: 4);
    final checked = tester.getSize(find.byType(WebBottomBar)).width;
    await _pump(tester, cell, answered: 4, wrongAt: 3);
    final missed = tester.getSize(find.byType(WebBottomBar)).width;
    expect(picked, before);
    expect(checked, before);
    expect(missed, before);
  });

  testWidgets('the phone bar keeps its width from pick to check',
      (tester) async {
    const cell = DsCell(390, 1, dark: false);
    await _pump(tester, cell, selected: 'a');
    final picked = tester.getSize(find.byKey(const ValueKey('quiz-counter')));
    await _pump(tester, cell, answered: 4);
    final checked = tester.getSize(find.byKey(const ValueKey('quiz-counter')));
    expect(checked, picked);
  });

  testWidgets('the phone track sits above the count', (tester) async {
    await _pump(tester, const DsCell(390, 1, dark: false));
    final track = tester.getRect(find.byType(AnswerTrack));
    final count = tester.getRect(find.text('4 of 10'));
    expect(track.bottom, lessThanOrEqualTo(count.top));
    expect(
      tester.getSize(find.byKey(const ValueKey('answer-track-mark-0'))),
      const Size(8, 4),
    );
  });

  testWidgets('the wide track sits between the count and the flag',
      (tester) async {
    await _pump(tester, const DsCell(1440, 1, dark: false));
    final track = tester.getRect(find.byType(AnswerTrack));
    final count = tester.getRect(find.text('4 of 10'));
    expect(track.left, greaterThan(count.right));
    expect(
      tester.getSize(find.byKey(const ValueKey('answer-track-mark-0'))),
      const Size(10, 4),
    );
  });

  testWidgets('the phone flag sits in the bar at 390, not in the header',
      (tester) async {
    await _pump(tester, const DsCell(390, 1, dark: false));
    final flag = tester.getRect(find.byTooltip('Flag question'));
    final bar = tester.getRect(find.byKey(const ValueKey('quiz-counter')));
    // Beside the count column, between it and Check, 44 px target.
    expect(flag.center.dy, closeTo(bar.center.dy, 8));
    expect(flag.left, greaterThan(bar.right));
    expect(flag.width, greaterThanOrEqualTo(44));
    expect(flag.height, greaterThanOrEqualTo(44));
    expect(tester.takeException(), isNull);
  });

  for (final width in [390.0, 1440.0]) {
    testWidgets(
        'over 20 questions the bar shows a line, not marks '
        '(${width.toInt()})', (tester) async {
      await _pump(tester, DsCell(width, 1, dark: false), total: 25);
      expect(find.byKey(const ValueKey('answer-track-mark-0')), findsNothing);
      expect(find.byKey(const ValueKey('answer-track-line')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
