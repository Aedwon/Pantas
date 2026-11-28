import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';

import '../../../../helpers/button_placement.dart';

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  Future<void> show(
    WidgetTester tester, {
    required bool wide,
    bool dark = false,
    VoidCallback? onPrimary,
  }) async {
    tester.view
      ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    debugWebPlatformOverride = wide;
    final card = HomeStateCard(
      state: HomeState.continueAssessment,
      answered: 8,
      total: 30,
      examName: '',
      examShortName: '',
      onPrimary: onPrimary ?? () {},
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
        home: MediaQuery(
          data: MediaQueryData(
            size: tester.view.physicalSize,
            disableAnimations: true,
          ),
          child: Scaffold(
            body: wide
                ? Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(width: 1080, child: card),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: card,
                  ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    testWidgets('phone Continue card, dark=$dark', (tester) async {
      await show(tester, wide: false, dark: dark);
      expect(find.text('Continue the assessment'), findsOneWidget);
      expect(find.text('8 of 30 answered.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('First, a short assessment'), findsNothing);
      expect(find.text('Start Assessment'), findsNothing);
      expect(find.text('Enter'), findsNothing);
      // The same 52 high full-width button as the Start card (C2B_Home).
      final button = find.widgetWithText(PantasButton, 'Continue');
      expect(tester.getSize(button).height, 52);
      expect(
        tester.getSize(button).width,
        tester.getSize(find.byType(HomeStateCard)).width - 36,
      );
    });

    testWidgets('wide Continue card, dark=$dark', (tester) async {
      var called = 0;
      await show(tester, wide: true, dark: dark, onPrimary: () => called++);
      expect(find.text('Continue the assessment'), findsOneWidget);
      expect(find.text('8 of 30 answered.'), findsOneWidget);
      expect(find.widgetWithText(WebButton, 'Continue'), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
      expect(find.text('Start Assessment'), findsNothing);
      final card = tester.getRect(find.byType(WebCard));
      final button = tester.getRect(find.byType(WebButton));
      // Right-aligned inside the card padding (C2B_HomeWide).
      expect(card.right - button.right, closeTo(20, 1));
      expectWidePlacement(tester, within: find.byType(HomeStateCard));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(called, 1);
    });
  }
}
