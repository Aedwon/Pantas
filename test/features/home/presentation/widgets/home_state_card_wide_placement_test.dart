import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/home/presentation/widgets/home_state_card.dart';

import '../../../../helpers/button_placement.dart';

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  testWidgets('wide exam-passed card pair keeps the 8 px gap', (tester) async {
    // Button placement rule: 8 px between a pair; it was 12 px before Nov 25.
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    debugWebPlatformOverride = true;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 1080,
              child: HomeStateCard(
                state: HomeState.passed,
                examName: 'CSE Professional',
                examShortName: 'CSE-P',
                onPrimary: () {},
                onSecondary: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expectWidePlacement(tester, within: find.byType(HomeStateCard));
  });
}
