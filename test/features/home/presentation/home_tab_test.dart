import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/platform/install/install_providers.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/components/skeleton_fade.dart';
import 'package:pantas/core/ui/components/state_view.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';
import 'package:pantas/features/home/application/home_boundary.dart';
import 'package:pantas/features/home/application/home_day_extras.dart';
import 'package:pantas/features/home/application/home_install_offer.dart';
import 'package:pantas/features/home/application/home_notices.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/performance/performance_view.dart';
import 'package:pantas/features/home/application/study_remote_providers.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/domain/study_models.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';
import 'package:pantas/features/home/presentation/widgets/home_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/home_web_layout.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../core/platform/install/fake_install_platform.dart';

const examId = 'exam_1';
const exam = Exam(
  id: examId,
  code: 'UPCAT',
  name: 'UP College Admissions Test',
  shortName: 'UPCAT',
  language: 'en',
  isActive: true,
  subjects: [],
);

final day = DateTime(2026, 10, 24);

RoadmapToday todayFor(DayPlan plan, {RoadmapState? state}) => RoadmapToday(
      snapshot: DaySnapshot(
        plan: plan,
        digest: RoadmapDigest(
          examId: examId,
          examDate: '2026-11-11:day',
          scopeTopicIds: const [],
          contentRevision: 'v1',
          assessmentCompleted: true,
          recordedMockCount: 0,
        ),
        topicOrderHead: const [],
        state: state ?? RoadmapState.planning,
      ),
      remaining: plan,
      originalDone: false,
    );

final planWithWork = DayPlan(
  day: day,
  lessonIds: const ['l1'],
  reviewQuestionIds: const ['q1'],
  newQuestionIds: const [],
  isMockDay: false,
  advancedIds: const {},
);

PerformanceRow subject(String id, int right, int total) => PerformanceRow(
      id: id,
      title: id,
      subtext: null,
      correct: right,
      answered: total,
      secondsPerQuestion: null,
    );

class _Launcher extends TodayQuestionLauncher {
  _Launcher(Ref ref) : super(ref, () => true);
  @override
  Future<Future<bool> Function()> captureGuard(
    String examId, {
    required bool Function() isAlive,
  }) async =>
      () async => isAlive();
}

Widget harness({
  ActiveExamFocus? focus,
  AssessmentResult? result,
  bool throwError = false,
  bool server = false,
  RoadmapToday? today,
  HomeNotice? notice,
  HomeDayNote? note,
  List<PerformanceRow> subjects = const [],
  List<Override> extra = const [],
  ThemeData? theme,
  double textScale = 1,
}) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeTab()),
      GoRoute(
        path: '/assessment/:id',
        builder: (_, __) => const Scaffold(body: Text('assessment')),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      homeBoundaryProvider.overrideWithValue(
        const HomeBoundary(owner: 'test', core: 'test'),
      ),
      studyUsesServerProvider.overrideWithValue(server),
      if (server) currentStudyCoverageProvider.overrideWithValue(false),
      if (server)
        serverStudyRoadmapProvider(examId).overrideWith((_) {
          final plan = <String, Object?>{
            'day': '2026-10-24',
            'lessonIds': ['l1'],
            'reviewQuestionIds': <String>[],
            'newQuestionIds': <String>[],
            'isMockDay': false,
            'isRestDay': false,
            'advancedIds': <String>[],
          };
          return Stream.value(
            StudyRoadmap.decode(
              {
                'examId': examId,
                'serverNow': 1,
                'proCovered': false,
                'revision': 'r',
                'state': 'planning',
                'today': plan,
                'remaining': plan,
                'originalDone': false,
                'canAdvance': false,
                'todayTopicOrder': <String>[],
                'weekDays': [
                  for (var i = 0; i < 7; i++) {'state': 'unknown'},
                ],
              },
              examId: examId,
            ),
          );
        }),
      activeExamFocusProvider.overrideWith((ref) async {
        if (throwError) throw Exception('PlatformException(42)');
        return focus ?? const ActiveExamFocus.selected(exam);
      }),
      homeMastheadProvider.overrideWith(
        (ref) async => const HomeMastheadData(
          name: null,
          examShortName: 'UPCAT',
          examDate: null,
        ),
      ),
      weekStripProvider(examId).overrideWith(
        (ref) async => HomeWeekStripData(
          states: List.filled(7, WeekDayState.plain),
          todayFraction: 0,
        ),
      ),
      assessmentResultProvider(examId).overrideWith((ref) async => result),
      homeNoticeProvider.overrideWith((ref) async => notice),
      homeTodayLoaderProvider.overrideWith(
        (ref) => (id, guard) async => HomeTodayData(
              today: today ?? todayFor(planWithWork),
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
              examName: exam.name,
              examShortName: exam.shortName,
              extras: HomeDayExtras(note: note),
            ),
      ),
      performanceViewProvider.overrideWith(
        (ref) async => PerformanceViewData(
          subjects: subjects,
          topics: const [],
          lessons: const [],
          subjectCounts: const {},
          lessonLevelAvailable: false,
        ),
      ),
      proForActiveExamProvider.overrideWith((ref) async => true),
      todayQuestionLauncherProvider.overrideWith(_Launcher.new),
      ...extra,
    ],
    child: MaterialApp.router(
      theme: theme ?? buildLightTheme(),
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
    ),
  );
}

ThemeData lightTheme() =>
    buildLightTheme(web: debugWebPlatformOverride ?? false);
ThemeData darkTheme() => buildDarkTheme(web: debugWebPlatformOverride ?? false);

AssessmentResult assessed() => AssessmentResult(
      examId: examId,
      completedAt: DateTime(2026, 8, 2),
      topicMasteries: [],
    );

void main() {
  testWidgets('wide Home shows one board error when the plan fails',
      (tester) async {
    debugWebPlatformOverride = true;
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() => debugWebPlatformOverride = null);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      harness(
        server: true,
        extra: [
          weekStripProvider(examId).overrideWith(
            (ref) async => throw StateError('plan unavailable'),
          ),
          homeTodayLoaderProvider.overrideWith(
            (ref) => (id, guard) async => throw StateError('plan unavailable'),
          ),
        ],
      ),
    );
    // The exam loads, Today mounts and fails, and the roadmap arriving retries
    // it once behind a skeleton before the failure stands.
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('Could not load your plan.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
    expect(
      tester.widget<StateView>(find.byType(StateView)).boardLayout,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'web Home uses authoritative Today without a local assessment result',
      (tester) async {
    await tester.pumpWidget(harness(server: true));
    await tester.pumpAndSettle();
    expect(find.text('Ratios'), findsOneWidget);
    expect(find.text('First, a short assessment'), findsNothing);
  });

  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized();
    view.platformDispatcher.views.first.physicalSize = const Size(390, 1600);
    view.platformDispatcher.views.first.devicePixelRatio = 1;
  });
  tearDown(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized();
    view.platformDispatcher.views.first.resetPhysicalSize();
    view.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  testWidgets('with a result: week, greeting, Today and Your performance',
      (tester) async {
    await tester.pumpWidget(
      harness(result: assessed(), subjects: [subject('Mathematics', 8, 10)]),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeMasthead), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Ratios'), findsOneWidget);
    expect(find.text('YOUR PERFORMANCE'), findsOneWidget);
    expect(find.text('See all topics and lessons'), findsOneWidget);
  });

  testWidgets('the install card sits at the bottom of Home, below the lists',
      (tester) async {
    await tester.pumpWidget(
      harness(
        result: assessed(),
        subjects: [subject('Mathematics', 8, 10)],
        extra: [
          installPlatformProvider
              .overrideWithValue(FakeInstallPlatform(isIosSafari: true)),
          homeFirstLessonFinishedProvider.overrideWith((ref) async => true),
        ],
      ),
    );
    await tester.pumpAndSettle();
    final card = find.text('Keep Pantas on your Home Screen');
    await tester.ensureVisible(card);
    expect(card, findsOneWidget);
    expect(find.text('Show Me How'), findsOneWidget);
    expect(
      tester.getTopLeft(card).dy,
      greaterThan(tester.getTopLeft(find.text('Your tendencies')).dy),
    );
  });

  testWidgets('no install card at first open, before a finished lesson',
      (tester) async {
    await tester.pumpWidget(
      harness(
        result: assessed(),
        subjects: [subject('Mathematics', 8, 10)],
        extra: [
          installPlatformProvider
              .overrideWithValue(FakeInstallPlatform(isIosSafari: true)),
          homeFirstLessonFinishedProvider.overrideWith((ref) async => false),
        ],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Show Me How'), findsNothing);
  });

  testWidgets('the old panels and stats band are gone', (tester) async {
    await tester.pumpWidget(harness(result: assessed()));
    await tester.pumpAndSettle();
    expect(find.text('Up next'), findsNothing);
    expect(find.text('Practice'), findsNothing);
    expect(find.text('Tendencies'), findsNothing);
  });

  testWidgets('before the assessment: week, greeting, the card, nothing else',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();
    expect(find.byType(HomeMasthead), findsOneWidget);
    expect(find.text('First, a short assessment'), findsOneWidget);
    expect(find.text('Start Assessment'), findsOneWidget);
    expect(find.text('TODAY'), findsNothing);
    expect(find.text('YOUR PERFORMANCE'), findsNothing);
    expect(find.textContaining('quick quiz'), findsNothing);
    await tester.tap(find.text('Start Assessment'));
    await tester.pumpAndSettle();
    expect(find.text('assessment'), findsOneWidget);
  });

  testWidgets('with no exam: the choose-exam fallback and no masthead',
      (tester) async {
    await tester.pumpWidget(
      harness(focus: const ActiveExamFocus.needsSelection()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Choose your exam'), findsOneWidget);
    expect(find.byType(HomeMasthead), findsNothing);
  });

  testWidgets('an error never shows the exception string', (tester) async {
    await tester.pumpWidget(harness(throwError: true));
    await tester.pumpAndSettle();
    expect(find.textContaining('PlatformException'), findsNothing);
    expect(find.text('Could not load your home.'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('a notice sits between the week and the greeting',
      (tester) async {
    await tester.pumpWidget(
      harness(
        result: assessed(),
        notice: const HomeNotice(
          kind: HomeNoticeKind.noDate,
          title: 'Add your exam date',
          detail: 'Your plan paces each day to it.',
          dismissalToken: 'yes',
          primaryLabel: 'Add Exam Date',
          secondaryLabel: 'Later',
        ),
      ),
    );
    await tester.pumpAndSettle();
    final strip = tester.getTopLeft(find.byType(NoticeStrip)).dy;
    final greeting = tester.getTopLeft(find.textContaining('Magandang')).dy;
    expect(strip, lessThan(greeting));
  });

  testWidgets('Add Exam Date opens the date sheet in place', (tester) async {
    await tester.pumpWidget(
      harness(
        result: assessed(),
        notice: const HomeNotice(
          kind: HomeNoticeKind.noDate,
          title: 'Add your exam date',
          detail: 'Your plan paces each day to it.',
          dismissalToken: 'yes',
          primaryLabel: 'Add Exam Date',
          secondaryLabel: 'Later',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add your exam date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Exam Date'));
    await tester.pumpAndSettle();
    expect(find.text('When is your exam?'), findsOneWidget);
  });

  testWidgets('after a break the greeting reads Welcome back', (tester) async {
    await tester.pumpWidget(
      harness(result: assessed(), note: HomeDayNote.welcomeBack),
    );
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.textContaining('Magandang'), findsNothing);
    expect(
      find.text("Items you missed are in today's reviews."),
      findsOneWidget,
    );
  });

  testWidgets('no lessons yet: the card, no performance, no notice',
      (tester) async {
    await tester.pumpWidget(
      harness(
        result: assessed(),
        subjects: [subject('Mathematics', 8, 10)],
        today: todayFor(
          DayPlan(
            day: day,
            lessonIds: const [],
            reviewQuestionIds: const [],
            newQuestionIds: const [],
            isMockDay: false,
            advancedIds: const {},
          ),
          state: RoadmapState.noContent,
        ),
        notice: const HomeNotice(
          kind: HomeNoticeKind.service,
          title: 'Backup is paused',
          dismissalToken: 'Backup is paused',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lessons are on the way'), findsOneWidget);
    expect(find.text('Switch Exam'), findsOneWidget);
    expect(find.text('YOUR PERFORMANCE'), findsNothing);
    expect(find.byType(NoticeStrip), findsNothing);
  });
  group('splash hand-off (Splash Hand-off canvas, option B, Smoothest)', () {
    HomeTodayData loaded() => HomeTodayData(
          today: todayFor(planWithWork),
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
          examName: exam.name,
          examShortName: exam.shortName,
        );

    /// Nothing between the fade and the plan's own text slides, scales or
    /// otherwise moves it. (Rows may press-scale; those are not ancestors of
    /// the text's position in the fade.)
    void expectNothingMovesRatios() {
      for (final moving in [SlideTransition, SizeTransition]) {
        expect(
          find.descendant(
            of: find.byType(SkeletonFade),
            matching: find.ancestor(
              of: find.text('Ratios'),
              matching: find.byType(moving),
            ),
          ),
          findsNothing,
          reason: '$moving would move the plan',
        );
      }
    }

    Future<(Completer<HomeTodayData>, List<int>)> pumpPending(
      WidgetTester tester, {
      bool signalAlreadySent = false,
    }) async {
      final plan = Completer<HomeTodayData>();
      final signals = <int>[];
      final signal = FirstScreenSignal(() => signals.add(1));
      if (signalAlreadySent) signal.ready();
      signals.clear();
      await tester.pumpWidget(
        harness(
          result: assessed(),
          subjects: [subject('Mathematics', 8, 10)],
          extra: [
            firstScreenSignalProvider.overrideWithValue(signal),
            homeTodayLoaderProvider
                .overrideWith((ref) => (id, guard) => plan.future),
          ],
        ),
      );
      // The exam settles, Home mounts and draws its first frame.
      await tester.pump();
      await tester.pump();
      return (plan, signals);
    }

    testWidgets('the logo is released at the first frame, shapes drawn',
        (tester) async {
      final (plan, signals) = await pumpPending(tester);

      expect(find.byType(HomeTodaySkeleton), findsOneWidget);
      expect(find.text('Ratios'), findsNothing);
      expect(signals, hasLength(1), reason: 'no waiting for the plan');
      // The logo is fading now, so the shapes are drawn without the usual
      // 300 ms wait.
      expect(find.byType(SkeletonBlock), findsWidgets);

      plan.complete(loaded());
      await tester.pumpAndSettle();
      expect(signals, hasLength(1), reason: 'released once');
    });

    testWidgets('a Home opened after the logo is gone keeps the shape wait',
        (tester) async {
      final (plan, signals) =
          await pumpPending(tester, signalAlreadySent: true);

      expect(signals, isEmpty);
      expect(find.byType(HomeTodaySkeleton), findsOneWidget);
      expect(find.byType(SkeletonBlock), findsNothing);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SkeletonBlock), findsWidgets);
      plan.complete(loaded());
      await tester.pumpAndSettle();
    });

    testWidgets('phone: the plan fades in over the shapes with no movement',
        (tester) async {
      final (plan, _) = await pumpPending(tester);
      await tester.pump(const Duration(milliseconds: 400));

      plan.complete(loaded());
      await tester.pump();
      await tester.pump();

      // Part way: both the shapes and the plan are in the tree.
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(HomeTodaySkeleton), findsOneWidget);
      expect(find.text('Ratios'), findsOneWidget);
      expect(find.byType(SkeletonFade), findsOneWidget);
      expectNothingMovesRatios();
      final placed = tester.getTopLeft(find.text('Ratios'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.getTopLeft(find.text('Ratios')), placed);

      // At the end the shapes are gone and the plan stands.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.byType(HomeTodaySkeleton), findsNothing);
      expect(find.text('Ratios'), findsOneWidget);
      expect(find.text('YOUR PERFORMANCE'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Ratios')), placed);
    });

    testWidgets('wide: the board fades in over the board shapes',
        (tester) async {
      debugWebPlatformOverride = true;
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(() => debugWebPlatformOverride = null);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final (plan, signals) = await pumpPending(tester);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(HomeWebLoading), findsWidgets);
      expect(signals, hasLength(1));

      plan.complete(loaded());
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomeWebLoading), findsWidgets);
      expect(find.text('Ratios'), findsOneWidget);
      expectNothingMovesRatios();

      await tester.pumpAndSettle();
      expect(find.byType(HomeWebLoading), findsNothing);
      expect(find.text('Ratios'), findsOneWidget);
    });

    testWidgets('reduced motion swaps the plan in at once', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final (plan, _) = await pumpPending(tester);
      await tester.pump(const Duration(milliseconds: 400));

      plan.complete(loaded());
      await tester.pump();
      await tester.pump();

      expect(find.byType(HomeTodaySkeleton), findsNothing);
      expect(find.text('Ratios'), findsOneWidget);
    });

    testWidgets('a failure after the shapes shows the error as before',
        (tester) async {
      final (plan, signals) = await pumpPending(tester);
      await tester.pump(const Duration(milliseconds: 400));

      plan.completeError(StateError('Planned lesson content unavailable'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Could not load your plan.'), findsOneWidget);
      expect(find.byType(HomeTodaySkeleton), findsNothing);
      expect(signals, hasLength(1));
    });
  });
}
