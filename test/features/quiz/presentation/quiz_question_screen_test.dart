import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/data/repos/content_repository.dart';
import 'package:pantas/core/storage/domain/attempt.dart';
import 'package:pantas/core/storage/domain/choice.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/domain/topic.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/choice_row.dart';
import 'package:pantas/core/ui/components/floating_bar.dart';
import 'package:pantas/core/ui/components/math_text.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/toast.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/lesson_text_scale.dart';
import 'package:pantas/features/quiz/application/quiz_completion_coordinator.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/submit_answer.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../core/ui/components/w2_test_support.dart';
import '../../../helpers/in_memory_database.dart';

class _Submit extends Mock implements SubmitAnswer {}

class _Complete extends Mock implements QuizCompletionCoordinator {}

class _Content extends Mock implements ContentRepository {}

class _FlagPreferences extends AppPreferencesRepository {
  _FlagPreferences(super.db);
  bool fail = true;
  @override
  Future<void> setAnnouncedFirstFlag() {
    if (fail) throw StateError('private flag preference failure');
    return super.setAnnouncedFirstFlag();
  }
}

class _RunningController extends QuizController {
  _RunningController(super.ref, QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: session.startedAt);
  }
}

Question item(int n) => Question(
      id: 'q$n',
      version: 1,
      examIds: const ['e'],
      topicId: 't',
      language: 'en',
      stem: 'Question $n',
      explanation: 'Explanation $n',
      choices: const [
        Choice(id: 'a', label: 'A', text: 'Right answer', isCorrect: true),
        Choice(
          id: 'b',
          label: 'B',
          text: 'Wrong answer',
          isCorrect: false,
          rationale: 'You confused these two ideas.',
        ),
        Choice(id: 'c', label: 'C', text: 'Other answer', isCorrect: false),
      ],
    );

void main() {
  setUpAll(() {
    registerFallbackValue(item(1));
    registerFallbackValue(
      QuizSession.start(
        sessionId: 'fallback',
        examId: 'e',
        questions: [item(1)],
        startedAt: DateTime.utc(2026),
      ),
    );
  });
  Future<ProviderContainer> pump(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
    double scale = 1,
    Size size = const Size(390, 844),
    bool pro = false,
    bool reduceMotion = true,
    QuizSession? session,
    QuizCompletionCoordinator? completion,
    Future<Passage?> Function()? passageReader,
    AppPreferencesRepository Function(AppDatabase)? preferences,
  }) async {
    final db = inMemoryDatabase();
    final submit = _Submit();
    final content = _Content();
    if (passageReader != null) {
      when(() => content.passageById(any())).thenAnswer((_) => passageReader());
    }
    when(() => content.topicById(any())).thenAnswer(
      (_) async => const Topic(
        id: 't',
        subjectId: 's',
        name: 'Mathematics',
        ordering: 0,
      ),
    );
    when(
      () => submit(
        question: any(named: 'question'),
        chosenChoiceId: any(named: 'chosenChoiceId'),
        responseMs: any(named: 'responseMs'),
        now: any(named: 'now'),
        origin: any(named: 'origin'),
      ),
    ).thenAnswer(
      (call) async => AnswerOutcome(
        questionId: (call.namedArguments[#question]! as Question).id,
        questionVersion: 1,
        chosenChoiceId: call.namedArguments[#chosenChoiceId]! as String,
        correctChoiceId: 'a',
        responseMs: call.namedArguments[#responseMs]! as int,
      ),
    );
    final run = session ??
        QuizSession.start(
          sessionId: 's',
          examId: 'e',
          questions: [item(1), item(2)],
          startedAt: DateTime.utc(2026, 10, 15),
        );
    final router = GoRouter(
      initialLocation: '/quiz',
      routes: [
        GoRoute(
          path: '/quiz',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/run'),
              child: const Text('Open quiz'),
            ),
          ),
        ),
        GoRoute(
          path: '/run',
          builder: (_, state) => QuizPage(
            examId: 'e',
            mode: QuizPageMode.practice,
            proIsActive: pro,
          ),
        ),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      await db.close();
    });
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          if (preferences != null)
            appPreferencesRepositoryProvider.overrideWithValue(preferences(db)),
          contentRepositoryProvider.overrideWithValue(content),
          submitAnswerProvider.overrideWithValue(submit),
          if (completion != null)
            quizCompletionCoordinatorProvider.overrideWithValue(completion),
          quizControllerProvider
              .overrideWith((ref) => _RunningController(ref, run)),
        ],
        child: MaterialApp.router(
          theme: brightness == Brightness.light
              ? buildLightTheme()
              : buildDarkTheme(),
          routerConfig: router,
          builder: (_, child) => MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(scale),
              disableAnimations: reduceMotion,
            ),
            child: child!,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open quiz'));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(QuizPage)));
  }

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('pick then Check and reveal $brightness scale=$scale',
          (tester) async {
        final container =
            await pump(tester, brightness: brightness, scale: scale);
        expect(find.byType(FloatingBar), findsOneWidget);
        final disabled = tester.widget<TextButton>(
          find.descendant(
            of: find.widgetWithText(PantasButton, 'Check'),
            matching: find.byType(TextButton),
          ),
        );
        expect(
          disabled.style!.foregroundColor!.resolve({}),
          tester.element(find.byType(FloatingBar)).colors.disabledActionLabel,
        );
        expect(
          tester
              .widget<PantasButton>(
                find.widgetWithText(PantasButton, 'Check'),
              )
              .onPressed,
          isNull,
        );
        await tester.tap(find.text('Wrong answer').hitTestable().first);
        await tester.pumpAndSettle();
        expect(
          (container.read(quizControllerProvider) as QuizRunning)
              .session
              .outcomes,
          isEmpty,
        );
        expect(find.text('correct answer'), findsNothing);
        await tester.tap(find.text('Right answer').hitTestable().first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Check'));
        await tester.pumpAndSettle();
        expect(
          (container.read(quizControllerProvider) as QuizRunning)
              .session
              .currentOutcome!
              .isCorrect,
          isTrue,
        );
        expect(
          tester.widget<FloatingBar>(find.byType(FloatingBar)).state,
          FloatingBarState.right,
        );
        await tester.ensureVisible(find.text('correct answer'));
        await tester.pumpAndSettle();
        expect(find.textContaining('back in'), findsNothing);
        expect(find.text('Explanation 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final pro in [false, true]) {
    testWidgets('miss reveal respects notes access pro=$pro', (tester) async {
      await pump(tester, pro: pro);
      await tester.tap(find.text('Wrong answer').hitTestable().first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FloatingBar>(find.byType(FloatingBar)).state,
        FloatingBarState.wrong,
      );
      await tester.ensureVisible(find.text('correct answer'));
      await tester.pumpAndSettle();
      expect(find.text('your pick'), pro ? findsOneWidget : findsNothing);
    });
  }

  testWidgets('grid revisits are read-only and return to the live question',
      (tester) async {
    final container = await pump(tester);
    await tester.tap(find.text('Right answer').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wrong answer').hitTestable().first);
    await tester.pumpAndSettle();
    final shownAt =
        (container.read(quizControllerProvider) as QuizRunning).questionShownAt;
    await tester.tap(find.text('2 of 2'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('grid-question-0-1')));
    await tester.pumpAndSettle();
    expect(find.text('Back to 2'), findsOneWidget);
    expect(find.byTooltip('Flag question'), findsOneWidget);
    expect(find.byType(ChoiceRow), findsWidgets);
    await tester.tap(find.text('Back to 2'));
    await tester.pumpAndSettle();
    final current = container.read(quizControllerProvider) as QuizRunning;
    expect(current.session.currentIndex, 1);
    expect(current.session.outcomes, hasLength(1));
    expect(current.selectedChoiceId, 'b');
    expect(current.questionShownAt, shownAt);
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('Finish'), findsOneWidget);
  });

  testWidgets('leave asks once for X and system back', (tester) async {
    await pump(tester);
    await tester.tap(find.byTooltip('Leave session'));
    await tester.pumpAndSettle();
    expect(find.text('Leave this session?'), findsOneWidget);
    await tester.tap(find.text('Keep Going'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Leave this session?'), findsOneWidget);
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(find.text('Open quiz'), findsOneWidget);
  });

  testWidgets('flag Undo keeps the question and writes no answer',
      (tester) async {
    final container = await pump(tester);
    await tester.tap(find.byTooltip('Flag question'));
    await tester.pumpAndSettle();
    expect(find.text('Flagged. Find it in the Quiz tab.'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(
      await container.read(questionFlagsRepositoryProvider).isFlagged('q1'),
      isFalse,
    );
    expect(
      (container.read(quizControllerProvider) as QuizRunning).session.outcomes,
      isEmpty,
    );
  });
  testWidgets(
      'long question grid opens at the current place and back only closes it',
      (tester) async {
    await pump(
      tester,
      session: QuizSession(
        sessionId: 'long',
        examId: 'e',
        questions: [for (var n = 1; n <= 100; n++) item(n)],
        currentIndex: 80,
        outcomes: [
          for (var n = 1; n <= 80; n++)
            AnswerOutcome(
              questionId: 'q$n',
              questionVersion: 1,
              chosenChoiceId: 'a',
              correctChoiceId: 'a',
              responseMs: 1000,
            ),
        ],
        startedAt: DateTime.utc(2026, 10, 15),
      ),
    );
    await tester.tap(find.text('81 of 100'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('grid-question-0-81')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('grid-question-0-1')).hitTestable(),
      findsNothing,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Leave this session?'), findsNothing);
    expect(find.text('Question 81'), findsOneWidget);
    expect(find.text('Questions'), findsNothing);
  });

  testWidgets('flag uses the drawn two-part pop and toast delay',
      (tester) async {
    await pump(tester, reduceMotion: false);
    await tester.tap(find.byTooltip('Flag question'));
    final pop = find.byKey(const ValueKey('quiz-flag-pop'));
    for (var n = 0; n < 10 && pop.evaluate().isEmpty; n++) {
      await tester.pump();
    }
    expect(pop, findsOneWidget);
    expect(
      tester.widget<Transform>(pop).transform.storage[0],
      closeTo(.6, .03),
    );
    expect(find.text('Flagged. Find it in the Quiz tab.'), findsNothing);
    await tester.pump(const Duration(milliseconds: 260));
    expect(
      tester.widget<Transform>(pop).transform.storage[0],
      closeTo(1.22, .03),
    );
    await tester.pump(const Duration(milliseconds: 260));
    expect(tester.widget<Transform>(pop).transform.storage[0], closeTo(1, .03));
    expect(find.text('Flagged. Find it in the Quiz tab.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2280));
    final toast = tester.widget<Toast>(find.byType(Toast));
    expect(toast.visible, isFalse);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(Toast), findsNothing);
  });
  testWidgets('Finish failure retries completion instead of checking again',
      (tester) async {
    final complete = _Complete();
    var fails = true;
    when(
      () => complete.complete(
        session: any(named: 'session'),
        now: any(named: 'now'),
        persisted: any(named: 'persisted'),
      ),
    ).thenAnswer((_) async {
      if (fails) throw StateError('private completion failure');
      return Attempt(
        id: 'one',
        examId: 'e',
        startedAt: DateTime.utc(2026, 10, 15),
        completedAt: DateTime.utc(2026, 10, 15, 0, 1),
        items: const [],
      );
    });
    final container = await pump(
      tester,
      completion: complete,
      session: QuizSession.start(
        sessionId: 'one',
        examId: 'e',
        questions: [item(1)],
        startedAt: DateTime.utc(2026, 10, 15),
      ),
    );
    await tester.tap(find.text('Right answer').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('private completion failure'), findsNothing);
    fails = false;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(container.read(quizControllerProvider), isA<QuizComplete>());
  });
  for (final brightness in Brightness.values) {
    testWidgets('wrong answer contrast uses its actual surface $brightness',
        (tester) async {
      await pump(tester, brightness: brightness);
      await tester.tap(find.text('Wrong answer').hitTestable());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      final wrong = find.byWidgetPredicate(
        (w) => w is ChoiceRow && w.state == ChoiceRowState.wrong,
      );
      final text = tester.widget<MathText>(
        find.descendant(of: wrong, matching: find.byType(MathText)),
      );
      final surface = tester.widget<AnimatedContainer>(
        find.descendant(
          of: wrong,
          matching: find.byKey(const ValueKey('choice-surface')),
        ),
      );
      expectContrast(
        text.style!.color!,
        (surface.decoration! as BoxDecoration).color!,
      );
    });
  }

  testWidgets('large lesson text scrolls long choices clear of the fixed bar',
      (tester) async {
    final long = item(1).copyWith(
      stem: List.filled(12, 'Read this part carefully.').join(' '),
      choices: [
        const Choice(
          id: 'a',
          label: 'A',
          text: 'Right answer',
          isCorrect: true,
        ),
        Choice(
          id: 'b',
          label: 'B',
          text: List.filled(12, 'A long choice.').join(' '),
          isCorrect: false,
        ),
        const Choice(
          id: 'c',
          label: 'C',
          text: 'Last choice',
          isCorrect: false,
        ),
      ],
    );
    final container = await pump(
      tester,
      scale: 2,
      session: QuizSession.start(
        sessionId: 'long',
        examId: 'e',
        questions: [long],
        startedAt: DateTime.utc(2026),
      ),
    );
    await container.read(lessonTextScaleProvider.notifier).setScale(1.4);
    await tester.pumpAndSettle();
    final last = find.text('Last choice');
    await tester.ensureVisible(last);
    await tester.pumpAndSettle();
    expect(
      tester.getBottomLeft(last).dy,
      lessThan(tester.getTopLeft(find.byType(FloatingBar)).dy),
    );
    expect(
      MediaQuery.textScalerOf(tester.element(last)).scale(17),
      closeTo(47.6, .01),
    );
    expect(
      MediaQuery.textScalerOf(tester.element(find.text('Check'))).scale(16),
      32,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a real figure keeps its white backing in dark mode',
      (tester) async {
    final figure = item(1).copyWith(
      figureSpecJson: '{"kind":"geometry-diagram","type":"triangle",'
          '"labels":["A","B","C"]}',
    );
    await pump(
      tester,
      brightness: Brightness.dark,
      session: QuizSession.start(
        sessionId: 'figure',
        examId: 'e',
        questions: [figure],
        startedAt: DateTime.utc(2026),
      ),
    );
    final frame = find.byKey(const ValueKey('question-figure-frame'));
    expect(frame, findsOneWidget);
    expect(tester.widget<Container>(frame).color, Colors.white);
    expect(tester.takeException(), isNull);
  });

  testWidgets('flag save Retry retains flag intent without checking an answer',
      (tester) async {
    late _FlagPreferences prefs;
    final container =
        await pump(tester, preferences: (db) => prefs = _FlagPreferences(db));
    await tester.tap(find.text('Wrong answer').hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Flag question'));
    await tester.pumpAndSettle();
    expect(find.text('Could not save your progress.'), findsOneWidget);
    expect(find.textContaining('private flag'), findsNothing);
    prefs.fail = false;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(
      await container.read(questionFlagsRepositoryProvider).isFlagged('q1'),
      isTrue,
    );
    expect(
      (container.read(quizControllerProvider) as QuizRunning).session.outcomes,
      isEmpty,
    );
    expect(find.text('Could not save your progress.'), findsNothing);
  });

  testWidgets('report opens the existing form and recolors after queued send',
      (tester) async {
    await pump(tester);
    await tester.tap(find.byTooltip('Report a question'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'This choice is missing a unit.',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
    final report = find.byTooltip('Report a question');
    final theme = tester.widget<IconTheme>(
      find.descendant(of: report, matching: find.byType(IconTheme)).last,
    );
    expect(theme.data.color, tester.element(report).colors.accent);
    expect(tester.takeException(), isNull);
  });
  testWidgets('compact 200 percent revisit keeps all targets and content clear',
      (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      await pump(
        tester,
        scale: 2,
        size: const Size(320, 640),
        session: QuizSession(
          sessionId: 'compact',
          examId: 'e',
          questions: [for (var n = 1; n <= 14; n++) item(n)],
          currentIndex: 13,
          outcomes: [
            for (var n = 1; n <= 13; n++)
              AnswerOutcome(
                questionId: 'q$n',
                questionVersion: 1,
                chosenChoiceId: 'a',
                correctChoiceId: 'a',
                responseMs: 1000,
              ),
          ],
          startedAt: DateTime.utc(2026),
        ),
      );
      await tester.tap(find.text('14 of 14'));
      await tester.pumpAndSettle();
      await tester
          .ensureVisible(find.byKey(const ValueKey('grid-question-0-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('grid-question-0-1')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final counter = find.byKey(const ValueKey('quiz-counter'));
      final flag = find.byTooltip('Flag question');
      final back = find.widgetWithText(PantasButton, 'Back to 14');
      for (final target in [counter, flag, back]) {
        expect(tester.getSize(target).width, greaterThanOrEqualTo(44));
        expect(tester.getSize(target).height, greaterThanOrEqualTo(44));
      }
      expect(tester.getRect(counter).overlaps(tester.getRect(flag)), isFalse);
      expect(tester.getRect(flag).overlaps(tester.getRect(back)), isFalse);
      expect(
        find.bySemanticsLabel('Question 1 of 14. Open question navigator'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Back to 14'), findsOneWidget);
      final explanation = find.text('Explanation 1');
      await tester.ensureVisible(explanation);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(explanation).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(FloatingBar)).dy),
      );
    } finally {
      semantics.dispose();
    }
  });

  for (final missing in [false, true]) {
    testWidgets(
        'passage ${missing ? "missing" : "load failure"} can retry '
        'without losing question', (tester) async {
      var reads = 0;
      await pump(
        tester,
        session: QuizSession.start(
          sessionId: 'passage-retry',
          examId: 'e',
          questions: [item(1).copyWith(passageId: 'p')],
          startedAt: DateTime.utc(2026),
        ),
        passageReader: () async {
          reads++;
          if (reads == 1) {
            if (missing) return null;
            throw StateError('private passage failure');
          }
          return const Passage(
            id: 'p',
            topicId: 't',
            title: 'Passage',
            body: 'Read this passage.',
            language: 'en',
            wordCount: 3,
          );
        },
      );
      expect(find.text('Could not load your quiz.'), findsOneWidget);
      expect(find.textContaining('private passage'), findsNothing);
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(find.text('Read this passage.'), findsOneWidget);
      expect(find.text('Question 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
