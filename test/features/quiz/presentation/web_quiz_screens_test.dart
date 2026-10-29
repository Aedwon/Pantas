import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';
import 'package:pantas/features/quiz/presentation/web_session_results.dart';

import '../../../helpers/pump_app.dart' show buildExam;
import 'session_end_screen_test.dart' show completedAttempt, completedSession;

class _ReviewWork implements TodayQuestionWork {
  @override
  List<int> get reviewSizes => [10, 10, 4];
  @override
  List<int> get reviewProgress => [10, 0, 0];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    required bool dark,
    List<Override> overrides = const [],
  }) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                size: Size(1440, 900),
                disableAnimations: true,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    for (final state in <SessionPanelState>[
      const SessionPanelAvailable(
        plan: TodaySessionPlan(
          questions: [],
          dueCount: 14,
          weaknessCount: 0,
          freshCount: 0,
        ),
      ),
      const SessionPanelNeedsAssessment(30),
      const SessionPanelInProgress(position: 6, total: 10),
      const SessionPanelCaughtUp(answeredToday: 25, correctToday: 20),
    ]) {
      testWidgets('wide tab ${state.runtimeType} dark=$dark', (tester) async {
        await pump(
          tester,
          const Padding(
            padding: EdgeInsets.fromLTRB(288, 28, 44, 44),
            child: QuizTabScreen(
              mockPanel: MockCard(
                model: MockCardModel(
                  state: MockCardState.waiting,
                  name: 'CSE simulation',
                  durationMinutes: 190,
                  lastPercent: 69,
                ),
              ),
            ),
          ),
          dark: dark,
          overrides: [
            activeExamFocusProvider.overrideWith(
              (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
            ),
            sessionPanelProvider('e').overrideWith((_) async => state),
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
        );
        expect(find.text('Quiz'), findsOneWidget);
        expect(find.text('CSE simulation'), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('CSE simulation')).dx,
          greaterThan(tester.getTopLeft(find.text('Your past mistakes')).dx),
        );
        if (state is SessionPanelAvailable) {
          expect(find.text('Reviews · Session 2 of 3'), findsOneWidget);
          expect(find.text('Continue Reviews'), findsOneWidget);
        }
        if (state is SessionPanelNeedsAssessment) {
          expect(find.text('First, a short assessment'), findsOneWidget);
        }
        if (state is SessionPanelInProgress) {
          expect(
            find.text('You paused. Every answer was saved.'),
            findsOneWidget,
          );
        }
        if (state is SessionPanelCaughtUp) {
          expect(find.text("That's all for today."), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }
    for (final correct in [2, 7, 10]) {
      for (final pro in [false, true]) {
        testWidgets('wide result $correct pro=$pro dark=$dark', (tester) async {
          final session = completedSession(correct: correct, batch: true);
          await pump(
            tester,
            SessionEndBody(
              session: session,
              attempt: completedAttempt(session),
              subjectNames: const {'t': 'Science'},
              proIsActive: pro,
              onDone: () {},
              onQuestion: (_) {},
              onAll: () {},
              onMistakes: () {},
              onNotes: () {},
              onNext: () async {},
            ),
            dark: dark,
          );
          expect(
            find.text(correct == 10 ? 'Perfect!' : 'Session finished.'),
            findsOneWidget,
          );
          expect(find.text('Done'), findsOneWidget);
          expect(tester.getSize(find.byType(WebCard).first).width, 640);
          expect(
            tester.getSize(find.byKey(const ValueKey('half-ring-paint'))).width,
            320,
          );
          expect(find.text('See all 10 questions'), findsOneWidget);
          expect(find.text('Start Session 2'), findsOneWidget);
          expect(
            find.text('Finish the Notes'),
            pro && correct < 10 ? findsOneWidget : findsNothing,
          );
          if (correct == 2) {
            expect(find.text('See all 8 mistakes'), findsOneWidget);
          }
          expect(tester.getTopLeft(find.text('Done')).dy, lessThan(100));
          expect(tester.takeException(), isNull);
        });
      }
    }
    for (final mistakesOnly in [false, true]) {
      testWidgets('wide question list mistakes=$mistakesOnly dark=$dark',
          (tester) async {
        final session = completedSession();
        int? selected;
        await pump(
          tester,
          WebQuizQuestionList(
            session: session,
            attempt: completedAttempt(session),
            subjectNames: const {'t': 'Science'},
            mistakesOnly: mistakesOnly,
            onBack: () {},
            onQuestion: (index) => selected = index,
          ),
          dark: dark,
        );
        expect(
          find.text(mistakesOnly ? 'Your mistakes' : 'All questions'),
          findsOneWidget,
        );
        expect(find.text('7 of 10 correct'), findsOneWidget);
        await tester.tap(find.text('Question 7'));
        expect(selected, 7);
        if (mistakesOnly) expect(find.text('Question 0'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
    testWidgets('wide results loading dark=$dark', (tester) async {
      await pump(tester, const WebDebriefLoading(), dark: dark);
      expect(find.byType(WebDebriefLoading), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
