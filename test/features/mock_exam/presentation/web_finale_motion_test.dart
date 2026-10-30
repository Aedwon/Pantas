import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/cse_mock_finale.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/web_mock_finale.dart';

import 'cse_mock_finale_test.dart' show input;
import 'web_mock_layout_test.dart' show result;

void main() {
  for (final reduced in [false, true]) {
    testWidgets('wide finale ends once, reduced=$reduced', (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(1440, 1000),
              disableAnimations: reduced,
            ),
            child: CseMockFinale(
              input: input(),
              blueprintName: 'CSE Professional simulation',
              resultsBuilder: (_, clock) => MockResultsPage(
                results: result,
                blueprintName: 'CSE Professional simulation',
                proIsActive: true,
                finaleClock: clock,
                pastResults: const [MockPastPoint(percent: 60, label: 'Oct 1')],
                onDone: () {},
              ),
            ),
          ),
        ),
      );
      final header = find
          .byWidgetPredicate((w) => w is WebFinaleEffect && w.track == 'k-rh');
      final past = find.byWidgetPredicate(
        (w) => w is WebFinaleEffect && w.track == 'k-rpast',
      );
      double opacity(Finder f) => tester
          .widget<Opacity>(
            find.descendant(of: f, matching: find.byType(Opacity)).first,
          )
          .opacity;
      expect(opacity(header), reduced ? 1 : 0);
      expect(opacity(past), reduced ? 1 : 0);
      await tester.pump(const Duration(milliseconds: 11350));
      expect(opacity(header), 1);
      expect(opacity(past), 1);
      expect(find.byKey(const ValueKey('web-mock-score')), findsOneWidget);
      expect(find.byKey(const ValueKey('web-finale-scene')), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.binding.transientCallbackCount, 0);
    });
  }
}
