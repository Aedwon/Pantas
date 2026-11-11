import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/report_queue.dart';
import 'package:pantas/core/ui/components/report_form.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/beta_feedback/presentation/exit_survey_page.dart';
import 'package:pantas/features/beta_feedback/presentation/feedback_page.dart';
import 'package:pantas/features/beta_feedback/presentation/sent_feedback_page.dart';

import '../../../helpers/ds_matrix.dart' show loadDsFonts;
import '../../../helpers/in_memory_database.dart';
import 'beta_feedback_fakes.dart';
import 'feedback_harness.dart';

/// The beta feedback screens (/settings/beta-feedback, /survey, /sent/:id) and
/// the question report form at the three widths that matter, light and dark,
/// text 1.0 and 2.0. A layout overflow fails the cell.
final _cells = <({double width, bool dark, double scale})>[
  for (final width in [390.0, 1100.0, 1440.0])
    for (final dark in [false, true])
      for (final scale in [1.0, 2.0]) (width: width, dark: dark, scale: scale),
];

String _name(({double width, bool dark, double scale}) c) =>
    '${c.width.toInt()} ${c.dark ? 'dark' : 'light'} x${c.scale}';

Map<String, WidgetBuilder> get _routes => {
      '/settings/beta-feedback': (_) =>
          const Scaffold(body: Text('feedback page')),
    };

FbHarness _harness(({double width, bool dark, double scale}) c) => FbHarness(
      width: c.width,
      wide: c.width >= 1024,
      dark: c.dark,
      textScale: c.scale,
      now: ph(11, 16, 9),
      api: FakeBetaFeedbackApi(
        reward: fakeReward(days: betaDays.take(5).toList(), eligible: true),
        sent: [
          fakeSent(
            'a',
            'The explanation for question 12 says B but the answer key '
                'marks C.',
            ph(11, 11, 21, 41),
            images: 2,
          ),
          fakeSent('b', '', ph(11, 10, 7, 5), images: 1),
        ],
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadDsFonts);

  for (final c in _cells) {
    testWidgets('Feedback page (${_name(c)})', (tester) async {
      await _harness(c).pump(
        tester,
        const FeedbackPage(frame: testFrame),
        routes: _routes,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('Exit survey (${_name(c)})', (tester) async {
      await _harness(c).pump(
        tester,
        const ExitSurveyPage(frame: testFrame),
        routes: _routes,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Send Survey'), findsOneWidget);
    });

    testWidgets('Sent feedback (${_name(c)})', (tester) async {
      await _harness(c).pump(
        tester,
        const SentFeedbackPage(frame: testFrame, id: 'a'),
        routes: _routes,
      );
      expect(tester.takeException(), isNull);
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
                      queue: ReportQueue(db),
                      onClose: () {},
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
      expect(find.text('Save'), findsOneWidget);
    });
  }
}
