import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/telemetry/perf_timeline.dart';
import 'package:pantas/core/ui/components/pantas_sheet.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/home_boundary.dart';
import 'package:pantas/features/home/application/home_day_extras.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/data/study_api.dart';
import 'package:pantas/features/home/data/study_read_cache.dart';
import 'package:pantas/features/home/data/study_snapshot_reader.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/widgets/home_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/in_memory_database.dart';

final day = DateTime(2026, 10, 24);
final plan = DayPlan(
  day: day,
  lessonIds: const ['l1', 'l2'],
  reviewQuestionIds: const ['q1'],
  newQuestionIds: const ['q2'],
  isMockDay: false,
  advancedIds: const {},
);
final today = RoadmapToday(
  snapshot: DaySnapshot(
    plan: plan,
    digest: RoadmapDigest(
      examId: 'e1',
      examDate: '',
      scopeTopicIds: const [],
      contentRevision: 'v1',
      assessmentCompleted: true,
      recordedMockCount: 0,
    ),
    topicOrderHead: const [],
  ),
  remaining: plan,
  originalDone: false,
);

void main() {
  for (final error in [false, true]) {
    testWidgets('Home signals only after its plan settles, error=$error',
        (tester) async {
      final pending = Completer<HomeTodayData>();
      var signals = 0;
      final data = HomeTodayData(
        today: today,
        lessons: const [],
        questionWork: null,
        canAdvance: false,
      );
      await pumpData(
        tester,
        data,
        pending: pending.future,
        overrides: [
          homeBoundaryProvider.overrideWithValue(
            const HomeBoundary(owner: 'test', core: 'test'),
          ),
          firstScreenSignalProvider
              .overrideWithValue(FirstScreenSignal(() => signals++)),
        ],
      );
      expect(signals, 0);
      if (error) {
        pending.completeError(StateError('offline'));
      } else {
        pending.complete(data);
      }
      await tester.pumpAndSettle();
      expect(signals, 1);
      await tester.pump();
      expect(signals, 1);
    });
  }
  testWidgets('Home marks its first frame, then its data, then the screen time',
      (tester) async {
    PerfTimeline.reset();
    addTearDown(PerfTimeline.reset);
    final pending = Completer<HomeTodayData>();
    final data = HomeTodayData(
      today: today,
      lessons: const [],
      questionWork: null,
      canAdvance: false,
    );
    await pumpData(tester, data, pending: pending.future);
    await tester.pump();
    expect(
      PerfTimeline.entries().map((e) => e.name),
      ['home.firstframe'],
      reason: 'the skeleton is drawn, the plan is not in yet',
    );

    pending.complete(data);
    await tester.pumpAndSettle();

    expect(
      PerfTimeline.entries().map((e) => e.name),
      ['home.firstframe', 'home.data', 'screen.home'],
    );
  });
  quietDayTests();
  auditTests();
  sheetHandleTests();
  testWidgets('a lesson row starts the real lesson with its day context',
      (tester) async {
    LessonDayContext? context;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => HomeTodayScreen(
            examId: 'e1',
            pageBuilder: (today, _) =>
                Scaffold(body: SingleChildScrollView(child: today)),
          ),
        ),
        GoRoute(
          path: '/lesson/:id',
          builder: (_, state) {
            context = state.extra! as LessonDayContext;
            return const Scaffold(body: Text('reader'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBoundaryProvider.overrideWithValue(
            const HomeBoundary(owner: 'test', core: 'test'),
          ),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(
              Exam(
                id: 'e1',
                code: 'CSE',
                name: 'Civil Service',
                shortName: 'CSE',
                language: 'en',
                isActive: true,
                subjects: [],
              ),
            ),
          ),
          homeTodayLoaderProvider.overrideWith(
            (ref) => (examId, guard) async => HomeTodayData(
                  today: today,
                  lessons: const [
                    HomeTodayLesson(
                      id: 'l1',
                      title: 'Ratios',
                      subject: 'Mathematics',
                      minutes: 8,
                      read: false,
                    ),
                    HomeTodayLesson(
                      id: 'l2',
                      title: 'Fractions',
                      subject: 'Mathematics',
                      minutes: 9,
                      read: false,
                    ),
                  ],
                  questionWork: null,
                  canAdvance: false,
                ),
          ),
          todayQuestionLauncherProvider.overrideWith(_Launcher.new),
        ],
        child: MaterialApp.router(
          theme: buildLightTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ratios'));
    await tester.pumpAndSettle();
    expect(find.text('Start Lesson'), findsNothing);
    expect(find.text('reader'), findsOneWidget);
    expect(context?.lessonIds, ['l1', 'l2']);
    expect(context?.index, 0);
    expect(context?.date, day);
    // New questions and reviews are still on the list, so the reader must not
    // close the day (6U-7).
    expect(context?.moreToDo, isTrue);
  });
  testWidgets('Lessons sheet groups subjects and omits row subtitles',
      (tester) async {
    await pumpData(
      tester,
      HomeTodayData(
        today: today,
        lessons: const [
          HomeTodayLesson(
            id: 'l1',
            title: 'Ratios',
            subject: 'Mathematics',
            minutes: 8,
            read: true,
          ),
          HomeTodayLesson(
            id: 'l2',
            title: 'Cells',
            subject: 'Science',
            minutes: 9,
            read: false,
          ),
          HomeTodayLesson(
            id: 'l3',
            title: 'Fractions',
            subject: 'Mathematics',
            minutes: 7,
            read: false,
          ),
          HomeTodayLesson(
            id: 'l4',
            title: 'Atoms',
            subject: 'Science',
            minutes: 6,
            read: false,
          ),
        ],
        questionWork: null,
        canAdvance: false,
      ),
    );
    await tester.tap(find.text('Lessons').first);
    await tester.pumpAndSettle();
    final sheet = find.byType(TodayQuestionsSheet);
    expect(
      find.descendant(of: sheet, matching: find.text('MATHEMATICS')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('SCIENCE')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Mathematics')),
      findsNothing,
    );
    expect(
      find.descendant(of: sheet, matching: find.text('Read')),
      findsNothing,
    );
    expect(
      tester
          .getTopLeft(
            find.descendant(of: sheet, matching: find.text('Fractions')),
          )
          .dy,
      lessThan(
        tester
            .getTopLeft(
              find.descendant(of: sheet, matching: find.text('SCIENCE')),
            )
            .dy,
      ),
    );
  });
  testWidgets('phone sheet titles use the row up to the time (3K-4)',
      (tester) async {
    const title = 'Order of Operations with Grouping Symbols and Exponents';
    await pumpData(
      tester,
      HomeTodayData(
        today: today,
        lessons: const [
          HomeTodayLesson(
            id: 'l1',
            title: title,
            subject: 'Mathematics',
            minutes: 10,
            read: false,
          ),
          HomeTodayLesson(
            id: 'l2',
            title: 'Cells',
            subject: 'Science',
            minutes: 9,
            read: false,
          ),
          HomeTodayLesson(
            id: 'l3',
            title: 'Fractions',
            subject: 'Mathematics',
            minutes: 7,
            read: false,
          ),
          HomeTodayLesson(
            id: 'l4',
            title: 'Atoms',
            subject: 'Science',
            minutes: 6,
            read: false,
          ),
        ],
        questionWork: null,
        canAdvance: false,
      ),
    );
    await tester.tap(find.text('Lessons').first);
    await tester.pumpAndSettle();
    final sheet = find.byType(TodayQuestionsSheet);
    final row = find.descendant(of: sheet, matching: find.text(title));
    final time = find.descendant(of: sheet, matching: find.text('10 min'));
    // The time keeps its own width, so the title runs to 10 px before it
    // instead of stopping at half of the row.
    expect(
      tester.getTopLeft(time).dx - tester.getTopRight(row).dx,
      lessThan(16),
    );
    // A title too long for the line is read in full, not cut with dots (the
    // Nov 3 rule, 3K-4 again).
    final text = tester.widget<Text>(row);
    expect(text.maxLines, isNull);
    expect(text.overflow, isNot(TextOverflow.ellipsis));
    expect(tester.getSize(row).height, greaterThan(24));
  });
  testWidgets(
      'wide drawer rows wrap a long title instead of ending in dots '
      '(3K-14)', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    const title =
        'Article XI: Accountability of Public Officers and the Ombudsman '
        'under the 1987 Philippine Constitution';
    await pumpData(
      tester,
      HomeTodayData(
        today: today,
        lessons: [
          const HomeTodayLesson(
            id: 'l1',
            title: title,
            subject: 'Constitution',
            minutes: 10,
            read: false,
          ),
          for (var i = 2; i <= 5; i++)
            HomeTodayLesson(
              id: 'l$i',
              title: 'Lesson $i',
              subject: 'Science',
              minutes: 9,
              read: false,
            ),
        ],
        questionWork: null,
        canAdvance: false,
      ),
    );
    await tester.tap(find.text('Lessons').first);
    await tester.pumpAndSettle();
    final drawer = find.byKey(const ValueKey('home-web-drawer'));
    final row = find.descendant(of: drawer, matching: find.text(title));
    expect(row, findsOneWidget);
    // Two lines or more: a long title is read in full.
    expect(tester.getSize(row).height, greaterThan(26));
    expect(tester.widget<Text>(row).overflow, isNot(TextOverflow.ellipsis));
  });
  testWidgets(
      'a first read that fails as the context settles retries by itself '
      'with a recaptured owner', (tester) async {
    var token = 'a';
    final guards = <Future<Future<bool> Function()>>[];
    var staleWrites = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBoundaryProvider.overrideWithValue(
            const HomeBoundary(owner: 'test', core: 'test'),
          ),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(
              Exam(
                id: 'e1',
                code: 'CSE',
                name: 'Civil Service',
                shortName: 'CSE',
                language: 'en',
                isActive: true,
                subjects: [],
              ),
            ),
          ),
          homeTodayLoaderProvider.overrideWith(
            (ref) => (examId, guard) async {
              guards.add(guard);
              final check = await guard;
              // The context changes while the first load is running.
              if (guards.length == 1) token = 'b';
              if (!await check()) throw StateError('Home owner changed');
              staleWrites++;
              return HomeTodayData(
                today: today,
                lessons: const [
                  HomeTodayLesson(
                    id: 'l1',
                    title: 'Ratios',
                    subject: 'Mathematics',
                    minutes: 8,
                    read: false,
                  ),
                ],
                questionWork: null,
                canAdvance: false,
              );
            },
          ),
          todayQuestionLauncherProvider.overrideWith(
            (ref) => _TokenLauncher(ref, () => token),
          ),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: HomeTodayScreen(
            examId: 'e1',
            pageBuilder: (today, _) => Scaffold(body: today),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Could not load your plan.'), findsNothing);
    expect(find.byType(HomeTodaySkeleton), findsOneWidget);
    expect(staleWrites, 0);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(guards, hasLength(2));
    expect(identical(guards.first, guards.last), isFalse);
    expect(find.text('Try Again'), findsNothing);
    expect(find.text('Ratios'), findsOneWidget);
    expect(staleWrites, 1);
  });
  settlingTests();
}

class _TokenLauncher extends TodayQuestionLauncher {
  _TokenLauncher(Ref ref, this.readToken) : super(ref, () => true);
  final String Function() readToken;
  @override
  Future<Future<bool> Function()> captureGuard(
    String examId, {
    required bool Function() isAlive,
  }) async {
    final captured = readToken();
    return () async => isAlive() && readToken() == captured;
  }
}

class _Launcher extends TodayQuestionLauncher {
  _Launcher(Ref ref) : super(ref, () => true);
  @override
  Future<Future<bool> Function()> captureGuard(
    String examId, {
    required bool Function() isAlive,
  }) async =>
      () async => isAlive();
}

RoadmapToday todayFor({
  RoadmapState state = RoadmapState.planning,
  DayPlan? dayPlan,
  String examDate = '2026-11-11:day',
  bool originalDone = false,
}) {
  final p = dayPlan ?? plan;
  return RoadmapToday(
    snapshot: DaySnapshot(
      plan: p,
      digest: RoadmapDigest(
        examId: 'e1',
        examDate: examDate,
        scopeTopicIds: const [],
        contentRevision: 'v1',
        assessmentCompleted: true,
        recordedMockCount: 0,
      ),
      topicOrderHead: const [],
      state: state,
    ),
    remaining: p,
    originalDone: originalDone,
  );
}

Future<void> pumpData(
  WidgetTester tester,
  HomeTodayData data, {
  VoidCallback? onSetDate,
  Future<HomeTodayData>? pending,
  List<Override> overrides = const [],
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => HomeTodayScreen(
          examId: 'e1',
          onSetDate: onSetDate,
          pageBuilder: (today, _) =>
              Scaffold(body: SingleChildScrollView(child: today)),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        homeBoundaryProvider.overrideWithValue(
          const HomeBoundary(owner: 'test', core: 'test'),
        ),
        activeExamFocusProvider.overrideWith(
          (ref) async => const ActiveExamFocus.selected(
            Exam(
              id: 'e1',
              code: 'UPCAT',
              name: 'UP College Admissions Test',
              shortName: 'UPCAT',
              language: 'en',
              isActive: true,
              subjects: [],
            ),
          ),
        ),
        homeTodayLoaderProvider.overrideWith(
          (ref) =>
              (examId, guard) async => pending == null ? data : await pending,
        ),
        todayQuestionLauncherProvider.overrideWith(_Launcher.new),
        ...overrides,
      ],
      child: MaterialApp.router(theme: buildLightTheme(), routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

DayPlan emptyPlan({bool rest = false, DateTime? at}) => DayPlan(
      day: at ?? day,
      lessonIds: const [],
      reviewQuestionIds: const [],
      newQuestionIds: const [],
      isMockDay: false,
      isRestDay: rest,
      advancedIds: const {},
    );

HomeTodayData dataFor(
  RoadmapToday today, {
  bool canAdvance = false,
  HomeDayExtras extras = const HomeDayExtras(),
}) =>
    HomeTodayData(
      today: today,
      lessons: const [],
      questionWork: null,
      canAdvance: canAdvance,
      examName: 'UP College Admissions Test',
      examShortName: 'UPCAT',
      extras: extras,
    );

HomeTodayData sheetWorkData() {
  final questions = [
    for (var i = 0; i < 11; i++)
      Question(
        id: 'r$i',
        version: 1,
        examIds: const ['e1'],
        topicId: 't',
        language: 'en',
        stem: 'Review $i',
        choices: const [],
        explanation: '',
      ),
  ];
  final batch = PreparedReviewBatch.fromReviews(
    scope: const ReviewBatchScope(
      userId: 'u',
      examId: 'e1',
      principal: 'u',
      accountLifetimeToken: 'original',
    ),
    preferences: QuizPreferences.defaults,
    localDay: day,
    orderedDueReviews: questions,
  );
  return HomeTodayData(
    today: today,
    lessons: const [],
    questionWork: TodayQuestionWork(
      examId: 'e1',
      today: today,
      preparedReviews: batch,
      storedReviews: null,
      newQuestions: questions.take(2).toList(),
      reviewProgress: const [0, 0],
      newRows: const [
        (title: 'Ratios', done: 0, total: 1),
        (title: 'Cells', done: 0, total: 1),
      ],
      guard: () async => true,
    ),
    canAdvance: false,
  );
}

/// One drag handle per sheet (Sheet README: grabber 36x5). The sheet draws
/// it, so the contents the Home sheets put inside must not draw a second.
void sheetHandleTests() {
  for (final row in ['Reviews', 'New questions']) {
    testWidgets('the $row sheet on Home shows exactly one drag handle',
        (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpData(tester, sheetWorkData());
      await tester.tap(find.text(row).first);
      await tester.pumpAndSettle();
      expect(find.byType(TodayQuestionsSheet), findsOneWidget);
      expect(find.byType(PantasSheetGrabber), findsOneWidget);
    });
  }
}

void quietDayTests() {
  testWidgets('exam-day warm-up keeps the View full plan action',
      (tester) async {
    final examToday = todayFor(
      dayPlan: DayPlan(
        day: DateTime(2026, 11, 11),
        lessonIds: const [],
        reviewQuestionIds: const ['warmup'],
        newQuestionIds: const [],
        isMockDay: false,
        advancedIds: const {},
      ),
    );
    final batch = PreparedReviewBatch.fromReviews(
      scope: const ReviewBatchScope(
        userId: 'u',
        examId: 'e1',
        principal: 'u',
        accountLifetimeToken: 'original',
      ),
      preferences: QuizPreferences.defaults,
      localDay: DateTime(2026, 11, 11),
      orderedDueReviews: const [
        Question(
          id: 'warmup',
          version: 1,
          examIds: ['e1'],
          topicId: 't',
          language: 'en',
          stem: 'Measured review',
          choices: [],
          explanation: '',
        ),
      ],
    );
    await pumpData(
      tester,
      HomeTodayData(
        today: examToday,
        lessons: const [],
        questionWork: TodayQuestionWork(
          examId: 'e1',
          today: examToday,
          preparedReviews: batch,
          storedReviews: null,
          newQuestions: const [],
          reviewProgress: const [0],
          newRows: const [],
          guard: () async => true,
        ),
        canAdvance: false,
        examShortName: 'UPCAT',
      ),
    );
    expect(find.text('Warm-up reviews'), findsOneWidget);
    expect(find.text('View full plan'), findsOneWidget);
  });
  testWidgets('a day off offers advance only when the engine permits it',
      (tester) async {
    await pumpData(
      tester,
      dataFor(
        todayFor(dayPlan: emptyPlan(rest: true)),
        canAdvance: true,
      ),
    );
    expect(find.text('Day off'), findsOneWidget);
    expect(find.text('I Want to Advance'), findsOneWidget);
    await pumpData(
      tester,
      dataFor(todayFor(dayPlan: emptyPlan(rest: true))),
    );
    expect(find.text('Day off'), findsOneWidget);
    expect(find.text('I Want to Advance'), findsNothing);
  });
  testWidgets('everything covered reads Nothing due with optional practice',
      (tester) async {
    await pumpData(
      tester,
      dataFor(
        todayFor(state: RoadmapState.allCovered, dayPlan: emptyPlan()),
      ),
    );
    expect(find.text('Nothing due today'), findsOneWidget);
    expect(
      find.text("You've covered everything in your plan."),
      findsOneWidget,
    );
    expect(find.text('Practice Weakest Topics'), findsOneWidget);
  });
  testWidgets('exam day with no eligible reviews claims no warm-up',
      (tester) async {
    await pumpData(
      tester,
      dataFor(
        todayFor(
          dayPlan: emptyPlan(at: DateTime(2026, 11, 11)),
        ),
      ),
    );
    expect(find.text('UPCAT is today.'), findsOneWidget);
    expect(find.text('Start Warm-up'), findsNothing);
    expect(find.textContaining('easy review'), findsNothing);
  });
  testWidgets('exam passed asks for a new date through Home', (tester) async {
    var asked = 0;
    await pumpData(
      tester,
      dataFor(
        todayFor(
          state: RoadmapState.examPassedAwaitingAnswer,
          dayPlan: emptyPlan(at: DateTime(2026, 11, 20)),
        ),
      ),
      onSetDate: () => asked++,
    );
    expect(find.text('Did you take UPCAT?'), findsOneWidget);
    expect(
      find.text("Your UPCAT date was November 11. Tell us what's next."),
      findsOneWidget,
    );
    await tester.tap(find.text('Set a New Date'));
    expect(asked, 1);
  });
  testWidgets('the calm line sits above Today and View full plan is available',
      (tester) async {
    await pumpData(
      tester,
      dataFor(
        todayFor(),
        extras: const HomeDayExtras(note: HomeDayNote.carried),
      ),
    );
    expect(find.text('Unfinished items are added to today.'), findsOneWidget);
    expect(find.text('View full plan'), findsOneWidget);
  });
  testWidgets('the calm line is dropped on a day off and on a finished day',
      (tester) async {
    const carried = HomeDayExtras(note: HomeDayNote.carried);
    await pumpData(
      tester,
      dataFor(todayFor(dayPlan: emptyPlan(rest: true)), extras: carried),
    );
    expect(find.text('Day off'), findsOneWidget);
    expect(find.text('Unfinished items are added to today.'), findsNothing);
    await pumpData(
      tester,
      dataFor(todayFor(originalDone: true), extras: carried),
    );
    expect(find.text('Unfinished items are added to today.'), findsNothing);
  });
  testWidgets('a moved mock names the exam simulation', (tester) async {
    await pumpData(
      tester,
      dataFor(
        todayFor(),
        extras: const HomeDayExtras(note: HomeDayNote.mockMoved),
      ),
    );
    expect(
      find.text('Your UPCAT simulation moved to today.'),
      findsOneWidget,
    );
  });
}

StudyRoadmap auditRoadmap() => StudyRoadmap.decode(
      {
        'examId': 'e1',
        'serverNow': 100,
        'proCovered': false,
        'revision': 'r',
        'state': 'planning',
        'today': {
          'day': '2026-10-24',
          'lessonIds': <String>[],
          'reviewQuestionIds': <String>[],
          'newQuestionIds': <String>[],
          'advancedIds': <String>[],
          'isMockDay': false,
          'isRestDay': false,
        },
        'remaining': {
          'day': '2026-10-24',
          'lessonIds': <String>[],
          'reviewQuestionIds': <String>[],
          'newQuestionIds': <String>[],
          'advancedIds': <String>[],
          'isMockDay': false,
          'isRestDay': false,
        },
        'weekDays': <Object?>[],
        'originalDone': true,
        'canAdvance': true,
        'todayTopicOrder': <String>[],
      },
      examId: 'e1',
    );

class _AuditPreparer extends TodayQuizPreparer {
  _AuditPreparer()
      : super(
          readStamp: (_) => throw UnimplementedError(),
          buildPlan: (_) => throw UnimplementedError(),
          now: DateTime.now,
        );
  final calls = <QuizPreparationRequest>[];
  @override
  Future<PreparedTodaySession> prepare(QuizPreparationRequest request) async {
    calls.add(request);
    throw StateError('Stop after captured request');
  }
}

void auditTests() {
  for (final code in [
    'failed-precondition',
    'permission-denied',
    'unavailable',
  ]) {
    testWidgets('advance $code retains only a retryable request',
        (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      final sent = <String>[];
      final request = StudyRequest(
        uid: 'u',
        examId: 'e1',
        isCurrent: () async => true,
        api: StudyApi((_, p) async {
          sent.add(p['requestId']! as String);
          throw FirebaseFunctionsException(code: code, message: 'Rejected');
        }),
      );
      await pumpData(
        tester,
        HomeTodayData(
          today: todayFor(dayPlan: emptyPlan(rest: true), originalDone: true),
          lessons: const [],
          questionWork: null,
          canAdvance: true,
        ),
        overrides: [
          homeBoundaryProvider.overrideWithValue(
            const HomeBoundary(owner: 'test', core: 'test'),
          ),
          studyUsesServerProvider.overrideWithValue(true),
          serverStudyRoadmapProvider('e1')
              .overrideWith((_) => Stream.value(auditRoadmap())),
          studySnapshotReaderProvider('e1').overrideWith(
            (_) async => StudySnapshotReader(
              request: request,
              cache: StudyReadCache(
                db,
                uid: 'u',
                examId: 'e1',
                coreToken: 'c',
                isCurrent: () async => true,
              ),
            ),
          ),
        ],
      );
      await tester.tap(find.text('I Want to Advance'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();
      expect(sent, hasLength(2));
      expect(sent.first == sent.last, code == 'unavailable');
    });
  }
  testWidgets('web Free weakest practice starts general exam practice',
      (tester) async {
    final preparer = _AuditPreparer();
    await pumpData(
      tester,
      HomeTodayData(
        today: todayFor(dayPlan: emptyPlan()),
        lessons: const [],
        questionWork: null,
        canAdvance: false,
      ),
      overrides: [
        homeBoundaryProvider.overrideWithValue(
          const HomeBoundary(owner: 'test', core: 'test'),
        ),
        studyUsesServerProvider.overrideWithValue(true),
        todayQuizPreparerProvider.overrideWithValue(preparer),
        serverStudyRoadmapProvider('e1')
            .overrideWith((_) => Stream.value(auditRoadmap())),
        serverStudyInsightsProvider('e1').overrideWith(
          (_) => Stream.value(
            StudyInsights.decode(
              {
                'examId': 'e1',
                'serverNow': 100,
                'proCovered': false,
                'revision': 'r',
                'performance': {
                  'overall': {'correct': 0, 'answered': 0},
                  'subjects': <Object?>[],
                },
              },
              examId: 'e1',
            ),
          ),
        ),
      ],
    );
    await tester.tap(find.text('Practice Weakest Topics'));
    await tester.pumpAndSettle();
    expect(preparer.calls, hasLength(1));
    expect(preparer.calls.single.topicId, isNull);
  });
}

/// Home must never show an error while the app is only settling. These pin the
/// "Could not load your plan." flash after the Name step and under the splash.
void settlingTests() {
  const message = 'Could not load your plan.';
  HomeTodayData loaded() => HomeTodayData(
        today: today,
        lessons: const [
          HomeTodayLesson(
            id: 'l1',
            title: 'Ratios',
            subject: 'Mathematics',
            minutes: 8,
            read: false,
          ),
        ],
        questionWork: null,
        canAdvance: false,
      );

  Future<int> pumpFailing(
    WidgetTester tester, {
    required Object? Function(int attempt)? failure,
    List<Override> overrides = const [],
  }) async {
    var attempts = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBoundaryProvider.overrideWithValue(
            const HomeBoundary(owner: 'test', core: 'test'),
          ),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(
              Exam(
                id: 'e1',
                code: 'CSE',
                name: 'Civil Service',
                shortName: 'CSE',
                language: 'en',
                isActive: true,
                subjects: [],
              ),
            ),
          ),
          homeTodayLoaderProvider.overrideWith(
            (ref) => (examId, guard) async {
              attempts++;
              final error = failure?.call(attempts);
              if (error is Exception) throw error;
              if (error is Error) throw error;
              return loaded();
            },
          ),
          todayQuestionLauncherProvider.overrideWith(_Launcher.new),
          ...overrides,
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: HomeTodayScreen(
            examId: 'e1',
            pageBuilder: (today, _) => Scaffold(body: today),
          ),
        ),
      ),
    );
    return attempts;
  }

  for (final error in <Object>[
    StateError('Quiz owner changed'),
    StateError('Home owner changed'),
    StateError('Quiz account is unavailable'),
    StateError(
      'The provider AutoDisposeFutureProvider<RoadmapToday>#1(e1) was '
      'disposed during loading state, yet no value could be emitted.',
    ),
    FirebaseFunctionsException(
      code: 'failed-precondition',
      message: 'Set your exam first.',
    ),
  ]) {
    testWidgets('a settling failure never shows the error: $error',
        (tester) async {
      var signals = 0;
      await pumpFailing(
        tester,
        failure: (attempt) => attempt <= 2 ? error : null,
        overrides: [
          homeBoundaryProvider.overrideWithValue(
            const HomeBoundary(owner: 'test', core: 'test'),
          ),
          firstScreenSignalProvider
              .overrideWithValue(FirstScreenSignal(() => signals++)),
        ],
      );
      // Every frame from the first failure to the retry that succeeds.
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.text(message), findsNothing, reason: 'frame $i');
        if (find.text('Ratios').evaluate().isNotEmpty) break;
        expect(find.byType(HomeTodaySkeleton), findsOneWidget);
        expect(signals, 0, reason: 'the splash holds while Home settles');
      }
      expect(find.text('Ratios'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(signals, 1);
    });
  }

  testWidgets('a real failure shows the error at once and retries nothing',
      (tester) async {
    var signals = 0;
    final attempts = await pumpFailing(
      tester,
      failure: (_) => StateError('Planned lesson content unavailable'),
      overrides: [
        homeBoundaryProvider.overrideWithValue(
          const HomeBoundary(owner: 'test', core: 'test'),
        ),
        firstScreenSignalProvider
            .overrideWithValue(FirstScreenSignal(() => signals++)),
      ],
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text(message), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(attempts, 1);
    expect(signals, 1);
  });

  testWidgets(
      'a settling failure that never clears shows the error after '
      'its retries, and Try Again starts a fresh count', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBoundaryProvider.overrideWithValue(
            const HomeBoundary(owner: 'test', core: 'test'),
          ),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(
              Exam(
                id: 'e1',
                code: 'CSE',
                name: 'Civil Service',
                shortName: 'CSE',
                language: 'en',
                isActive: true,
                subjects: [],
              ),
            ),
          ),
          homeTodayLoaderProvider.overrideWith(
            (ref) => (examId, guard) async {
              calls++;
              throw StateError('Study owner changed');
            },
          ),
          todayQuestionLauncherProvider.overrideWith(_Launcher.new),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: HomeTodayScreen(
            examId: 'e1',
            pageBuilder: (today, _) => Scaffold(body: today),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    expect(find.text(message), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text(message), findsOneWidget);
    expect(calls, 7);
    await tester.tap(find.text('Try Again'));
    await tester.pump();
    expect(find.text(message), findsNothing);
    expect(calls, 8);
    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(find.text(message), findsOneWidget);
    expect(calls, 14);
  });
  // Nov 10: the plan reader is kept alive, so a read that failed while the
  // owner settled held "Study owner changed" and every retry, and Try Again,
  // got the same cached error back ("Could not load your plan." in the
  // journeys and on prod). A settling retry must read the plan afresh.
  testWidgets(
      'a settling retry and Try Again rebuild the cached plan readers '
      'instead of reusing their error', (tester) async {
    var readerBuilds = 0;
    var roadmapBuilds = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBoundaryProvider.overrideWithValue(
            const HomeBoundary(owner: 'test', core: 'test'),
          ),
          activeExamFocusProvider.overrideWith(
            (ref) async => const ActiveExamFocus.selected(
              Exam(
                id: 'e1',
                code: 'CSE',
                name: 'Civil Service',
                shortName: 'CSE',
                language: 'en',
                isActive: true,
                subjects: [],
              ),
            ),
          ),
          studySnapshotReaderProvider.overrideWith((ref, examId) async {
            readerBuilds++;
            throw StateError('Study owner changed');
          }),
          serverStudyRoadmapProvider.overrideWith((ref, examId) async* {
            ref.keepAlive();
            roadmapBuilds++;
            await ref.watch(studySnapshotReaderProvider(examId).future);
          }),
          homeTodayLoaderProvider.overrideWith(
            (ref) => (examId, guard) async {
              await ref.read(serverStudyRoadmapProvider(examId).future);
              throw StateError('unreachable');
            },
          ),
          todayQuestionLauncherProvider.overrideWith(_Launcher.new),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: HomeTodayScreen(
            examId: 'e1',
            pageBuilder: (today, _) => Scaffold(body: today),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(readerBuilds, 1);
    expect(roadmapBuilds, 1);
    // The first settling retry runs after 150 ms.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(readerBuilds, 2);
    expect(roadmapBuilds, 2);
    await tester.pump(const Duration(seconds: 9));
    await tester.pump();
    expect(find.text(message), findsOneWidget);
    final before = readerBuilds;
    await tester.tap(find.text('Try Again'));
    await tester.pump();
    expect(readerBuilds, before + 1);
  });
}
