// Route /study, the Study list.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/lesson/presentation/learn_tab_home.dart';

import 'fixtures/study_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'study_list',
    (tester, width) => pumpStudyScreen(
      tester,
      width,
      const StudyTabHome(),
      shell: true,
    ),
  );
}
