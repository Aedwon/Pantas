// Route /quiz/mock/setup.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../features/mock_exam/presentation/web_mock_layout_test.dart'
    as layout show blueprint;
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen(
    'mock_setup',
    (tester, width) => pumpScreen(
      tester,
      width,
      scaffolded(
        inShell(
          MockSetupPage(parsedBlueprint: layout.blueprint, onStart: (_) {}),
          width,
          ShellTab.quiz,
        ),
      ),
    ),
  );
}
