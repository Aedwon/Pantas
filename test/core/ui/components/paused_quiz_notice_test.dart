import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/paused_quiz_notice.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

void main() {
  for (final wide in [false, true]) {
    testWidgets('names the paused quiz and offers both ways out, wide=$wide',
        (tester) async {
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = Size(wide ? 1440 : 390, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var resumed = 0;
      var discarded = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: wide),
          home: Scaffold(
            body: Column(
              children: [
                PausedQuizNotice(
                  onResume: () => resumed++,
                  onDiscard: () => discarded++,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.textContaining('You paused a quiz.'), findsOneWidget);
      await tester.tap(find.text('Resume'));
      await tester.tap(find.text('Discard this session'));
      expect(resumed, 1);
      expect(discarded, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
