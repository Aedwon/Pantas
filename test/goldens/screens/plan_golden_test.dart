// Route /plan.
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/plan_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'plan',
    (tester, width) => pumpScreen(
      tester,
      width,
      inShell(planFixture(), width, ShellTab.home),
    ),
  );
}
