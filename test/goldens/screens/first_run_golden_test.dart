// Route /try: the first run. One sheet per step; files come from CI.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_state.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/first_run/application/first_run_data.dart';
import 'package:pantas/features/first_run/presentation/first_run_page.dart';

import '../../features/first_run/first_run_harness.dart' show fixtureData;
import '../../helpers/in_memory_database.dart';
import '../../helpers/pump_app.dart';
import 'screen_harness.dart';

const _right = '"picks":{"q1":"q1-c1"},"checked":["q1"]';
const _wrong = '"picks":{"q1":"q1-c1","q2":"q2-c1"},"checked":["q1","q2"]';
const _end = '"picks":{"q1":"q1-c1","q2":"q2-c1","q3":"q3-c1"},'
    '"checked":["q1","q2","q3"]';

Future<Finder> _pump(
  WidgetTester tester,
  double width, {
  required String step,
  String progress = '"picks":{},"checked":[]',
  bool dark = false,
}) async {
  final db = inMemoryDatabase();
  final contentDb = openTestContentDatabase();
  afterCapture(() async {
    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
  await tester.runAsync(
    () => db.into(db.devicePrefs).insert(
          DevicePrefsCompanion.insert(
            key: 'first_run_open_v1',
            value: '{"uid":"u1","examId":"exam_upcat","step":"$step",'
                '$progress}',
          ),
        ),
  );
  return pumpScreen(
    tester,
    width,
    const FirstRunPage(),
    dark: dark,
    router: true,
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      contentDatabaseProvider.overrideWithValue(contentDb),
      authStateProvider.overrideWith(
        (ref) => Stream.value(
          const AuthState.signedIn(
            user: AuthUser(uid: 'u1', email: '', displayName: ''),
          ),
        ),
      ),
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(buildExam(id: 'exam_upcat')),
      ),
      firstRunDataProvider.overrideWith((ref, examId) async => fixtureData),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final dark in [false, true]) {
    final suffix = dark ? '_dark' : '';
    goldenScreen(
      'first_run_intro$suffix',
      (tester, width) => _pump(tester, width, step: 'intro', dark: dark),
    );
    goldenScreen(
      'first_run_lesson$suffix',
      (tester, width) => _pump(tester, width, step: 'lesson', dark: dark),
    );
    goldenScreen(
      'first_run_question_right$suffix',
      (tester, width) => _pump(
        tester,
        width,
        step: 'question1',
        progress: _right,
        dark: dark,
      ),
    );
    goldenScreen(
      'first_run_question_wrong$suffix',
      (tester, width) => _pump(
        tester,
        width,
        step: 'question2',
        progress: _wrong,
        dark: dark,
      ),
    );
    // Animations are off in every sheet, so the end sheet is also the
    // Reduce Motion end state.
    goldenScreen(
      'first_run_end$suffix',
      (tester, width) => _pump(
        tester,
        width,
        step: 'end',
        progress: _end,
        dark: dark,
      ),
    );
  }
}
