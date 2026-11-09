// Route /lesson/:lessonId, the reader.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/lesson/presentation/lesson_page.dart';

import 'fixtures/study_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'lesson_reader',
    (tester, width) =>
        pumpStudyScreen(tester, width, const LessonPage(lessonId: 'l1')),
  );
}
