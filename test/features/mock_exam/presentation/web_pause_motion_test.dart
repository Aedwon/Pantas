import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/mock_hourglass.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets('wide pause entry and resume, reduced=$reduced',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var resumed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: true),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(1440, 900),
              disableAnimations: reduced,
            ),
            child: PausePage(
              partNames: const ['General Information'],
              currentPartIndex: 0,
              remaining: const Duration(minutes: 30),
              partLength: const Duration(minutes: 90),
              answeredCount: 3,
              onResume: () => resumed = true,
              onDiscard: () {},
            ),
          ),
        ),
      );
      final content = find.byKey(const ValueKey('web-pause-content'));
      expect(tester.widget<Opacity>(content).opacity, reduced ? 1 : 0);
      if (!reduced) {
        expect(find.text('30:00'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 1000));
        expect(find.text('29:59'), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 500));
        expect(
          tester
              .widget<MockHourglass>(find.byType(MockHourglass))
              .streamOpacity,
          0,
        );
      }
      await tester.pump(const Duration(milliseconds: 4100));
      expect(tester.widget<Opacity>(content).opacity, 1);
      expect(find.text('Paused'), findsOneWidget);
      await tester.tap(find.text('Resume'));
      await tester.pump();
      expect(resumed, reduced);
      if (!reduced) {
        await tester.pump(const Duration(milliseconds: 900));
        expect(
          tester
              .widget<MockHourglass>(find.byType(MockHourglass))
              .streamOpacity,
          1,
        );
      }
      await tester.pump(const Duration(milliseconds: 2700));
      expect(resumed, isTrue);
      if (reduced) expect(tester.binding.transientCallbackCount, 0);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
