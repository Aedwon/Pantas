import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

import '../../../helpers/pump_app.dart' show buildExam;

class _Work implements TodayQuestionWork {
  @override
  List<int> get reviewSizes => [10, 4];
  @override
  List<int> get reviewProgress => [0, 0];
  @override
  int get reviewsDone => 0;
  @override
  int get reviewsTotal => 14;
  @override
  int get newDone => 0;
  @override
  int get newTotal => 7;
  @override
  List<({String title, int done, int total})> get newRows =>
      [(title: 'Algebra', done: 0, total: 7)];
  @override
  List<Question> get newQuestions => const [
        Question(
          id: 'q',
          version: 1,
          examIds: ['e'],
          topicId: 't',
          language: 'en',
          stem: 'Stem',
          choices: [],
          explanation: '',
        ),
      ];
  @override
  bool pausedHere(TodayQuestionKind kind) => false;
  @override
  bool pausedElsewhere(TodayQuestionKind kind) => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Launcher extends TodayQuestionLauncher {
  _Launcher(Ref ref) : super(ref, () => true);
  @override
  Future<Future<bool> Function()> captureGuard(
    String examId, {
    required bool Function() isAlive,
  }) async =>
      () async => isAlive();
  @override
  Future<TodayQuestionWork> load(
    String examId, {
    Future<Future<bool> Function()>? originalGuard,
  }) async =>
      _Work();
}

void main() {
  for (final row in ['Reviews', 'New questions']) {
    testWidgets('wide Quiz tab $row drawer: Close X centres on the title block',
        (tester) async {
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeExamFocusProvider.overrideWith(
              (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
            ),
            sessionPanelProvider('e').overrideWith(
              (_) async => const SessionPanelAvailable(
                plan: TodaySessionPlan(
                  questions: [],
                  dueCount: 14,
                  weaknessCount: 0,
                  freshCount: 0,
                ),
              ),
            ),
            todayQuestionLauncherProvider.overrideWith(_Launcher.new),
            quizTodayCountsProvider('e').overrideWith(
              (_) async => const QuizTodayCounts(
                reviewsDone: 0,
                reviewsTotal: 14,
                newDone: 0,
                newTotal: 7,
              ),
            ),
            quizPracticeCountsProvider('e')
                .overrideWith((_) async => (mistakes: 28, flags: 12)),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: const Scaffold(
              body: MediaQuery(
                data: MediaQueryData(
                  size: Size(1440, 900),
                  disableAnimations: true,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(288, 28, 44, 44),
                  child: QuizTabScreen(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(row).first);
      await tester.pumpAndSettle();
      final drawer = find.byKey(const ValueKey('home-web-drawer'));
      final title = tester.getRect(
        find.descendant(of: drawer, matching: find.text(row)),
      );
      final count = find.descendant(
        of: drawer,
        matching: find.textContaining(RegExp(r'^\d+ of \d+$')),
      );
      final close = tester.getCenter(find.byTooltip('Close')).dy;
      if (row == 'Reviews') {
        expect(count, findsNothing);
        expect(close, closeTo((title.top + title.bottom) / 2, 0.6));
      } else {
        // The two-line header keeps its measured spot, as on Home.
        expect(count, findsWidgets);
        expect(close, closeTo(50.5, 0.1));
      }
    });
  }
}
