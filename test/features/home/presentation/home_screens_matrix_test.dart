import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/domain/exam_date.dart';
import 'package:pantas/core/ui/components/week_strip.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/application/performance/topic_detail.dart';
import 'package:pantas/features/home/application/record_provider.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/home_providers.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';
import 'package:pantas/features/home/presentation/plan_day_page.dart';
import 'package:pantas/features/home/presentation/plan_page.dart';
import 'package:pantas/features/home/presentation/record_page.dart';
import 'package:pantas/features/home/presentation/tendencies_page.dart';
import 'package:pantas/features/home/presentation/topic_detail_page.dart';
import 'package:pantas/features/home/presentation/widgets/home_masthead.dart';
import 'package:pantas/features/metrics/archetypes/archetype_catalog.dart';
import 'package:pantas/features/metrics/archetypes/archetype_templates.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';

import '../../../helpers/ds_matrix.dart';
import 'home_tab_test.dart' as home_tab;

/// Every Home screen at the three widths that matter (phone, the compact
/// sidebar range and the wide layout), light and dark, text 1.0 and 2.0. A
/// layout overflow raised while pumping fails the cell.
final _cells = <DsCell>[
  for (final width in [390.0, 1100.0, 1440.0])
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) DsCell(width, scale, dark: dark),
];

PerformanceRow _row(String id, int right, int total) => PerformanceRow(
      id: id,
      title: id,
      subtext: 'Subject',
      correct: right,
      answered: total,
      secondsPerQuestion: null,
    );

const _lesson = HomeTodayLesson(
  id: 'l',
  title: 'DNA and genes',
  subject: 'Biology',
  minutes: 8,
  read: true,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadDsFonts);

  group('Home (/home)', () {
    for (final cell in _cells) {
      testWidgets('masthead $cell', (tester) async {
        tester.view
          ..physicalSize = Size(cell.width, 1400)
          ..devicePixelRatio = 1;
        debugWebPlatformOverride = cell.width >= 1024;
        addTearDown(() {
          tester.view.reset();
          debugWebPlatformOverride = null;
        });
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              homeMastheadProvider.overrideWith(
                (ref) async => HomeMastheadData(
                  name: 'Aedwon',
                  examShortName: 'UPCAT',
                  examDate: ExamDate.onDay(DateTime(2026, 11, 20)),
                ),
              ),
              weekStripProvider('exam_1').overrideWith(
                (ref) async => HomeWeekStripData(
                  states: const [
                    WeekDayState.done,
                    WeekDayState.partial,
                    WeekDayState.missed,
                    WeekDayState.today,
                    WeekDayState.plain,
                    WeekDayState.plain,
                    WeekDayState.dayOff,
                  ],
                  todayFraction: .5,
                ),
              ),
            ],
            child: MaterialApp(
              theme: cell.dark ? home_tab.darkTheme() : home_tab.lightTheme(),
              home: MediaQuery(
                data: MediaQueryData(
                  size: Size(cell.width, 1400),
                  textScaler: TextScaler.linear(cell.scale),
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: HomeMasthead(
                      examId: 'exam_1',
                      now: DateTime(2026, 11, 4, 9),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 800));
        expect(tester.takeException(), isNull);
      });

      testWidgets('tab $cell', (tester) async {
        tester.view
          ..physicalSize = Size(cell.width, 1400)
          ..devicePixelRatio = 1;
        debugWebPlatformOverride = cell.width >= 1024;
        addTearDown(() {
          tester.view.reset();
          debugWebPlatformOverride = null;
        });
        await tester.pumpWidget(
          home_tab.harness(
            theme: cell.dark ? home_tab.darkTheme() : home_tab.lightTheme(),
            textScale: cell.scale,
            subjects: [_row('Math', 8, 10), _row('Science', 3, 9)],
          ),
        );
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Plan (/plan, /plan/history, /plan/day, /plan/week)', () {
    dsMatrix(
      'plan',
      (_) => PlanPage(
        pro: true,
        paused: false,
        done: 2,
        total: 4,
        subtitle: '42 days until CSE-P',
        nodes: const [
          PlanNode(
            kind: PlanNodeKind.week,
            title: 'Oct 4 – 10',
            subtitle: 'Actual topic',
            date: 'Next week',
            target: '2026-10-04',
          ),
          PlanNode(
            kind: PlanNodeKind.exam,
            title: 'CSE-P',
            subtitle: 'Exam day',
            date: 'Wed, Nov 11',
          ),
        ],
        history: const [
          PlanHistoryEntry(id: 'h1', date: 'Today', text: 'Actual change'),
        ],
        onBack: () {},
        onToday: () {},
        onWeek: (_) {},
        onPro: () {},
      ),
      scroll: false,
      cells: _cells,
    );

    dsMatrix(
      'plan history',
      (_) => PlanHistoryPage(
        history: [
          for (var i = 0; i < 8; i++)
            PlanHistoryEntry(id: 'h$i', date: 'Today', text: 'Change $i'),
        ],
        onBack: () {},
      ),
      scroll: false,
      cells: _cells,
    );

    dsMatrix(
      'plan day',
      (_) => PlanDayPage(
        date: DateTime(2026, 10, 6),
        past: false,
        rest: false,
        lessons: const [_lesson],
        reviewsDone: 2,
        reviewsTotal: 3,
        newDone: 1,
        newTotal: 4,
        onBack: () {},
        onLesson: (_) {},
      ),
      scroll: false,
      cells: _cells,
    );

    dsMatrix(
      'plan week',
      (_) => PlanWeekPage(
        title: 'Oct 4 – 10',
        days: [
          PlanWeekDay(
            date: DateTime(2026, 10, 4),
            rest: true,
            lessonTitles: const [],
          ),
          PlanWeekDay(
            date: DateTime(2026, 10, 5),
            rest: false,
            lessonTitles: const ['DNA and genes'],
          ),
        ],
        studyDaysLabel: 'You study Monday to Saturday.',
        onBack: () {},
        onDay: (_) {},
        onChange: () {},
      ),
      scroll: false,
      cells: _cells,
    );
  });

  group('Performance (/performance, /performance/topic)', () {
    final data = PerformanceViewData(
      subjects: [_row('Math', 8, 10), _row('Science', 3, 9)],
      topics: [_row('Algebra', 1, 2), _row('Geometry', 1, 4)],
      lessons: [],
      subjectCounts: {'Math': 2},
      lessonLevelAvailable: true,
      parentSubjectIds: {'Algebra': 'Math', 'Geometry': 'Math'},
    );
    for (final pro in [true, false]) {
      dsMatrix(
        'performance pro=$pro',
        (_) => PerformancePage(
          data: data,
          pro: pro,
          paused: false,
          onTopic: (_) {},
          onPro: () {},
          onBack: () {},
        ),
        scroll: false,
        cells: _cells,
      );
    }

    dsMatrix(
      'topic',
      (_) => TopicDetailPage(
        detail: TopicDetail(
          topicId: 'geo',
          name: 'Geometry',
          subject: 'Mathematics',
          correct: 4,
          answered: 9,
          lessons: [
            const TopicLesson(
              id: 'l1',
              title: 'Lines and angles',
              read: true,
              today: false,
            ),
            const TopicLesson(
              id: 'l3',
              title: 'Circles',
              read: false,
              today: true,
            ),
          ],
        ),
        onBack: () {},
        onLesson: (_) {},
        onPractice: () {},
      ),
      scroll: false,
      cells: _cells,
    );
  });

  group('Record (/record)', () {
    dsMatrix(
      'record',
      (_) => RecordPage(
        record: StudentRecord(
          weeksIn: 3,
          dayStreak: 2,
          streakStartedOn: null,
          questionsAnswered: 380,
          sessionMinutes: 2130,
          lessonsRead: 30,
          daysActive: 12,
          longestStreak: 5,
          bestMockPercent: 64,
          accuracySeries: [
            (weekStart: DateTime(2026, 10, 5), accuracy: .5),
            (weekStart: DateTime(2026, 10, 12), accuracy: .55),
            (weekStart: DateTime(2026, 10, 19), accuracy: .6),
          ],
          mocks: const [],
        ),
        mocks: [
          RecordMockRow(
            id: 'm',
            name: 'CSE simulation',
            date: DateTime(2026, 10, 24),
            percent: 64,
          ),
        ],
        onBack: () {},
        onMock: (_) {},
      ),
      scroll: false,
      cells: _cells,
    );
  });

  group('Tendencies (/tendencies)', () {
    final profile = archetypeCatalog.first;
    dsMatrix(
      'tendencies',
      (_) => TendenciesPage(
        data: HowYouWork(
          name: 'Ana',
          archetype: profile.label,
          archetypeLine: archetypeIdentityLine(profile.id),
          tendencies: const [
            Tendency(
              id: TendencyId.underPressure,
              heading: 'Under pressure',
              leftLabel: 'practicing',
              rightLabel: 'under time',
              leftFigure: '70%',
              rightFigure: '60%',
              sentence: 'Measured pressure',
              isLoss: false,
              gap: null,
              unlockAction: '',
              confidence: TendencyConfidence.clear,
            ),
          ],
          whenYouWork: const [],
        ),
        pro: true,
        paused: false,
        onBack: () {},
        onName: () {},
        onPro: () {},
      ),
      scroll: false,
      cells: _cells,
    );

    dsMatrix(
      'tendencies empty',
      (_) => TendenciesPage(
        data: const HowYouWork(
          name: null,
          archetype: null,
          archetypeLine: null,
          tendencies: [],
          whenYouWork: [],
        ),
        pro: false,
        paused: false,
        onBack: () {},
        onName: () {},
        onPro: () {},
      ),
      scroll: false,
      cells: _cells,
    );
  });
}
