import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';

import '../../../helpers/button_placement.dart';
import '../../../helpers/ds_matrix.dart';

void main() {
  setUpAll(loadDsFonts);
  tearDown(() => debugWebPlatformOverride = null);

  for (final parts in [
    const ['Language', 'Reading', 'Math', 'Science'],
    const ['CSE Professional'],
  ]) {
    testWidgets('wide pause page pair keeps the 8 px gap (${parts.length})',
        (tester) async {
      // Button placement rule: 8 px between a pair; it was 12 px before Nov 25.
      debugWebPlatformOverride = true;
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(1440, 900),
              disableAnimations: true,
            ),
            child: PausePage(
              partNames: parts,
              currentPartIndex: parts.length > 1 ? 2 : 0,
              remaining: const Duration(minutes: 21, seconds: 47),
              partLength: const Duration(minutes: 75),
              answeredCount: 144,
              onResume: () {},
              onDiscard: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
      expectWidePlacement(tester);
    });
  }
}
