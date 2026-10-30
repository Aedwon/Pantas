import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';
import 'package:pantas/features/home/presentation/record_page.dart';
import 'package:pantas/features/home/presentation/widgets/home_performance_card.dart';
import 'package:pantas/features/home/presentation/widgets/home_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/home_today_checklist.dart';
import 'package:pantas/features/home/presentation/widgets/plan_skeletons.dart';
import 'package:pantas/features/home/presentation/widgets/progress_skeletons.dart';

const _surface = ValueKey<String>('grouped-section-surface');

void main() {
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    required double width,
    required bool dark,
  }) async {
    final wide = width >= 1024;
    debugWebPlatformOverride = wide;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = Size(width, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 2600)),
          child: Scaffold(
            body: Padding(
              padding: wide
                  ? const EdgeInsets.fromLTRB(288, 28, 44, 44)
                  : const EdgeInsets.all(16),
              child: Align(alignment: Alignment.topCenter, child: child),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
  }

  List<Size> sizes(WidgetTester tester, Finder finder) => [
        for (final e in finder.evaluate().toList()
          ..sort(
            (a, b) => tester
                .getTopLeft(find.byElementPredicate((x) => x == a))
                .dy
                .compareTo(
                  tester.getTopLeft(find.byElementPredicate((x) => x == b)).dy,
                ),
          ))
          tester.getSize(find.byElementPredicate((x) => x == e)),
      ];

  Finder skeletonSections() => find.byWidgetPredicate(
        (w) => w.key == skeletonSectionKey || w.key == _surface,
      );

  /// Section counts match exactly. Heights and widths match within 12 percent
  /// or 14 pixels, whichever is larger.
  void expectMatch(List<Size> skeleton, List<Size> loaded, String label) {
    expect(skeleton.length, loaded.length, reason: '$label section count');
    for (var i = 0; i < loaded.length; i++) {
      final tolerance =
          loaded[i].height * .12 < 14 ? 14.0 : loaded[i].height * .12;
      expect(
        (skeleton[i].height - loaded[i].height).abs(),
        lessThanOrEqualTo(tolerance),
        reason: '$label section $i height ${skeleton[i]} vs ${loaded[i]}',
      );
      expect(
        (skeleton[i].width - loaded[i].width).abs(),
        lessThanOrEqualTo(2),
        reason: '$label section $i width',
      );
    }
  }

  PerformanceRow row(String id) => PerformanceRow(
        id: id,
        title: id,
        subtext: null,
        correct: 1,
        answered: 2,
        secondsPerQuestion: null,
      );

  for (final dark in [false, true]) {
    final mode = dark ? 'dark' : 'light';

    testWidgets('Home phone skeleton matches Today, performance, More $mode',
        (tester) async {
      await mount(
        tester,
        const HomePageSkeleton(),
        width: 390,
        dark: dark,
      );
      final skeleton = sizes(tester, skeletonSections());
      await mount(
        tester,
        Padding(
          // The skeleton page carries the loaded page's 16 pixel list inset.
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              HomeTodayChecklist(
                web: false,
                lessons: const [
                  HomeTodayLesson(
                    id: 'a',
                    title: 'Lesson a',
                    subject: 'Math',
                    minutes: 10,
                    read: false,
                  ),
                  HomeTodayLesson(
                    id: 'b',
                    title: 'Lesson b',
                    subject: 'Math',
                    minutes: 10,
                    read: false,
                  ),
                ],
                reviewsDone: 0,
                reviewsTotal: 5,
                newDone: 0,
                newTotal: 5,
                canAdvance: false,
                isMockDay: false,
                onLesson: (_) {},
                onLessons: () {},
                onReviews: () {},
                onNew: () {},
                onAdvance: () {},
                onMock: () {},
                onPlan: () {},
              ),
              HomePerformanceCard(
                web: false,
                rows: [row('a'), row('b'), row('c')],
                pro: true,
                onOpen: () {},
              ),
              GroupedSection(
                header: 'More about you',
                children: [
                  ListRow(title: 'Your record', divider: true, onTap: () {}),
                  ListRow(title: 'Your tendencies', onTap: () {}),
                ],
              ),
            ],
          ),
        ),
        width: 390,
        dark: dark,
      );
      final loaded = sizes(tester, find.byKey(_surface));
      // The skeleton also draws the week card, which the loaded fixture omits.
      expectMatch(skeleton.sublist(1), loaded, 'home');
    });

    testWidgets('Home 1440 skeleton follows L_PlanSlow $mode', (tester) async {
      await mount(tester, const HomePageSkeleton(), width: 1440, dark: dark);
      final blocks = sizes(tester, find.byKey(skeletonSectionKey));
      expect(
        blocks.map((s) => s.height).toList()..sort(),
        [66, 96, 330, 520],
      );
    });

    testWidgets('Record phone skeleton matches the loaded groups $mode',
        (tester) async {
      await mount(tester, const RecordSkeleton(), width: 390, dark: dark);
      final skeleton = sizes(tester, skeletonSections());
      final record = StudentRecord(
        weeksIn: 6,
        dayStreak: 12,
        streakStartedOn: DateTime(2026, 10, 3),
        questionsAnswered: 1284,
        sessionMinutes: 2130,
        lessonsRead: 46,
        daysActive: 37,
        longestStreak: 15,
        bestMockPercent: 64,
        accuracySeries: [
          (weekStart: DateTime(2026, 9, 2), accuracy: 52),
          (weekStart: DateTime(2026, 10, 8), accuracy: 61),
        ],
        mocks: const [],
      );
      tester.view.physicalSize = const Size(390, 2600);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme() : buildLightTheme(),
          home: RecordPage(
            record: record,
            mocks: const [],
            onBack: () {},
            onMock: (_) {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expectMatch(skeleton, sizes(tester, find.byKey(_surface)), 'record');
    });

    testWidgets('Plan phone skeleton has Today, Coming up, History $mode',
        (tester) async {
      await mount(tester, const PlanSkeleton(), width: 390, dark: dark);
      final skeleton = sizes(tester, skeletonSections());
      tester.view.physicalSize = const Size(390, 2600);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme() : buildLightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: PlanPage(
              pro: true,
              paused: false,
              done: 2,
              total: 4,
              nodes: const [
                PlanNode(
                  kind: PlanNodeKind.week,
                  title: 'Oct 4 – 10',
                  subtitle: 'Topic',
                  date: 'Next week',
                  target: '2026-10-04',
                ),
                PlanNode(
                  kind: PlanNodeKind.week,
                  title: 'Oct 11 – 17',
                  subtitle: 'Topic',
                  date: 'In 2 weeks',
                  target: '2026-10-11',
                ),
                PlanNode(
                  kind: PlanNodeKind.exam,
                  title: 'CSE-P',
                  subtitle: 'Exam day',
                  date: 'Wed, Nov 11',
                ),
              ],
              history: [
                for (var i = 0; i < 5; i++)
                  PlanHistoryEntry(id: 'h$i', date: 'Today', text: 'Change $i'),
              ],
              onBack: () {},
              onToday: () {},
              onWeek: (_) {},
              onPro: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final loaded = sizes(tester, find.byKey(_surface));
      expectMatch(skeleton, loaded, 'plan');
    });
  }

  testWidgets('Record 1440 skeleton has the nine cards of the loaded page',
      (tester) async {
    await mount(tester, const WebRecordLoading(), width: 1440, dark: false);
    expect(find.byKey(skeletonSectionKey), findsNWidgets(9));
  });

  testWidgets('web tendencies skeleton follows L_ProgressSlow', (tester) async {
    await mount(
      tester,
      const WebTendenciesLoading(),
      width: 1440,
      dark: true,
    );
    expect(
      sizes(tester, find.byKey(skeletonSectionKey)).map((s) => s.height),
      [112, 180, 180, 180, 180],
    );
  });

  testWidgets('web plan skeleton uses the 13 to 10 column split',
      (tester) async {
    await mount(tester, const WebPlanLoading(), width: 1440, dark: false);
    final cards = sizes(tester, find.byKey(skeletonSectionKey));
    expect(cards.length, 3);
    final widths = {for (final c in cards) c.width.round()}.toList()..sort();
    expect(widths.length, 2);
    expect(widths.last / widths.first, closeTo(1.3, .03));
  });

  testWidgets('skeleton stops pulsing under reduced motion', (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: RecordSkeleton()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 650));
    final opacity = tester.widget<Opacity>(
      find.byKey(const ValueKey('loading-shapes-opacity')),
    );
    expect(opacity.opacity, 1);
  });
}
