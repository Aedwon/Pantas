// Route /plan/day/:date.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/domain/home_today_lesson.dart';
import 'package:pantas/features/home/presentation/plan_day_page.dart';

import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'plan_day',
    (tester, width) => pumpScreen(
      tester,
      width,
      scaffolded(
        PlanDayPage(
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
        ),
      ),
    ),
  );
}
