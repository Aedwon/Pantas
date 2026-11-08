// Design system 4.0, Quiz family: every quiz screen at 390, 1100 and 1440
// wide, light and dark, at text scale 1.0 and 2.0, with no layout overflow.
// The phone flag position (D71) is checked at 360 and 420 wide.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';
import 'package:pantas/features/quiz/data/repos/practice_preferences_repository.dart';
import 'package:pantas/features/quiz/domain/quiz_session.dart';
import 'package:pantas/features/quiz/domain/use_cases/build_today_plan.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_providers.dart';
import 'package:pantas/features/quiz/presentation/practice_picker_screen.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/questions_unavailable.dart';
import 'package:pantas/features/quiz/presentation/quiz_controller.dart';
import 'package:pantas/features/quiz/presentation/quiz_note_editor.dart';
import 'package:pantas/features/quiz/presentation/quiz_page.dart';
import 'package:pantas/features/quiz/presentation/quiz_question_viewer.dart';
import 'package:pantas/features/quiz/presentation/quiz_tab_screen.dart';
import 'package:pantas/features/quiz/presentation/session_end_screen.dart';
import 'package:pantas/features/quiz/presentation/today_providers.dart';

import '../../../helpers/ds_matrix.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart' show buildExam;
import 'practice_picker_screen_test.dart' show index;
import 'quiz_question_viewer_test.dart' as viewer show items, questions;
import 'session_end_screen_test.dart' show completedAttempt, completedSession;

/// The quiz widths: a phone, the compact sidebar range and the full width.
final _cells = <DsCell>[
  for (final width in [390.0, 1100.0, 1440.0])
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
];

class _ReviewWork implements TodayQuestionWork {
  @override
  List<int> get reviewSizes => [10, 10, 4];
  @override
  List<int> get reviewProgress => [10, 0, 0];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

/// Pumps [child] at [cell] with providers, the web platform from 1024, and no
/// scroll wrapper. Returns once the frame has settled.
Future<void> _pump(
  WidgetTester tester,
  DsCell cell,
  Widget child, {
  List<Override> overrides = const [],
  bool router = false,
}) async {
  tester.view
    ..physicalSize = Size(cell.width, 900)
    ..devicePixelRatio = 1;
  addTearDown(() {
    tester.view.reset();
    debugWebPlatformOverride = null;
  });
  final web = cell.width >= 1024;
  debugWebPlatformOverride = web;
  final theme =
      cell.dark ? buildDarkTheme(web: web) : buildLightTheme(web: web);
  Widget builder(BuildContext context, Widget? home) => MediaQuery(
        data: MediaQueryData(
          size: Size(cell.width, 900),
          textScaler: TextScaler.linear(cell.scale),
          disableAnimations: true,
        ),
        child: home ?? const SizedBox(),
      );
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: router
          ? MaterialApp.router(
              theme: theme,
              builder: builder,
              routerConfig: GoRouter(
                routes: [GoRoute(path: '/', builder: (_, __) => child)],
              ),
            )
          : MaterialApp(
              theme: theme,
              builder: builder,
              home: Scaffold(body: child),
            ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

void _matrix(
  String name,
  Widget Function(DsCell cell) build, {
  List<Override> Function(DsCell cell)? overrides,
  bool router = false,
  Future<void> Function(WidgetTester tester, DsCell cell)? check,
}) {
  for (final cell in _cells) {
    testWidgets('$name ($cell)', (tester) async {
      await tester.runAsync(loadDsFonts);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await _pump(
        tester,
        cell,
        build(cell),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          ...?overrides?.call(cell),
        ],
        router: router,
      );
      expect(tester.takeException(), isNull);
      if (check != null) await check(tester, cell);
    });
  }
}

void main() {
  // Quiz tab.
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
    _matrix(
      'quiz tab ${state.runtimeType}',
      (cell) => const QuizTabScreen(
        mockPanel: MockCard(
          model: MockCardModel(
            state: MockCardState.waiting,
            name: 'CSE simulation',
            durationMinutes: 190,
            lastPercent: 69,
          ),
        ),
      ),
      check: (tester, _) async =>
          expect(find.text('CSE simulation'), findsOneWidget),
      overrides: (_) => [
        activeExamFocusProvider.overrideWith(
          (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
        ),
        sessionPanelProvider('e').overrideWith((_) async => state),
        todayQuestionWorkProvider('e').overrideWith((_) async => _ReviewWork()),
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
  }

  // The question: picking, then revealed.
  for (final revealed in [false, true]) {
    final full = completedSession(batch: true);
    final session = full.copyWith(
      currentIndex: 3,
      outcomes: full.outcomes.take(revealed ? 4 : 3).toList(),
    );
    _matrix(
      'question ${revealed ? 'revealed' : 'picking'}',
      (cell) => const QuizPage(examId: 'e', proIsActive: false),
      check: (tester, _) async {
        expect(find.text('4 of 10'), findsWidgets);
        expect(find.text('Stem 3'), findsWidgets);
      },
      overrides: (_) => [
        flaggedIdsProvider.overrideWith((_) async => <String>{'q1'}),
        quizControllerProvider.overrideWith(
          (ref) => _Controller(ref, session, selected: revealed ? null : 'a'),
        ),
      ],
    );
  }

  // The session end.
  for (final correct in [2, 10]) {
    final session = completedSession(correct: correct, batch: true);
    _matrix(
      'session end $correct of 10',
      check: (tester, _) async => expect(
        find.textContaining(RegExp('Session finished|Perfect')),
        findsOneWidget,
      ),
      (cell) => SessionEndBody(
        session: session,
        attempt: completedAttempt(session),
        subjectNames: const {'t': 'Earth Science'},
        proIsActive: true,
        onDone: () {},
        onQuestion: (_) {},
        onAll: () {},
        onMistakes: () {},
        onNotes: () {},
        onNext: () async {},
      ),
    );
  }

  // Review of a finished session.
  for (final pro in [false, true]) {
    _matrix(
      'question viewer pro=$pro',
      (cell) => QuizQuestionViewer(
        questions: viewer.questions,
        items: viewer.items,
        subjectNames: const {'t': 'General Information'},
        topicNames: const {'t': 'Philippine Constitution'},
        pro: pro,
        onBack: () {},
        onNote: (_, __, ___) async {},
        onReport: (_) async => true,
      ),
    );
  }

  // The note editor.
  _matrix(
    'note editor',
    (cell) => Align(
      alignment: Alignment.bottomCenter,
      child: QuizNoteEditor(onCancel: () {}, onSave: (_, __) async {}),
    ),
  );

  // Questions unavailable.
  _matrix(
    'questions unavailable',
    (cell) => QuestionsUnavailable(notFound: true, onRetry: () {}),
  );

  // The custom practice picker.
  _matrix(
    'practice picker',
    (cell) => const PracticePickerScreen(examId: 'e'),
    router: true,
    overrides: (_) => [
      authStateProvider.overrideWith(
        (_) => Stream.value(const AuthState.anonymous(uid: 'test')),
      ),
      activeExamFocusProvider.overrideWith(
        (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
      ),
      practiceIndexProvider('e').overrideWith((_) async => index),
      practicePaceProvider('e').overrideWith((_) async => null),
      practicePreferencesRepositoryProvider.overrideWith(
        (ref) => PracticePreferencesRepository(ref.watch(appDatabaseProvider)),
      ),
    ],
  );

  // D71: under 400 the flag leaves the bar and sits in the question header.
  for (final (width, inHeader) in [(360.0, true), (420.0, false)]) {
    testWidgets(
        'phone flag is in the ${inHeader ? 'question header' : 'bar'} '
        'at $width', (tester) async {
      await tester.runAsync(loadDsFonts);
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final full = completedSession(batch: true);
      final session = full.copyWith(
        currentIndex: 3,
        outcomes: full.outcomes.take(3).toList(),
      );
      await _pump(
        tester,
        DsCell(width, 1, dark: false),
        const QuizPage(examId: 'e', proIsActive: false),
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          flaggedIdsProvider.overrideWith((_) async => <String>{}),
          quizControllerProvider
              .overrideWith((ref) => _Controller(ref, session)),
        ],
      );
      expect(tester.takeException(), isNull);
      final flag = find.byTooltip('Flag question');
      expect(flag, findsOneWidget);
      final counter = find.byKey(const ValueKey('quiz-counter'));
      final flagCenter = tester.getCenter(flag);
      final counterCenter = tester.getCenter(counter);
      // The question header sits above the options and the bar sits at the
      // bottom of the screen.
      if (inHeader) {
        expect(flagCenter.dy, lessThan(counterCenter.dy - 100));
        // At the right end of the header.
        expect(flagCenter.dx, greaterThan(width - 80));
      } else {
        expect(flagCenter.dy, closeTo(counterCenter.dy, 8));
      }
      // The bar keeps its counter, and every target is 44 high.
      expect(tester.getSize(flag).height, greaterThanOrEqualTo(44));
    });
  }
}
