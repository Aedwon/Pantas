// Route /plan/day/:date.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/plan_day_page.dart';

import 'fixtures/plan_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'plan_day',
    (tester, width) {
      final day = PlanDayPage(
        date: DateTime(2026, 11, 9),
        past: false,
        rest: false,
        lessons: const [
          HomeTodayLesson(
            id: 'l',
            title: 'DNA and genes',
            subject: 'Biology',
            minutes: 8,
            read: true,
          ),
        ],
        reviewsDone: 2,
        reviewsTotal: 3,
        newDone: 1,
        newTotal: 4,
        onBack: () {},
        onLesson: (_) {},
      );
      // The wide route draws the day in a pane beside the plan, in the app
      // frame (PlanDayScreen).
      return pumpScreen(
        tester,
        width,
        width >= 1024
            ? inShell(
                planFixture(webPane: day, selectedWeek: '2026-11-08'),
                width,
                ShellTab.home,
              )
            : scaffolded(day),
      );
    },
  );
}
