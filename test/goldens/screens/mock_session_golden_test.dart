// Route /quiz/mock/resume/:attemptId, a mock exam in progress.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/application/mock_start_providers.dart';

import 'fixtures/mock_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'mock_session',
    (tester, width) => pumpScreen(
      tester,
      width,
      mockSessionPage(),
      overrides: [
        hydratedMockQuestionProvider
            .overrideWith((ref, id) => hydratedMockQuestion()),
      ],
    ),
  );
}
