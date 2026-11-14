// Route /home, before the first assessment: the screen a new student sees.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/home/presentation/home_tab.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';

import 'fixtures/study_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'home',
    (tester, width) => pumpStudyScreen(
      tester,
      width,
      const HomeTab(),
      shell: true,
      shellTab: 0,
      overrides: [nowProvider.overrideWithValue(() => screenNow)],
    ),
  );
}
