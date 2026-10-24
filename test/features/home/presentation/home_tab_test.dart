import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/notice_strip.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/assessment/application/assessment_result_providers.dart';
import 'package:pantas/features/assessment/domain/models/assessment_result.dart';
import 'package:pantas/features/home/application/home_day_extras.dart';
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
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

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
    ],
    child: MaterialApp.router(
      theme: buildLightTheme(),
      routerConfig: router,
    ),
  );
}

AssessmentResult assessed() => AssessmentResult(
      examId: examId,
      completedAt: DateTime(2026, 8, 2),
      topicMasteries: [],
    );

void main() {
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
}
