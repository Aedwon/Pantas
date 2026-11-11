import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_tap_area.dart';
import 'package:pantas/core/ui/components/progress_ring.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/quiz/data/repos/practice_preferences_repository.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_screen.dart';
import 'package:pantas/features/quiz/presentation/quiz_note_editor.dart';
import 'package:pantas/features/quiz/presentation/quiz_question_viewer.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart' show buildExam;
import 'practice_picker_screen_test.dart' show index;
import 'quiz_question_viewer_test.dart' show items, questions;
import 'session_end_screen_test.dart' show completedAttempt, completedSession;

class _ReviewWork implements TodayQuestionWork {
  @override
  List<int> get reviewSizes => [10, 10, 4];
  @override
  List<int> get reviewProgress => [10, 0, 0];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// How visible [target] is: the product of every fade above it.
double shown(WidgetTester tester, Finder target) {
  var value = 1.0;
  for (final element
      in find.ancestor(of: target, matching: find.byType(Opacity)).evaluate()) {
    value *= (element.widget as Opacity).opacity;
  }
  for (final element in find
      .ancestor(of: target, matching: find.byType(FadeTransition))
      .evaluate()) {
    value *= (element.widget as FadeTransition).opacity.value;
  }
  return value;
}

void main() {
  void wide(WidgetTester tester) {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget app(
    Widget home, {
    required bool still,
    List<Override> overrides = const [],
  }) =>
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: still),
            child: child!,
          ),
          home: home,
        ),
      );

  for (final still in [false, true]) {
    final mode = still ? 'reduced motion' : 'full motion';

    testWidgets('Q1 wide Quiz tab enters with the phone stagger, $mode',
        (tester) async {
      wide(tester);
      await tester.pumpWidget(
        app(
          const Scaffold(
            body: Padding(
              padding: EdgeInsets.fromLTRB(288, 28, 44, 44),
              child: QuizTabScreen(),
            ),
          ),
          still: still,
          overrides: [
            activeExamFocusProvider.overrideWith(
              (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
            ),
            sessionPanelProvider('e').overrideWith(
              (_) async => const SessionPanelCaughtUp(
                answeredToday: 25,
                correctToday: 20,
              ),
            ),
            todayQuestionWorkProvider('e')
                .overrideWith((_) async => _ReviewWork()),
            quizTodayCountsProvider('e').overrideWith(
              (_) async => const QuizTodayCounts(
                reviewsDone: 18,
                reviewsTotal: 32,
                newDone: 7,
                newTotal: 7,
              ),
            ),
            quizPracticeCountsProvider('e')
                .overrideWith((_) async => (mistakes: 28, flags: 12)),
          ],
        ),
      );
      final more = find.text('MORE WAYS TO PRACTICE');
      for (var i = 0; i < 10 && more.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(more, findsOneWidget);
      if (still) {
        expect(shown(tester, more), 1);
        return;
      }
      // The practice block holds 280 ms, then rises through 450 ms.
      expect(shown(tester, more), 0);
      await tester.pump(const Duration(milliseconds: 450));
      final mid = shown(tester, more);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(1));
      await tester.pumpAndSettle();
      expect(shown(tester, more), 1);
    });

    testWidgets('Q2 wide topic unfold and caret follow the phone, $mode',
        (tester) async {
      wide(tester);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.pumpWidget(
        app(
          const Scaffold(
            body: Padding(
              padding: EdgeInsets.fromLTRB(288, 28, 44, 44),
              child: PracticePickerScreen(examId: 'e'),
            ),
          ),
          still: still,
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            practicePreferencesRepositoryProvider
                .overrideWithValue(PracticePreferencesRepository(db)),
            practiceIndexProvider('e').overrideWith((_) async => index),
            practicePaceProvider('e').overrideWith((_) async => 50000),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final lessons = find.byKey(const ValueKey('web-lessons-t'));
      final caret = find.descendant(
        of: find.byKey(const ValueKey('web-caret-t')),
        matching: find.byType(RotationTransition),
      );
      double turns() => tester.widget<RotationTransition>(caret).turns.value;
      expect(find.text('Linear equations'), findsNothing);
      await tester.tap(find.byTooltip('Show lessons in Algebra'));
      await tester.pump();
      expect(find.byTooltip('Hide lessons in Algebra'), findsOneWidget);
      if (still) {
        expect(lessons, findsNothing);
        expect(find.text('Linear equations'), findsOneWidget);
        expect(turns(), .5);
        return;
      }
      await tester.pump(const Duration(milliseconds: 100));
      final partial = tester.getSize(lessons).height;
      expect(partial, greaterThan(0));
      expect(turns(), greaterThan(0));
      expect(turns(), lessThan(.5));
      await tester.pumpAndSettle();
      expect(tester.getSize(lessons).height, greaterThan(partial));
      expect(turns(), .5);
      await tester.tap(find.byTooltip('Hide lessons in Algebra'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byTooltip('Show lessons in Algebra'), findsOneWidget);
      expect(find.text('Linear equations'), findsNothing);
      await tester.pumpAndSettle();
      expect(tester.getSize(lessons).height, 0);
      expect(turns(), 0);
    });

    testWidgets('Q8 wide Today rings fill like the phone, $mode',
        (tester) async {
      wide(tester);
      await tester.pumpWidget(
        app(
          const Scaffold(
            body: Padding(
              padding: EdgeInsets.fromLTRB(288, 28, 44, 44),
              child: QuizTabScreen(),
            ),
          ),
          still: still,
          overrides: [
            activeExamFocusProvider.overrideWith(
              (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
            ),
            sessionPanelProvider('e').overrideWith(
              (_) async => const SessionPanelCaughtUp(
                answeredToday: 25,
                correctToday: 20,
              ),
            ),
            todayQuestionWorkProvider('e')
                .overrideWith((_) async => _ReviewWork()),
            quizTodayCountsProvider('e').overrideWith(
              (_) async => const QuizTodayCounts(
                reviewsDone: 18,
                reviewsTotal: 32,
                newDone: 3,
                newTotal: 7,
              ),
            ),
            quizPracticeCountsProvider('e')
                .overrideWith((_) async => (mistakes: 28, flags: 12)),
          ],
        ),
      );
      for (var i = 0;
          i < 30 && find.byType(ProgressRing).evaluate().isEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      final rings = tester.widgetList<ProgressRing>(find.byType(ProgressRing));
      expect(rings, hasLength(2));
      expect(
        [for (final ring in rings) ring.fillDuration],
        everyElement(const Duration(milliseconds: 700)),
      );
      expect(
        [for (final ring in rings) ring.fillDelay],
        const [Duration(milliseconds: 500), Duration(milliseconds: 620)],
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('Q7 wide Your quiz card and Clear change like the phone, $mode',
        (tester) async {
      wide(tester);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.pumpWidget(
        app(
          const Scaffold(
            body: Padding(
              padding: EdgeInsets.fromLTRB(288, 28, 44, 44),
              child: PracticePickerScreen(examId: 'e'),
            ),
          ),
          still: still,
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            practicePreferencesRepositoryProvider
                .overrideWithValue(PracticePreferencesRepository(db)),
            practiceIndexProvider('e').overrideWith((_) async => index),
            practicePaceProvider('e').overrideWith((_) async => 50000),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final empty = find.text('Nothing picked yet');
      final picked = find.text('2 lessons picked');
      final clear = find.text('Clear');
      // The topic unfolds also use an AnimatedSize; the card's is top aligned.
      final card = find.byWidgetPredicate(
        (w) => w is AnimatedSize && w.alignment == Alignment.topCenter,
      );
      double cardHeight() => tester.getSize(card).height;
      expect(clear, findsNothing);
      final emptyHeight = still ? 0.0 : cardHeight();
      await tester.tap(find.text('Algebra'));
      await tester.pump();
      if (still) {
        expect(empty, findsNothing);
        expect(shown(tester, picked), 1);
        expect(shown(tester, clear), 1);
        await tester.tap(clear);
        await tester.pump();
        expect(picked, findsNothing);
        expect(shown(tester, empty), 1);
        expect(clear, findsNothing);
        return;
      }
      // Both bodies fade over 200 ms and the card sizes to the new one.
      await tester.pump(const Duration(milliseconds: 100));
      expect(shown(tester, empty), inExclusiveRange(0, 1));
      expect(shown(tester, picked), inExclusiveRange(0, 1));
      expect(shown(tester, clear), inExclusiveRange(0, 1));
      final sizing = cardHeight();
      expect(sizing, greaterThan(emptyHeight));
      await tester.pumpAndSettle();
      expect(empty, findsNothing);
      expect(shown(tester, picked), 1);
      expect(shown(tester, clear), 1);
      expect(cardHeight(), greaterThan(sizing));
      await tester.tap(clear);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(picked, findsOneWidget);
      expect(shown(tester, picked), inExclusiveRange(0, 1));
      expect(shown(tester, empty), inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(picked, findsNothing);
      expect(clear, findsNothing);
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('Q4 wide note editor fades and sizes with the phone, $mode',
        (tester) async {
      wide(tester);
      await tester.pumpWidget(
        app(
          QuizQuestionViewer(
            questions: questions,
            items: items,
            pro: true,
            onBack: () {},
            onNote: (_, __, ___) async {},
            onReport: (_) async => true,
          ),
          still: still,
        ),
      );
      await tester.pumpAndSettle();
      final slot = find.byKey(const ValueKey('web-note-reveal-q1'));
      expect(find.byType(QuizNoteEditor), findsOneWidget);
      final full = tester.getSize(slot).height;
      await tester.tap(find.text('Not Now'));
      await tester.pump();
      if (still) {
        expect(find.byType(QuizNoteEditor), findsNothing);
      } else {
        // Closing takes 720 ms and the editor stays until it ends.
        await tester.pump(const Duration(milliseconds: 300));
        final closing = tester.getSize(slot).height;
        expect(find.byType(QuizNoteEditor), findsOneWidget);
        expect(closing, greaterThan(0));
        expect(closing, lessThan(full));
        await tester.pumpAndSettle();
        expect(find.byType(QuizNoteEditor), findsNothing);
      }
      expect(tester.getSize(slot).height, 0);
      await tester.tap(find.byTooltip('Edit Note'));
      await tester.pump();
      if (still) {
        expect(tester.getSize(slot).height, full);
        expect(shown(tester, find.byType(QuizNoteEditor)), 1);
        return;
      }
      // Opening takes 420 ms: first the size grows, then the editor fades in.
      await tester.pump(const Duration(milliseconds: 100));
      final opening = tester.getSize(slot).height;
      expect(opening, greaterThan(0));
      expect(opening, lessThan(full));
      expect(shown(tester, find.byType(QuizNoteEditor)), lessThan(1));
      await tester.pumpAndSettle();
      expect(tester.getSize(slot).height, full);
      expect(shown(tester, find.byType(QuizNoteEditor)), 1);
    });

    testWidgets('Q5 wide results appear in the phone stagger, $mode',
        (tester) async {
      wide(tester);
      final session = completedSession(correct: 2);
      await tester.pumpWidget(
        app(
          Scaffold(
            body: SessionEndBody(
              session: session,
              attempt: completedAttempt(session),
              subjectNames: const {'t': 'Science'},
              proIsActive: true,
              onDone: () {},
              onQuestion: (_) {},
              onAll: () {},
              onMistakes: () {},
              onNotes: () {},
            ),
          ),
          still: still,
        ),
      );
      await tester.pump();
      final title = find.text('Session finished.');
      final first = find.widgetWithText(PantasTapArea, '1');
      final last = find.widgetWithText(PantasTapArea, '10');
      final minutes = find.text('in 9 minutes');
      final notes = find.text('Finish the Notes');
      if (still) {
        for (final target in [title, first, last, minutes, notes]) {
          expect(shown(tester, target), 1);
        }
        return;
      }
      for (final target in [title, first, last, minutes, notes]) {
        expect(shown(tester, target), 0);
      }
      // 600 ms in: the title is done and the first circle is popping.
      await tester.pump(const Duration(milliseconds: 600));
      expect(shown(tester, title), 1);
      expect(shown(tester, first), greaterThan(0));
      expect(shown(tester, last), 0);
      expect(shown(tester, notes), 0);
      // 1.3 s in the last circle pops (400 + 9 x 90 ms) and the notes wait.
      await tester.pump(const Duration(milliseconds: 700));
      expect(shown(tester, last), greaterThan(0));
      expect(shown(tester, notes), 0);
      await tester.pumpAndSettle();
      for (final target in [title, first, last, minutes, notes]) {
        expect(shown(tester, target), 1);
      }
    });

    testWidgets('Q6 wide report slides in and out like the phone, $mode',
        (tester) async {
      wide(tester);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final queue = ReportQueue(db);
      await tester.pumpWidget(
        app(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => openQuestionReport(context, 'q', queue: queue),
                child: const Text('Report'),
              ),
            ),
          ),
          still: still,
        ),
      );
      await tester.tap(find.text('Report'));
      await tester.pump();
      final form = find.byType(ReportForm);
      // The dialog motion (Dialog README): a 24 px rise and a fade; reduced
      // motion fades in place over 150 ms with no rise.
      if (still) {
        await tester.pump(const Duration(milliseconds: 60));
        expect(shown(tester, form), greaterThan(0));
        expect(shown(tester, form), lessThan(1));
        final top = tester.getTopLeft(form).dy;
        await tester.pump(const Duration(milliseconds: 200));
        expect(shown(tester, form), 1);
        expect(tester.getTopLeft(form).dy, top);
        await tester.tap(find.byTooltip('Close report'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));
        expect(form, findsOneWidget);
        expect(shown(tester, form), lessThan(1));
        await tester.pumpAndSettle();
        expect(form, findsNothing);
        return;
      }
      await tester.pump(const Duration(milliseconds: 150));
      expect(shown(tester, form), greaterThan(0));
      expect(shown(tester, form), lessThan(1));
      final rising = tester.getTopLeft(form).dy;
      await tester.pumpAndSettle();
      expect(shown(tester, form), 1);
      expect(tester.getTopLeft(form).dy, lessThan(rising));
      await tester.tap(find.byTooltip('Close report'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(form, findsOneWidget);
      expect(shown(tester, form), lessThan(1));
      await tester.pumpAndSettle();
      expect(form, findsNothing);
    });
  }
}
