import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/beta_feedback/presentation/reward_page.dart';

import '../../../helpers/ds_matrix.dart' show loadDsFonts;
import '../../../helpers/in_memory_database.dart';
import 'beta_feedback_fakes.dart';
import 'feedback_harness.dart';

/// The reward page (/settings/beta-feedback) and the question report form at the three widths that matter, light and dark,
/// text 1.0 and 2.0. A layout overflow fails the cell.
final _cells = <({double width, bool dark, double scale})>[
  for (final width in [390.0, 1100.0, 1440.0])
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) (width: width, dark: dark, scale: scale),
];

String _name(({double width, bool dark, double scale}) c) =>
    '${c.width.toInt()} ${c.dark ? 'dark' : 'light'} x${c.scale}';

FbHarness _harness(({double width, bool dark, double scale}) c) => FbHarness(
      width: c.width,
      wide: c.width >= 1024,
      dark: c.dark,
      textScale: c.scale,
      now: ph(11, 16, 9),
      api: FakeBetaFeedbackApi(
        reward: fakeReward(
          days: betaDays.take(5).toList(),
          surveySubmitted: true,
          eligible: true,
        ),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadDsFonts);

  for (final c in _cells) {
    testWidgets('Reward page (${_name(c)})', (tester) async {
      await _harness(c).pump(tester, const RewardPage(frame: testFrame));
      expect(tester.takeException(), isNull);
      expect(find.text('Activate 1 Year of Pro'), findsOneWidget);
    });

    testWidgets('Question report form (${_name(c)})', (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      tester.view
        ..physicalSize = Size(c.width, 1200)
        ..devicePixelRatio = 1;
      debugWebPlatformOverride = c.width >= 1024;
      addTearDown(() {
        tester.view.reset();
        debugWebPlatformOverride = null;
      });
      final wide = c.width >= 1024;
      await tester.pumpWidget(
        MaterialApp(
          theme:
              c.dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(c.width, 1200),
              textScaler: TextScaler.linear(c.scale),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 416),
                    child: ReportForm(
                      questionId: 'q',
                      queue: ReportQueue(db, account: () => 'a'),
                      onClose: () {},
                      onSaved: (_) {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Send'), findsOneWidget);
    });
  }
}
