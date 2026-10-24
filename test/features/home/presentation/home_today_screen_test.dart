import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/today_questions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/lesson_day_context.dart';
import 'package:pantas/features/home/presentation/home_today_screen.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
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
  testWidgets('lesson sheet starts the real lesson with its day context',
      (tester) async {
    LessonDayContext? context;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => HomeTodayScreen(
            examId: 'e1',
            pageBuilder: (today) =>
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
            pageBuilder: (today) => Scaffold(body: today),
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
