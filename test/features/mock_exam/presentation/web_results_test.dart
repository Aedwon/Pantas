import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';
import 'web_mock_layout_test.dart' show result;

void main() {
  tearDown(() => debugWebPlatformOverride = null);
  for (final dark in [false, true]) {
    testWidgets(
        'mock results shared card, full chart and Done shortcut dark=$dark',
        (tester) async {
      debugWebPlatformOverride = true;
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var done = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: MockResultsPage(
            results: result,
            proIsActive: true,
            blueprintName: 'CSE simulation',
            dateFormatted: 'Friday, October 30',
            onDone: () => done = true,
            onReviewTap: () {},
            pastResults: const [
              MockPastPoint(percent: 60, label: 'Oct 1'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final score = find.byKey(const ValueKey('web-mock-score'));
      expect(tester.getSize(score).width, 1040);
      expect(
        find.descendant(of: score, matching: find.text('See all questions')),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.byType(MockPastChart)).width,
        dark ? 998 : 1000,
      );
      expect(
        tester.getTopLeft(find.text('Done')).dy,
        lessThan(tester.getBottomLeft(find.text('CSE simulation')).dy),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(done, isTrue);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
        'past locked results keep score and show an invitation dark=$dark',
        (tester) async {
      debugWebPlatformOverride = true;
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: MockResultsPage(
            results: result,
            proIsActive: false,
            canReview: false,
            fromRecord: true,
            onSeePro: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Your record'), findsOneWidget);
      expect(find.text('See all questions'), findsNothing);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('web-mock-score')),
          matching: find.text('See Pro'),
        ),
        findsNothing,
      );
      expect(find.text('See Pro'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
