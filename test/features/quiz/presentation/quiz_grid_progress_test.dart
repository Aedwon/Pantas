// The quiz question grid (design system 4.0, QuestionNavigator): six 36 px
// chips on the wide popover and on the phone sheet, progress only during the
// session (no right or wrong tint), roving focus with arrow keys. The results
// page after a session keeps its outcome colors.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/question_navigator_chip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedAttempt, completedSession;

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: DateTime.utc(2026));
  }

  @override
  Future<void> start({
    required String examId,
    String? topicId,
    int count = 10,
    int? randomSeed,
  }) async {}
}

String? _focused() => FocusManager.instance.primaryFocus?.debugLabel;

/// Four answered (the second one wrong), the fifth question on screen.
QuizSession _session() {
  final completed = completedSession(batch: true);
  final outcomes = completed.outcomes.take(4).toList();
  final o = outcomes[1];
  outcomes[1] = AnswerOutcome(
    questionId: o.questionId,
    questionVersion: o.questionVersion,
    chosenChoiceId: 'b',
    correctChoiceId: 'a',
    responseMs: o.responseMs,
  );
  return completed.copyWith(currentIndex: 4, outcomes: outcomes);
}

Future<void> _pump(WidgetTester tester, DsCell cell) async {
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
  final session = _session();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        flaggedIdsProvider.overrideWith((_) async => <String>{'q2'}),
        quizControllerProvider.overrideWith((ref) => _Controller(ref, session)),
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

Future<void> _open(WidgetTester tester, DsCell cell) async {
  if (cell.width >= 1024) {
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
  } else {
    await tester.tap(find.text('5 of 10'));
  }
  await tester.pumpAndSettle();
}

Finder _chip(DsCell cell, int n) => find.byKey(
      cell.width >= 1024
          ? ValueKey('web-grid-question-$n')
          : ValueKey('grid-question-0-${n + 1}'),
    );

Color? _fill(WidgetTester tester, Finder chip) => (tester
        .widget<DecoratedBox>(
          find.descendant(
            of: chip,
            matching: find.byKey(const ValueKey('question-chip-fill')),
          ),
        )
        .decoration as ShapeDecoration)
    .color;

void main() {
  for (final cell in [
    for (final width in [390.0, 1440.0])
      for (final dark in [false, true])
        for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
  ]) {
    testWidgets('in a session the grid shows progress only ($cell)',
        (tester) async {
      await _pump(tester, cell);
      await _open(tester, cell);
      expect(tester.takeException(), isNull);
      // Six to a row, 36 px chips.
      final first = tester.getTopLeft(_chip(cell, 0));
      expect(tester.getSize(_chip(cell, 0)), const Size.square(36));
      expect(tester.getTopLeft(_chip(cell, 5)).dy, first.dy);
      expect(tester.getTopLeft(_chip(cell, 6)).dy, greaterThan(first.dy));
      // A right answer (1) and a wrong one (2) look the same: answered.
      expect(_fill(tester, _chip(cell, 0)), _fill(tester, _chip(cell, 1)));
      expect(_fill(tester, _chip(cell, 0)), _fill(tester, _chip(cell, 2)));
      // The question on screen is not answered, so it differs.
      expect(
        _fill(tester, _chip(cell, 4)),
        isNot(_fill(tester, _chip(cell, 0))),
      );
    });
  }

  testWidgets('the grid has roving focus and two-dimensional arrows',
      (tester) async {
    const cell = DsCell(1440, 1, dark: false);
    await _pump(tester, cell);
    await _open(tester, cell);
    // Tab reaches the grid's one stop, the question on screen.
    for (var i = 0; i < 20 && !(_focused() ?? '').startsWith('Question'); i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    }
    expect(_focused(), 'Question 5');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    expect(_focused(), 'Question 4');
    // Questions after the current one are locked: arrows skip them.
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    expect(_focused(), 'Question 5');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(_focused(), 'Question 5');
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    expect(_focused(), 'Question 1');
  });

  testWidgets('chips are named with their state', (tester) async {
    final semantics = tester.ensureSemantics();
    const cell = DsCell(1440, 1, dark: false);
    await _pump(tester, cell);
    await _open(tester, cell);
    expect(find.bySemanticsLabel('Question 2, answered'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Question 3, answered, flagged'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Question 5, current, blank'), findsOneWidget);
    expect(find.bySemanticsLabel('Question 8, locked'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the results page after a session keeps outcome colors',
      (tester) async {
    const cell = DsCell(1440, 1, dark: false);
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view
      ..physicalSize = Size(cell.width, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final session = completedSession();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(
              size: tester.view.physicalSize,
              disableAnimations: true,
            ),
            child: SessionEndBody(
              session: session,
              attempt: completedAttempt(session),
              subjectNames: const {'t': 'Science'},
              proIsActive: false,
              onDone: () {},
              onQuestion: (_) {},
              onAll: () {},
              onMistakes: () {},
              onNotes: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final colors = buildLightTheme(web: true).extension<PantasColors>()!;
    final tints = <Color?>{};
    for (final box in tester.widgetList<Container>(find.byType(Container))) {
      final decoration = box.decoration;
      if (decoration is BoxDecoration && decoration.shape == BoxShape.circle) {
        tints.add(decoration.color);
      }
    }
    expect(tints, containsAll([colors.accentTint, colors.dangerTint]));
    expect(find.byType(QuestionNavigatorChip), findsNothing);
  });
}
