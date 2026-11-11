// Route /mock/results/:attemptId.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../features/mock_exam/presentation/web_mock_layout_test.dart'
    as layout show result;
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'mock_results',
    (tester, width) => pumpScreen(
      tester,
      width,
      scaffolded(
        MockResultsPage(
          results: layout.result,
          examId: 'exam_upcat',
          proIsActive: false,
          reviewUntil: DateTime(2026, 11, 23),
          blueprintName: 'UPCAT simulation',
          dateFormatted: 'Monday, Nov 9',
          disableAnimations: true,
          onReviewTap: () {},
          onDone: () {},
          onSeePro: () {},
        ),
      ),
    ),
  );
}
