import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/home_boundary.dart';
import 'package:pantas/features/home/application/home_day_extras.dart';
import 'package:pantas/features/home/application/home_today.dart';
import 'package:pantas/features/home/application/plan_provider.dart';
import 'package:pantas/features/home/application/today_questions.dart';
import 'package:pantas/features/home/domain/home_day_note.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/plan_screen.dart';
import 'package:pantas/features/home/presentation/plan_web.dart';
import 'package:pantas/features/home/presentation/widgets/web_record_layout.dart';
import 'package:pantas/features/roadmap/application/roadmap_providers.dart';
import 'package:pantas/features/roadmap/domain/day_snapshot.dart';
import 'package:pantas/features/roadmap/domain/roadmap.dart';

import '../../../helpers/pump_app.dart';

// QA 4N-10, 4N-11 and 4N-14: the pages beside Plan share one left edge, one
// back arrow, and the Plan page's title-to-line spacing.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });

  final date = DateTime(2026, 10, 26);
  final plan = DayPlan(
    day: date,
    lessonIds: const ['l1'],
    reviewQuestionIds: const ['q1'],
    newQuestionIds: const [],
    isMockDay: false,
    advancedIds: const {},
  );
  final roadmapToday = RoadmapToday(
    snapshot: DaySnapshot(
      plan: plan,
      digest: RoadmapDigest(
        examId: 'e',
        examDate: '2026-12-03:day',
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

  Future<void> mountDay(
    WidgetTester tester, {
    required double width,
    required bool wide,
  }) async {
    debugWebPlatformOverride = wide;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBoundaryProvider.overrideWithValue(
            const HomeBoundary(owner: 'test', core: 'test'),
          ),
          activeExamFocusProvider.overrideWith(
            (_) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          todayQuestionLauncherProvider.overrideWith(_Launcher.new),
          homeTodayLoaderProvider.overrideWith(
            (_) => (exam, guard) async => HomeTodayData(
                  today: roadmapToday,
                  lessons: const [
                    HomeTodayLesson(
                      id: 'l1',
                      title: 'Cells',
                      subject: 'Science',
                      minutes: 8,
                      read: false,
                    ),
                  ],
                  questionWork: null,
                  canAdvance: false,
                  examName: 'CSE Pro',
                  examShortName: 'CSE Pro',
                  extras: const HomeDayExtras(note: HomeDayNote.carried),
                ),
          ),
          planDayViewProvider('2026-10-26').overrideWith(
            (_) async => PlanDayView(
              date: date,
              plan: plan,
              remaining: null,
              lessons: const [],
              kind: 'today',
            ),
          ),
        ],
        child: MaterialApp(
          theme: buildDarkTheme(web: wide),
          home: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(wide ? 274 : 0, wide ? 28 : 0, 0, 0),
              child: SizedBox(
                width: wide ? 1080 : width,
                child: const PlanDayScreen(date: '2026-10-26'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the wide Today page starts at the shared left edge (4N-10)',
      (tester) async {
    await mountDay(tester, width: 1440, wide: true);
    expect(find.byType(PlanWebFrame), findsOneWidget);
    expect(find.byType(PantasPage), findsNothing);
    // Title and list start at the page edge, where Plan, Performance and
    // History start, not 16 px in.
    expect(tester.getTopLeft(find.text('Today').first).dx, 274);
    expect(tester.getTopLeft(find.text('Cells')).dx, greaterThan(274));
    expect(tester.getTopLeft(find.byType(PlanWebFrame)).dx, 274);
    // The page is as wide as the shell's page area, not narrower and centered.
    expect(tester.getSize(find.byType(PlanWebFrame)).width, 1080);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the phone Today page keeps the phone frame', (tester) async {
    await mountDay(tester, width: 390, wide: false);
    expect(find.byType(PlanWebFrame), findsNothing);
    expect(find.byType(PantasPage), findsOneWidget);
  });

  testWidgets('the phone day note sits under the title as the Plan subtitle',
      (tester) async {
    await mountDay(tester, width: 390, wide: false);
    final title = tester.getRect(find.text('Today').first);
    final note =
        tester.getRect(find.text('Unfinished items are added to today.'));
    // Board DP_PlanA: the line sits 2 px under the title (plus the line's own
    // leading), not 20 and 6 px of padding apart.
    expect(note.top - title.bottom, lessThan(10));
    expect(note.top - title.bottom, greaterThanOrEqualTo(2));
  });

  testWidgets(
      'Record, Tendencies and Plan put the back link and title at one x and y '
      '(4N-11, 5Q-2)', (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    Future<(Offset, Offset, Offset)> places(Widget page, String title) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(web: true),
          home: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(274, 28, 0, 0),
              child: SizedBox(width: 1080, height: 800, child: page),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return (
        tester.getTopLeft(find.byIcon(Icons.chevron_left)),
        tester.getTopLeft(find.text(title)),
        tester.getTopLeft(find.text('Content')),
      );
    }

    final plan = await places(
      PlanWebFrame(
        title: 'Your plan',
        onBack: () {},
        child: const Text('Content'),
      ),
      'Your plan',
    );
    final record = await places(
      WebMyPage(
        title: 'Your record',
        onBack: () {},
        child: const Text('Content'),
      ),
      'Your record',
    );
    expect(record.$1, plan.$1, reason: 'back link');
    expect(record.$2, plan.$2, reason: 'title');
    expect(record.$3, plan.$3, reason: 'first content');
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
