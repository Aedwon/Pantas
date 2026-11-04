import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';

import '../../../helpers/in_memory_database.dart';
import 'session_end_screen_test.dart' show completedSession;

class _Controller extends QuizController {
  _Controller(super.ref, QuizSession session) {
    state = QuizRunning(session: session, questionShownAt: DateTime.utc(2026));
  }

  /// Swaps in the session after the student checked an answer.
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
      controller.checked(after);
      await tester.pump();
      double columnWidth() => tester
          .getSize(find.byKey(const ValueKey('web-question-column')).last)
          .width;
      await tester.pump(const Duration(milliseconds: 100));
      // Begun, not finished: the column has not moved and nothing shows yet.
      expect(columnWidth(), 720);
      expect(revealOpacity(tester), 0);
      await tester.pump(const Duration(milliseconds: 600));
      expect(columnWidth(), inExclusiveRange(600, 720));
      await tester.pump(const Duration(milliseconds: 600));
      expect(revealOpacity(tester), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(revealOpacity(tester), 1);
      expect(
        tester
            .getSize(find.byKey(const ValueKey('web-question-column')).last)
            .width,
        600,
      );
      expect(tester.hasRunningAnimations, isFalse);
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
      ShapeBorder? shape(int n) => tester
          .widget<TextButton>(
            find.descendant(
              of: find.byKey(ValueKey('web-grid-question-$n')),
              matching: find.byType(TextButton),
            ),
          )
          .style
          ?.shape
          ?.resolve({});
      BorderSide edge(int n) => (shape(n)! as RoundedRectangleBorder).side;
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
}
