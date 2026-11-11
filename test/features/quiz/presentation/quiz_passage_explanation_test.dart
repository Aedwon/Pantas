// Passage items (design system 4.0, Passage and Explanation READMEs): on
// reveal the explanation replaces the passage column; "Show Passage" at the
// right of the explanation head brings the passage back in a Drawer (wide) or
// a Sheet (phone). On the phone "Show Full Passage" expands in place, and a
// passage over about 300 words opens in the Sheet. The Pro "your pick" note is
// its own block after the correct-answer reasoning.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_question.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedSession;

const _short = 'Mangroves grow where rivers meet the sea. Their roots hold the '
    'mud in place. Fishers noticed that catches rose after a belt was '
    'replanted. Young fish hide among the roots. The lesson is simple: plant '
    'trees where the shore wears away.';

String get _long => List.filled(16, _short).join(' ');

Passage _passage(String body) => Passage(
      id: 'p',
      topicId: 't',
      title: 'Mangroves',
      body: body,
      language: 'en',
      wordCount: body.split(' ').length,
    );

const _question = Question(
  id: 'q1',
  version: 1,
  examIds: ['e'],
  topicId: 't',
  language: 'en',
  stem: 'What is the main idea?',
  shortLabel: 'Main idea',
  explanation: 'The text names planting as the lesson.',
  passageId: 'p',
  choices: [
    Choice(id: 'a', label: 'A', text: 'Plant trees', isCorrect: true),
    Choice(
      id: 'b',
      label: 'B',
      text: 'Leave the shore',
      isCorrect: false,
      rationale: 'The text does not say to leave the shore.',
    ),
  ],
);

Future<void> _pumpQuestion(
  WidgetTester tester,
  double width, {
  required bool checked,
  required Passage passage,
  bool drawer = false,
  bool pro = true,
  String? chosen,
  bool dark = false,
  double scale = 1,
}) async {
  debugWebPlatformOverride = true;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view
    ..physicalSize = Size(width, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(40, 24, 40, 140),
          child: WebQuizQuestion(
            question: _question,
            subject: 'Reading',
            passage: passage,
            checked: checked,
            pro: pro,
            chosenId: chosen,
            drawer: drawer
                ? ExplanationDrawer(
                    counter: '1 of 3',
                    actionLabel: 'Next',
                    onAction: () {},
                  )
                : null,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _drawer => find.byKey(const ValueKey('web-side-drawer'));

void main() {
  testWidgets('at 1440 the passage sits left of the question until the reveal',
      (tester) async {
    await _pumpQuestion(
      tester,
      1440,
      checked: false,
      passage: _passage(_short),
    );
    expect(find.text('PASSAGE'), findsOneWidget);
    expect(find.byKey(const ValueKey('web-answer-column')), findsNothing);
    expect(
      tester.getTopLeft(find.text('PASSAGE')).dx,
      lessThan(
        tester.getTopLeft(find.byKey(const ValueKey('web-question-column'))).dx,
      ),
    );
  });

  testWidgets('on reveal the explanation replaces the passage column',
      (tester) async {
    await _pumpQuestion(
      tester,
      1440,
      checked: true,
      chosen: 'a',
      passage: _passage(_short),
    );
    // No third column: the passage text is gone, the explanation is there.
    expect(find.text('PASSAGE'), findsNothing);
    expect(find.textContaining('Mangroves grow'), findsNothing);
    expect(find.text('The text names planting as the lesson.'), findsOneWidget);
    // The explanation takes the passage's place, left of the question.
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('web-answer-column'))).dx,
      lessThan(
        tester.getTopLeft(find.byKey(const ValueKey('web-question-column'))).dx,
      ),
    );
    // "Show Passage" sits at the right end of the head.
    final link = find.widgetWithText(WebTextLink, 'Show Passage');
    expect(link, findsOneWidget);
    final card = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('web-answer-column')),
        matching: find.byType(WebCard),
      ),
    );
    expect(tester.getRect(link).right, greaterThan(card.center.dx));
    expect(card.contains(tester.getCenter(link)), isTrue);
  });

  testWidgets(
      'Show Passage opens the passage in a Drawer; Esc returns focus '
      'to the link', (tester) async {
    await _pumpQuestion(
      tester,
      1440,
      checked: true,
      chosen: 'a',
      passage: _passage(_short),
    );
    // A keyboard user reaches the link with Tab and opens it with Enter.
    for (var i = 0; i < 12; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      final link = FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<WebTextLink>();
      if (link?.label == 'Show Passage') break;
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(_drawer, findsOneWidget);
    expect(
      find.descendant(of: _drawer, matching: find.text('Passage')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _drawer,
        matching: find.textContaining('Mangroves grow'),
      ),
      findsOneWidget,
    );
    final heading = tester.widget<Focus>(
      find.byKey(const ValueKey('passage-heading')),
    );
    expect(heading.focusNode!.hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(_drawer, findsNothing);
    final focused = FocusManager.instance.primaryFocus?.context
        ?.findAncestorWidgetOfExactType<WebTextLink>();
    expect(focused?.label, 'Show Passage');
  });

  testWidgets('the pick note is its own block after the correct answer',
      (tester) async {
    await _pumpQuestion(
      tester,
      1440,
      checked: true,
      chosen: 'b',
      passage: _passage(_short),
    );
    final cards = find.descendant(
      of: find.byKey(const ValueKey('web-answer-column')),
      matching: find.byType(WebCard),
    );
    expect(cards, findsNWidgets(2));
    final correct = tester.getRect(cards.at(0));
    final pick = tester.getRect(find.byKey(const ValueKey('web-your-pick')));
    expect(pick.top, greaterThanOrEqualTo(correct.bottom));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('web-your-pick')),
        matching: find.text('The text does not say to leave the shore.'),
      ),
      findsOneWidget,
    );
    // The correct-answer card holds only the correct reasoning.
    expect(
      find.descendant(
        of: cards.at(0),
        matching: find.text('The text does not say to leave the shore.'),
      ),
      findsNothing,
    );
  });

  testWidgets(
      'below 1134 the passage collapses above the stem and opens in '
      'a Drawer', (tester) async {
    await _pumpQuestion(
      tester,
      1100,
      checked: false,
      passage: _passage(_long),
      drawer: true,
    );
    final collapsed = find.byKey(const ValueKey('web-passage-collapsed'));
    expect(collapsed, findsOneWidget);
    // Four lines, not the whole passage.
    expect(tester.getSize(collapsed).height, lessThan(18 * 1.7 * 4 + 1));
    expect(
      tester.getBottomLeft(collapsed).dy,
      lessThan(
        tester.getTopLeft(find.text('What is the main idea?')).dy,
      ),
    );
    await tester.tap(find.widgetWithText(WebTextLink, 'Show Passage'));
    await tester.pumpAndSettle();
    expect(_drawer, findsOneWidget);
  });

  group('phone', () {
    late _Controller controller;
    late QuizSession before;
    late QuizSession after;

    Future<void> pumpPhone(WidgetTester tester, Passage passage) async {
      debugWebPlatformOverride = false;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = const Size(390, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final completed = completedSession();
      final withPassage = completed.copyWith(
        questions: [
          for (final q in completed.questions) q.copyWith(passageId: 'p'),
        ],
      );
      before = withPassage.copyWith(
        currentIndex: 3,
        outcomes: withPassage.outcomes.take(3).toList(),
      );
      after = before.copyWith(outcomes: withPassage.outcomes.take(4).toList());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            flaggedIdsProvider.overrideWith((_) async => <String>{}),
            passageByIdProvider('p').overrideWith((_) async => passage),
            quizControllerProvider.overrideWith(
              (ref) => controller = _Controller(ref, before),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: const QuizPage(examId: 'e', proIsActive: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a short passage expands in place', (tester) async {
      await pumpPhone(tester, _passage(_short));
      expect(passageWordCount(_short), lessThan(300));
      final text = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('rivers meet'),
      );
      final collapsedHeight = tester.getSize(text.first).height;
      await tester.tap(find.text('Show Full Passage'));
      await tester.pumpAndSettle();
      expect(find.byType(PantasSheet), findsNWidgets(2));
      expect(tester.getSize(text.first).height, greaterThan(collapsedHeight));
      expect(find.text('Show Less'), findsOneWidget);
      // The stem is still on the same scroll.
      expect(find.text('Stem 3'), findsOneWidget);
    });

    testWidgets('a passage over 300 words opens in the Sheet', (tester) async {
      await pumpPhone(tester, _passage(_long));
      expect(passageWordCount(_long), greaterThan(300));
      await tester.tap(find.text('Show Full Passage'));
      await tester.pumpAndSettle();
      expect(find.text('Show Less'), findsNothing);
      final sheet = find.byWidgetPredicate(
        (w) => w is PantasSheet && w.label == 'Passage' && w.open,
      );
      expect(sheet, findsOneWidget);
      await tester.tap(find.text('Close').last);
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is PantasSheet && w.label == 'Passage' && w.open,
        ),
        findsNothing,
      );
    });

    testWidgets('after the reveal Show Passage opens the Sheet',
        (tester) async {
      await pumpPhone(tester, _passage(_short));
      controller.checked(after);
      await tester.pumpAndSettle();
      expect(find.text('Explanation 3'), findsOneWidget);
      await tester.tap(find.widgetWithText(WebTextLink, 'Show Passage'));
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) => w is PantasSheet && w.label == 'Passage' && w.open,
        ),
        findsOneWidget,
      );
    });
  });

  test('passageWordCount counts words in the text', () {
    expect(passageWordCount(''), 0);
    expect(passageWordCount('  one  two\nthree '), 3);
  });

  for (final cell in [
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0])
        for (final width in [1100.0, 1440.0]) DsCell(width, scale, dark: dark),
  ]) {
    testWidgets('passage item does not overflow ($cell)', (tester) async {
      await tester.runAsync(loadDsFonts);
      for (final checked in [false, true]) {
        await _pumpQuestion(
          tester,
          cell.width,
          checked: checked,
          chosen: 'b',
          passage: _passage(_long),
          drawer: true,
          dark: cell.dark,
          scale: cell.scale,
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: DateTime.utc(2026));
  }

  void checked(QuizSession session) {
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
