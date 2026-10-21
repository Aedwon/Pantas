import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

void main() {
  const exam = Exam(
    id: 'e',
    code: 'E',
    name: 'Exam',
    shortName: 'Exam',
    language: 'en',
    isActive: true,
    subjects: [],
  );
  var state =
      const SessionPanelInProgress(position: 6, total: 10) as SessionPanelState;
  const counts = QuizTodayCounts(
    reviewsDone: 12,
    reviewsTotal: 18,
    newDone: 3,
    newTotal: 7,
  );

  Future<void> pump(
    WidgetTester tester, {
    bool dark = false,
    double scale = 1,
    bool still = false,
    GoRouter? router,
    bool noExam = false,
    bool empty = false,
  }) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeExamFocusProvider.overrideWith(
            (_) async => noExam
                ? const ActiveExamFocus.needsSelection()
                : const ActiveExamFocus.selected(exam),
          ),
          sessionPanelProvider('e').overrideWith((_) async => state),
          quizTodayCountsProvider('e').overrideWith((_) async => counts),
          quizPracticeCountsProvider('e').overrideWith(
            (_) async =>
                empty ? (mistakes: 0, flags: 0) : (mistakes: 28, flags: 12),
          ),
        ],
        child: router == null
            ? MaterialApp(
                theme: dark ? buildDarkTheme() : buildLightTheme(),
                home: MediaQuery(
                  data: MediaQueryData(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: still,
                  ),
                  child: const QuizTabScreen(),
                ),
              )
            : MaterialApp.router(
                theme: buildLightTheme(),
                routerConfig: router,
              ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('paused tab at dark=$dark scale=$scale', (tester) async {
        state = const SessionPanelInProgress(position: 6, total: 10);
        await pump(tester, dark: dark, scale: scale, still: true);
        expect(
          find.text('You paused. Every answer was saved.'),
          findsOneWidget,
        );
        expect(find.text('6 of 10'), findsNothing);
        expect(find.text('Resume'), findsOneWidget);
        expect(find.text('3 of 7'), findsOneWidget);
        final row = find.ancestor(
          of: find.text('Customize your own'),
          matching: find.byType(ListRow),
        );
        expect(tester.widget<ListRow>(row).onTap, isNull);
        final reviewsRow = find.ancestor(
          of: find.text('Reviews'),
          matching: find.byType(ListRow),
        );
        expect(tester.widget<ListRow>(reviewsRow).value, '12 of 18');
        final dim = find.ancestor(of: row, matching: find.byType(Opacity));
        expect(tester.widget<Opacity>(dim.first).opacity, .45);
        expect(
          find.text('Finish or discard your paused quiz first'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('assessment and empty rows at dark=$dark scale=$scale',
          (tester) async {
        state = const SessionPanelNeedsAssessment(30);
        await pump(tester, dark: dark, scale: scale, empty: true, still: true);
        expect(find.text('First, a short assessment'), findsOneWidget);
        expect(find.text('Nothing to fix yet'), findsOneWidget);
        expect(find.text('Flag a question to come back to it'), findsOneWidget);
        expect(find.text('Resume'), findsNothing);
        expect(tester.takeException(), isNull);
      });

      testWidgets('completed tab at dark=$dark scale=$scale', (tester) async {
        state = const SessionPanelCaughtUp(answeredToday: 25, correctToday: 20);
        await pump(tester, dark: dark, scale: scale, still: true);
        expect(find.text("That's all for today."), findsOneWidget);
        expect(find.text('Resume'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('#23 assessment completion clears the Quiz assessment gate',
      (tester) async {
    state = const SessionPanelNeedsAssessment(30);
    final router = GoRouter(
      initialLocation: '/quiz',
      routes: [
        GoRoute(path: '/quiz', builder: (_, __) => const QuizTabScreen()),
        GoRoute(
          path: '/assessment/e',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () {
                state = const SessionPanelCaughtUp(
                  answeredToday: 30,
                  correctToday: 24,
                );
                context.pop();
              },
              child: const Text('Complete assessment'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await pump(tester, router: router, empty: true);
    await tester.tap(find.text('Start Assessment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete assessment'));
    await tester.pumpAndSettle();
    expect(find.text('First, a short assessment'), findsNothing);
    expect(find.text("That's all for today."), findsOneWidget);
  });

  testWidgets('#24 #27 #28 one Resume returns to the saved session and clears',
      (tester) async {
    state = const SessionPanelInProgress(position: 6, total: 10);
    final router = GoRouter(
      initialLocation: '/quiz',
      routes: [
        GoRoute(path: '/quiz', builder: (_, __) => const QuizTabScreen()),
        GoRoute(
          path: '/quiz/resume/e',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () {
                state = const SessionPanelCaughtUp(
                  answeredToday: 10,
                  correctToday: 8,
                );
                context.pop();
              },
              child: const Text('Finish saved session'),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await pump(tester, router: router);
    expect(find.text('Resume'), findsOneWidget);
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();
    expect(find.text('Finish saved session'), findsOneWidget);
    await tester.tap(find.text('Finish saved session'));
    await tester.pumpAndSettle();
    expect(find.text('Resume'), findsNothing);
    expect(find.text("That's all for today."), findsOneWidget);
  });

  testWidgets('mixed Today never claims a Reviews-only launch', (tester) async {
    state = const SessionPanelAvailable(
      plan: TodaySessionPlan(
        questions: [],
        dueCount: 4,
        weaknessCount: 0,
        freshCount: 1,
      ),
    );
    await pump(tester, still: true);
    expect(find.text('Continue Reviews'), findsNothing);
    expect(find.text('Resume'), findsNothing);
  });
}
