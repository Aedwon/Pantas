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
        1000,
      );
      expect(
        tester.getTopLeft(find.text('Done')).dy,
        lessThan(tester.getBottomLeft(find.text('CSE simulation')).dy),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(done, isTrue);
      expect(tester.takeException(), isNull);
    });
    testWidgets('Enter on "See all questions" opens them, not Done dark=$dark',
        (tester) async {
      debugWebPlatformOverride = true;
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var done = 0;
      var review = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
          home: MockResultsPage(
            results: result,
            proIsActive: true,
            blueprintName: 'CSE simulation',
            dateFormatted: 'Friday, October 30',
            onDone: () => done++,
            onReviewTap: () => review++,
            pastResults: const [MockPastPoint(percent: 60, label: 'Oct 1')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      Focus.of(tester.element(find.text('See all questions'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(review, 1, reason: 'Enter pressed the control it was on');
      expect(done, 0);
    });
    testWidgets('wide results from Your record vs after finishing dark=$dark',
        (tester) async {
      debugWebPlatformOverride = true;
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Future<void> pump({required bool fromRecord}) async {
        await tester.pumpWidget(
          MaterialApp(
            theme:
                dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
            home: MockResultsPage(
              results: result,
              proIsActive: true,
              fromRecord: fromRecord,
              blueprintName: 'CSE simulation',
              dateFormatted: 'Friday, October 30',
              onDone: () {},
              onFullRecord: () {},
              pastResults: const [MockPastPoint(percent: 60, label: 'Oct 1')],
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pump(fromRecord: true);
      expect(find.text('Your record'), findsOneWidget);
      // 6T-10: the board's 64 px header, as other full-screen pages have, and
      // the title stays where 64 + 16 puts it.
      expect(tester.getCenter(find.text('Your record')).dy, 32);
      expect(tester.getTopLeft(find.text('CSE simulation')).dy, 80);
      expect(find.text('Done'), findsNothing);
      expect(find.byTooltip('Close'), findsNothing);
      expect(find.text('See full record'), findsOneWidget);
      expect(find.byType(MockPastChart), findsNothing);
      expect(find.text('VERSUS PAST RESULTS'), findsNothing);
      await pump(fromRecord: false);
      expect(find.byTooltip('Close'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Your record'), findsNothing);
      expect(find.text('See full record'), findsOneWidget);
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
