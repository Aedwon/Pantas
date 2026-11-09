// Route /performance.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/application/performance/performance_provider.dart';
import 'package:pantas/features/home/presentation/performance_page.dart';

import 'screen_harness.dart';

PerformanceRow _row(String id, int right, int total) => PerformanceRow(
      id: id,
      title: id,
      subtext: 'Subject',
      correct: right,
      answered: total,
      secondsPerQuestion: null,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'performance',
    (tester, width) => pumpScreen(
      tester,
      width,
      scaffolded(
        PerformancePage(
          data: PerformanceViewData(
            subjects: [_row('Math', 8, 10), _row('Science', 3, 9)],
            topics: [_row('Algebra', 1, 2), _row('Geometry', 1, 4)],
            lessons: [],
            subjectCounts: {'Math': 2},
            lessonLevelAvailable: true,
            parentSubjectIds: {'Algebra': 'Math', 'Geometry': 'Math'},
          ),
          pro: true,
          paused: false,
          onTopic: (_) {},
          onPro: () {},
          onBack: () {},
        ),
      ),
    ),
  );
}
