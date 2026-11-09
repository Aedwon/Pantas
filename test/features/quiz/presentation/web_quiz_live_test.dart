import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/ids.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedSession;

class _SlowFlags extends QuestionFlagController {
  _SlowFlags(this.gate);
  final Completer<void> gate;

  @override
  Future<FlagToggle> setFlagged(
    QuestionId questionId, {
    required bool flagged,
  }) async {
    await gate.future;
    return FlagToggle.firstFlagged;
  }
}

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: DateTime.utc(2026));
  }

  /// Swaps in the session after the student checked an answer.
  void checked(QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: DateTime.utc(2026));
  }

  /// What a real check lands on, so a test can press the real buttons.
  QuizSession? afterCheck;

  @override
  void pick({required String chosenChoiceId}) {
    final s = state;
    if (s is! QuizRunning) return;
    state = QuizRunning(
      session: s.session,
      questionShownAt: s.questionShownAt,
      selectedChoiceId: chosenChoiceId,
    );
  }

  @override
  Future<void> check() async {
    final s = state;
    if (s is! QuizRunning || afterCheck == null) return;
    state = QuizRunning(
      session: s.session,
      questionShownAt: s.questionShownAt,
      selectedChoiceId: s.selectedChoiceId,
      checking: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));
    state = QuizRunning(
      session: afterCheck!,
      questionShownAt: s.questionShownAt,
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

void main() {
  for (final dark in [false, true]) {
    testWidgets('wide live grid, looking back and leave dark=$dark',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final completed = completedSession(batch: true);
      final session = completed.copyWith(
        currentIndex: 3,
        outcomes: completed.outcomes.take(3).toList(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            flaggedIdsProvider.overrideWith((_) async => <String>{}),
            quizControllerProvider
                .overrideWith((ref) => _Controller(ref, session)),
          ],
          child: MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: const QuizPage(examId: 'e', proIsActive: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Reviews · Session 1 of 2'), findsOneWidget);
      expect(find.text('4 of 10'), findsOneWidget);
      expect(find.byKey(const ValueKey('web-answer-column')), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('3 of 10 answered'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('web-grid-question-1')));
      await tester.pumpAndSettle();
      expect(find.text('Back to 4'), findsOneWidget);
      expect(find.byKey(const ValueKey('web-answer-column')), findsOneWidget);
      // Board QS_GridBack: the navigator stays open after a pick.
      expect(find.text('Questions'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('4 of 10'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Questions'), findsNothing);
      expect(find.text('Leave this session?'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Leave this session?'), findsOneWidget);
      expect(find.text('Keep Going'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  group('question navigator motion', () {
    Future<void> pumpLive(WidgetTester tester, {bool still = false}) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final completed = completedSession(batch: true);
      final session = completed.copyWith(
        currentIndex: 3,
        outcomes: completed.outcomes.take(3).toList(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            flaggedIdsProvider.overrideWith((_) async => <String>{}),
            quizControllerProvider
                .overrideWith((ref) => _Controller(ref, session)),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: still),
              child: child!,
            ),
            home: const QuizPage(examId: 'e', proIsActive: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final popover = find.text('Questions');

    double shown(WidgetTester tester) {
      var value = 1.0;
      for (final element in find
          .ancestor(of: popover, matching: find.byType(Opacity))
          .evaluate()) {
        value *= (element.widget as Opacity).opacity;
      }
      return value;
    }

    Future<void> key(WidgetTester tester, LogicalKeyboardKey key) async {
      await tester.sendKeyEvent(key);
      await tester.pump();
      await tester.pump();
    }

    testWidgets('opens and closes over 240 ms, and stays until it ends',
        (tester) async {
      await pumpLive(tester);
      await key(tester, LogicalKeyboardKey.keyG);
      await tester.pump(const Duration(milliseconds: 100));
      expect(shown(tester), inExclusiveRange(0, 1));
      final rising = tester.getTopLeft(popover).dy;
      await tester.pumpAndSettle();
      expect(shown(tester), 1);
      expect(tester.getTopLeft(popover).dy, lessThan(rising));

      await key(tester, LogicalKeyboardKey.keyG);
      await tester.pump(const Duration(milliseconds: 100));
      expect(popover, findsOneWidget);
      expect(shown(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(popover, findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Esc closes it the same way', (tester) async {
      await pumpLive(tester);
      await key(tester, LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      await key(tester, LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 100));
      expect(popover, findsOneWidget);
      expect(shown(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(popover, findsNothing);
      expect(find.text('Leave this session?'), findsNothing);
    });

    testWidgets('a click away closes it and the catcher stops answering',
        (tester) async {
      await pumpLive(tester);
      await key(tester, LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(1300, 200));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(popover, findsOneWidget);
      expect(shown(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(popover, findsNothing);
    });

    testWidgets('opening it again while it closes turns it round',
        (tester) async {
      await pumpLive(tester);
      await key(tester, LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      await key(tester, LogicalKeyboardKey.keyG);
      await tester.pump(const Duration(milliseconds: 100));
      final closing = shown(tester);
      expect(closing, inExclusiveRange(0, 1));
      await key(tester, LogicalKeyboardKey.keyG);
      await tester.pump(const Duration(milliseconds: 60));
      expect(shown(tester), greaterThan(closing));
      await tester.pumpAndSettle();
      expect(popover, findsOneWidget);
      expect(shown(tester), 1);
    });

    testWidgets('once open, it stays put and runs nothing', (tester) async {
      await pumpLive(tester);
      await key(tester, LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      expect(shown(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('reduced motion opens and closes at once', (tester) async {
      await pumpLive(tester, still: true);
      await key(tester, LogicalKeyboardKey.keyG);
      expect(popover, findsOneWidget);
      expect(shown(tester), 1);
      await key(tester, LogicalKeyboardKey.keyG);
      expect(popover, findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
  group('keys keep working after Check', () {
    late _Controller controller;
    late QuizSession before;

    Future<void> pumpLive(
      WidgetTester tester, {
      bool lettersOn = true,
    }) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final completed = completedSession(batch: true);
      before = completed.copyWith(
        currentIndex: 3,
        outcomes: completed.outcomes.take(3).toList(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            flaggedIdsProvider.overrideWith((_) async => <String>{}),
            quizControllerProvider.overrideWith(
              (ref) => controller = _Controller(ref, before)
                ..afterCheck = before.copyWith(
                  outcomes: completed.outcomes.take(4).toList(),
                ),
            ),
          ],
          child: LetterShortcutsScope(
            enabled: lettersOn,
            child: MaterialApp(
              theme: buildDarkTheme(web: true),
              home: const QuizPage(examId: 'e', proIsActive: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // A click in the browser also moves keyboard focus to what was clicked.
    Future<void> click(WidgetTester tester, Finder target) async {
      await tester.tap(target);
      Focus.of(tester.element(target)).requestFocus();
      await tester.pump();
    }

    // The student clicks an answer, then checks it by key or by click.
    Future<void> pickAndCheck(WidgetTester tester, {required bool key}) async {
      await click(tester, find.text('Wrong').last);
      if (key) {
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      } else {
        await click(tester, find.text('Check'));
      }
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);
    }

    for (final byKey in [true, false]) {
      testWidgets(
          'G, F and Esc answer after Check by ${byKey ? 'key' : 'click'}',
          (tester) async {
        await pumpLive(tester);
        await pickAndCheck(tester, key: byKey);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
        await tester.pumpAndSettle();
        expect(find.text('Questions'), findsOneWidget);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Questions'), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsOneWidget);
      });
    }

    testWidgets('Esc answers after the flag button was clicked',
        (tester) async {
      await pumpLive(tester);
      await pickAndCheck(tester, key: true);
      await click(tester, find.byTooltip('Flag question'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Leave this session?'), findsOneWidget);
    });

    // The page's focus node can lose focus to its scope (a locked choice, a
    // busy button, the browser moving focus). The keys must come back.
    testWidgets('keys come back when focus falls out of the page',
        (tester) async {
      await pumpLive(tester);
      await pickAndCheck(tester, key: true);
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      expect(find.text('Questions'), findsOneWidget);
      FocusManager.instance.rootScope.requestFocus();
      await tester.pump();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Questions'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('Leave this session?'), findsOneWidget);
    });

    // Enter runs the control that holds focus, not the page's Check.
    String? picked() {
      final state = controller.state;
      return state is QuizRunning ? state.selectedChoiceId : null;
    }

    testWidgets('Enter on a focused answer picks it and does not check',
        (tester) async {
      await pumpLive(tester);
      await click(tester, find.text('Wrong').last);
      expect(picked(), 'b');
      // Tab to the other answer: it holds focus, and B is still the pick.
      Focus.of(tester.element(find.text('Right').last)).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(picked(), 'a', reason: 'Enter pressed the answer it was on');
      expect(find.text('Next'), findsNothing, reason: 'nothing was checked');
      expect(find.text('Check'), findsOneWidget);
    });

    testWidgets('Enter on the answer already picked checks it', (tester) async {
      await pumpLive(tester);
      await click(tester, find.text('Wrong').last);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('Enter on the Check button is the button press',
        (tester) async {
      await pumpLive(tester);
      await click(tester, find.text('Wrong').last);
      Focus.of(tester.element(find.text('Check'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);
    });

    // The real app hosts the page in a nested navigator (the web shell) and
    // opens dialogs on the root one, so the page's route stays "current".
    Future<void> pumpNested(WidgetTester tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final completed = completedSession(batch: true);
      before = completed.copyWith(
        currentIndex: 3,
        outcomes: completed.outcomes.take(3).toList(),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            flaggedIdsProvider.overrideWith((_) async => <String>{}),
            quizControllerProvider.overrideWith(
              (ref) => controller = _Controller(ref, before)
                ..afterCheck = before.copyWith(
                  outcomes: completed.outcomes.take(4).toList(),
                ),
            ),
          ],
          child: MaterialApp.router(
            theme: buildDarkTheme(web: true),
            routerConfig: GoRouter(
              initialLocation: '/quiz/session',
              routes: [
                ShellRoute(
                  builder: (_, __, child) => child,
                  routes: [
                    GoRoute(
                      path: '/quiz/session',
                      builder: (_, __) =>
                          const QuizPage(examId: 'e', proIsActive: false),
                    ),
                    GoRoute(
                      path: '/quiz',
                      builder: (_, __) => const Scaffold(body: Text('Tab')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // The Leave dialog owns the keys. Esc closes it, Enter is Keep Going, and
    // F, G and Enter reach nothing on the page behind it.
    group('Leave dialog keys', () {
      Future<void> openLeave(WidgetTester tester) async {
        await pumpNested(tester);
        await click(tester, find.text('Wrong').last);
        await tester.tap(find.byTooltip('Leave session'));
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsOneWidget);
      }

      // The page's own node, the one its shortcuts hang on.
      FocusNode pageNode(WidgetTester tester) =>
          Focus.of(tester.element(find.byType(Scaffold).first));

      Future<void> expectPageUntouched(WidgetTester tester) async {
        expect(find.text('Questions'), findsNothing, reason: 'G');
        expect(
          find.text('Flagged. Find it in the Quiz tab.'),
          findsNothing,
          reason: 'F',
        );
        expect(find.text('Next'), findsNothing, reason: 'Enter checked');
        expect(find.text('Check'), findsOneWidget);
      }

      testWidgets('focus starts inside the dialog, and Esc closes it',
          (tester) async {
        await openLeave(tester);
        final held = FocusManager.instance.primaryFocus!;
        expect(held, isNot(isA<FocusScopeNode>()));
        expect(ModalRoute.of(held.context!), isA<DialogRoute<bool>>());
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsNothing);
        await expectPageUntouched(tester);
      });

      testWidgets('Enter is Keep Going and checks nothing', (tester) async {
        await openLeave(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsNothing);
        await expectPageUntouched(tester);
      });

      testWidgets('F and G change nothing behind it', (tester) async {
        await openLeave(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Leave this session?'), findsOneWidget);
        await expectPageUntouched(tester);
      });

      testWidgets('Tab reaches Leave, and Enter on it leaves', (tester) async {
        await openLeave(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsNothing);
        expect(find.byType(QuizPage), findsNothing);
      });

      // The page can get the focus back while the dialog is up (the browser
      // moving it, a rebuilt control). Then the page still stays out of it.
      testWidgets('a page that has the focus yields to the dialog',
          (tester) async {
        await openLeave(tester);
        pageNode(tester).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(find.text('Leave this session?'), findsOneWidget);
        await expectPageUntouched(tester);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsNothing);
        await expectPageUntouched(tester);
      });
    });

    testWidgets('A and B pick a choice, and a letter past the last does not',
        (tester) async {
      await pumpLive(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
      expect(picked(), 'b');
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      expect(picked(), 'a');
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      expect(picked(), 'a', reason: 'the question has two choices');
    });

    group('with Keyboard Shortcuts off', () {
      testWidgets('A, B and E pick nothing', (tester) async {
        await pumpLive(tester, lettersOn: false);
        for (final key in [
          LogicalKeyboardKey.keyA,
          LogicalKeyboardKey.keyB,
          LogicalKeyboardKey.keyE,
        ]) {
          await tester.sendKeyEvent(key);
        }
        expect(picked(), isNull);
      });

      testWidgets('F does not flag and G does not open the list',
          (tester) async {
        await pumpLive(tester, lettersOn: false);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
        await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Flagged. Find it in the Quiz tab.'), findsNothing);
        expect(find.text('Questions'), findsNothing);
      });

      testWidgets('Esc still asks to leave and Enter still works',
          (tester) async {
        await pumpLive(tester, lettersOn: false);
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Leave this session?'), findsOneWidget);
      });
    });

    testWidgets('F flags and does not pick', (tester) async {
      await pumpLive(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.pump(const Duration(milliseconds: 500));
      expect(picked(), isNull);
      expect(find.text('Flagged. Find it in the Quiz tab.'), findsOneWidget);
    });

    testWidgets('F still flags after Check without adding a key hint',
        (tester) async {
      await pumpLive(tester);
      await pickAndCheck(tester, key: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Flagged. Find it in the Quiz tab.'), findsOneWidget);
      expect(find.text('F to flag'), findsNothing);
    });

    testWidgets('the letters pick nothing once the question is checked',
        (tester) async {
      await pumpLive(tester);
      await pickAndCheck(tester, key: true);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      expect(picked(), isNull);
    });

    testWidgets('Enter moves on after Check', (tester) async {
      await pumpLive(tester);
      await pickAndCheck(tester, key: false);
      var next = 0;
      controller.addListener((state) {
        if (state is QuizRunning && state.session.currentIndex == 4) next++;
      });
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(next, greaterThan(0));
    });
  });

  group('wide navigator and reveal', () {
    late _Controller controller;
    late QuizSession before;
    late QuizSession after;

    Future<void> pumpLive(WidgetTester tester, {bool still = false}) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final completed = completedSession(batch: true);
      before = completed.copyWith(
        currentIndex: 3,
        outcomes: completed.outcomes.take(3).toList(),
      );
      after = before.copyWith(outcomes: completed.outcomes.take(4).toList());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            flaggedIdsProvider.overrideWith((_) async => <String>{}),
            quizControllerProvider.overrideWith(
              (ref) => controller = _Controller(ref, before),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: still),
              child: child!,
            ),
            home: const QuizPage(examId: 'e', proIsActive: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    double revealOpacity(WidgetTester tester) => tester
        .widget<Opacity>(find.byKey(const ValueKey('web-answer-reveal')))
        .opacity;

    testWidgets('Check plays the reveal instead of showing its end at once',
        (tester) async {
      await pumpLive(tester);
      final openLeft = tester
          .getTopLeft(find.byKey(const ValueKey('web-question-column')).last)
          .dx;
      controller.checked(after);
      await tester.pump();
      Finder column() => find.byKey(const ValueKey('web-question-column')).last;
      await tester.pump(const Duration(milliseconds: 100));
      // Begun, not finished: the column has not moved and nothing shows yet.
      expect(tester.getTopLeft(column()).dx, closeTo(openLeft, .5));
      expect(revealOpacity(tester), 0);
      await tester.pump(const Duration(milliseconds: 600));
      final moving = tester.getTopLeft(column()).dx;
      expect(moving, lessThan(openLeft));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.getTopLeft(column()).dx, lessThan(moving));
      expect(revealOpacity(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(revealOpacity(tester), 1);
      expect(tester.getSize(column()).width, 600);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the column slides without changing width, so nothing re-wraps',
        (tester) async {
      await pumpLive(tester);
      controller.checked(after);
      await tester.pump();
      final widths = <double>{};
      for (var ms = 0; ms < 1900; ms += 50) {
        widths.add(
          tester
              .getSize(find.byKey(const ValueKey('web-question-column')).last)
              .width,
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(widths, {600.0});
    });

    testWidgets('reduced motion shows the finished reveal at once',
        (tester) async {
      await pumpLive(tester, still: true);
      controller.checked(after);
      await tester.pump();
      expect(revealOpacity(tester), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the counter and flag carry the names the phone gives them',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpLive(tester);
      expect(
        find.bySemanticsLabel('Question 4 of 10. Open question navigator'),
        findsOneWidget,
      );
      final flag =
          tester.getSemantics(find.bySemanticsLabel('Flag question 4'));
      expect(flag.flagsCollection.isButton, isTrue);
      // A switch, not a plain button: it says whether the flag is on.
      expect(flag.flagsCollection.isToggled, isNot(Tristate.none));
      semantics.dispose();
    });

    testWidgets('the navigator is five to a row and marks where you are',
        (tester) async {
      await pumpLive(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      Offset cell(int n) =>
          tester.getTopLeft(find.byKey(ValueKey('web-grid-question-$n')));
      for (var n = 1; n < 5; n++) {
        expect(cell(n).dy, cell(0).dy);
        expect(cell(n).dx, greaterThan(cell(n - 1).dx));
      }
      expect(cell(5).dy, greaterThan(cell(0).dy));
      expect(cell(5).dx, cell(0).dx);
      // The title and the grid share one left edge.
      expect(cell(0).dx, tester.getTopLeft(find.text('Questions')).dx);
      // Question 4 is on screen: the dark edge sits on it and no other cell.
      BorderSide edge(int n) {
        final cell = tester
            .widgetList<DecoratedBox>(
              find.descendant(
                of: find.byKey(ValueKey('web-grid-question-$n')),
                matching: find.byType(DecoratedBox),
              ),
            )
            .where((box) => box.position == DecorationPosition.background)
            .map((box) => box.decoration)
            .whereType<BoxDecoration>()
            .first;
        final border = cell.border;
        return border is Border ? border.top : BorderSide.none;
      }

      expect(edge(3).width, 2);
      expect(edge(2).style, BorderStyle.none);
      expect(edge(4).width, 1);
      // Looking back at 2 moves the edge and leaves the grid open.
      await tester.tap(find.byKey(const ValueKey('web-grid-question-1')));
      await tester.pumpAndSettle();
      expect(find.text('Questions'), findsOneWidget);
      expect(edge(1).width, 2);
      expect(edge(3).width, 1);
    });
  });

  // Fourth sweep (4O): the wide question page, as it is on screen.
  group('wide question page, fourth sweep', () {
    late QuizSession before;

    Future<void> pump(
      WidgetTester tester, {
      Set<String> flagged = const {},
      QuizSession? session,
      List<Override> extra = const [],
      bool checkable = false,
    }) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final completed = completedSession(batch: true);
      before = session ??
          completed.copyWith(
            currentIndex: 3,
            outcomes: completed.outcomes.take(3).toList(),
          );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            flaggedIdsProvider.overrideWith((_) async => flagged),
            quizControllerProvider.overrideWith(
              (ref) => _Controller(ref, before)
                ..afterCheck = checkable
                    ? before.copyWith(
                        outcomes: completed.outcomes.take(4).toList(),
                      )
                    : null,
            ),
            ...extra,
          ],
          child: MaterialApp(
            theme: buildDarkTheme(web: true),
            home: const QuizPage(examId: 'e', proIsActive: false),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('4O-1: the title is centered on the page', (tester) async {
      await pump(tester);
      final title = tester.getCenter(find.text('Reviews · Session 1 of 2'));
      expect(title.dx, closeTo(720, .5));
    });

    testWidgets('4O-4: each answer takes one Tab stop', (tester) async {
      await pump(tester);
      final stops = <FocusNode>[];
      for (var i = 0; i < 30; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final focused = FocusManager.instance.primaryFocus!;
        if (stops.contains(focused)) break;
        stops.add(focused);
      }
      final onChoice = [
        for (final node in stops)
          if (node.context?.findAncestorWidgetOfExactType<WebAnswerOption>() !=
              null)
            node.rect.topLeft,
      ];
      expect(onChoice, hasLength(2));
      expect(
        onChoice.toSet().length,
        onChoice.length,
        reason: 'a choice was visited twice: $onChoice',
      );
    });

    testWidgets('4O-6: the grid opens whole over the flag toast',
        (tester) async {
      await pump(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Flagged. Find it in the Quiz tab.'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('Flagged. Find it in the Quiz tab.'), findsNothing);
      expect(
        find.text('Click any answered question to go back to it.'),
        findsOneWidget,
      );
    });

    testWidgets('4O-6: a grid opened before the toast appears keeps the spot',
        (tester) async {
      await pump(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('Flagged. Find it in the Quiz tab.'), findsNothing);
    });

    testWidgets('4O-7: a flagged question is marked in the grid',
        (tester) async {
      await pump(tester, flagged: {'q1'});
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      Finder mark(int n) => find.descendant(
            of: find.byKey(ValueKey('web-grid-question-$n')),
            matching: find.byKey(const ValueKey('web-grid-flag')),
          );
      expect(mark(1), findsOneWidget);
      expect(mark(0), findsNothing);
      expect(mark(2), findsNothing);
      // Inside the cell, so the grid does not cut it.
      final cell =
          tester.getRect(find.byKey(const ValueKey('web-grid-question-1')));
      expect(cell.contains(tester.getCenter(mark(1))), isTrue);
    });

    testWidgets('5R-5: the grid is a floating card, clear of the bar',
        (tester) async {
      await pump(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      final card = find.ancestor(
        of: find.text('Questions'),
        matching: find.byType(WebCard),
      );
      expect(tester.widget<WebCard>(card).floating, isTrue);
      final decoration = tester
          .widget<Container>(
            find.descendant(of: card, matching: find.byType(Container)).first,
          )
          .decoration! as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, isNotEmpty);
      // It sits 12 px above the bar.
      final bar = find.byType(WebBottomBar);
      expect(
        tester.getRect(bar).top - tester.getRect(card).bottom,
        closeTo(12, 1),
      );
    });

    testWidgets('4O-12: the next question opens with no choice focused',
        (tester) async {
      await pump(tester, checkable: true);
      final wrong = find.text('Wrong').last;
      await tester.tap(wrong);
      Focus.of(tester.element(wrong)).requestFocus();
      await tester.pump();
      FocusNode? focused() => FocusManager.instance.primaryFocus;
      bool onChoice() =>
          focused()
              ?.context
              ?.findAncestorWidgetOfExactType<WebAnswerOption>() !=
          null;
      expect(onChoice(), isTrue, reason: 'the clicked choice holds focus');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Next'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('5 of 10'), findsOneWidget);
      expect(onChoice(), isFalse);
      // The page's keys still answer.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
      await tester.pumpAndSettle();
      expect(find.text('Questions'), findsOneWidget);
    });

    testWidgets('4O-11: the flag button keeps focus while the flag saves',
        (tester) async {
      final gate = Completer<void>();
      await pump(
        tester,
        extra: [
          questionFlagControllerProvider.overrideWith(() => _SlowFlags(gate)),
        ],
      );
      final flag = find.byTooltip('Flag question');
      // The button's own focus node, one level inside the tooltip.
      Focus.of(
        tester.element(
          find.descendant(of: flag, matching: find.byType(WebFlagIcon)),
        ),
      ).requestFocus();
      await tester.pump();
      final held = FocusManager.instance.primaryFocus;
      expect(
        held?.context?.findAncestorWidgetOfExactType<IconButton>(),
        isNotNull,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump(const Duration(milliseconds: 50));
      // Saving: the button is busy, and the ring has not moved.
      expect(FocusManager.instance.primaryFocus, held);
      gate.complete();
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, held);
    });
  });
}
