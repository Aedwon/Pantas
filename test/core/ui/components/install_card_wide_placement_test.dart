import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/platform/install/install_platform.dart';
import 'package:pantas/core/ui/components/install_card.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

import '../../../helpers/button_placement.dart';

void main() {
  tearDown(() => debugWebPlatformOverride = null);

  testWidgets('wide install card pair keeps the 8 px gap', (tester) async {
    // Button placement rule: 8 px between a pair; it was 10 px before Nov 25.
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
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 1080,
              child: InstallCard(
                path: InstallPath.native,
                onPrimary: () {},
                onNotNow: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expectWidePlacement(tester, within: find.byType(InstallCard));
  });
}
