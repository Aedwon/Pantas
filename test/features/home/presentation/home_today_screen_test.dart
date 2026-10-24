import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/domain/question.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/home_day_extras.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/quiz/domain/models/quiz_preferences.dart';
import 'package:pantas/features/quiz/domain/models/review_batch.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

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
  quietDayTests();
  testWidgets('lesson sheet starts the real lesson with its day context',
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
    expect(find.text('Start Lesson'), findsOneWidget);
    await tester.tap(find.text('Start Lesson'));
    await tester.pumpAndSettle();
    expect(find.text('reader'), findsOneWidget);
    expect(context?.lessonIds, ['l1', 'l2']);
    expect(context?.index, 0);
    expect(context?.date, day);
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
  testWidgets('retry retains original page ownership guard', (tester) async {
    final guards = <Future<Future<bool> Function()>>[];
    var tries = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
              tries++;
              throw StateError('recoverable');
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
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(tries, 2);
    expect(identical(guards.first, guards.last), isTrue);
    expect(find.textContaining('recoverable'), findsNothing);
    expect(find.byType(TodayQuestionRow), findsNothing);
  });
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
}) async {
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
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
        homeTodayLoaderProvider
            .overrideWith((ref) => (examId, guard) async => data),
        todayQuestionLauncherProvider.overrideWith(_Launcher.new),
      ],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: HomeTodayScreen(
          examId: 'e1',
          onSetDate: onSetDate,
          pageBuilder: (today, _) =>
              Scaffold(body: SingleChildScrollView(child: today)),
        ),
      ),
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
      find.text("Your UPCAT date was 11 November. Tell us what's next."),
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
