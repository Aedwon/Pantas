import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/mock_hourglass.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';

void main() {
  testWidgets('enabling reduced motion stops the paused clock and hourglass',
      (tester) async {
    debugWebPlatformOverride = true;
    addTearDown(() => debugWebPlatformOverride = null);
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var reduced = false;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: true),
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return MediaQuery(
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
                onResume: () {},
                onDiscard: () {},
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 4000));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 6000));
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    update(() => reduced = true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 12));
    expect(tester.binding.transientCallbackCount, 0);
    expect(
      tester.widget<MockHourglass>(find.byType(MockHourglass)).streamOpacity,
      0,
    );
    expect(tester.takeException(), isNull);
  });
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
              paper: const Text('Frozen paper'),
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
      final paper = find.byKey(const ValueKey('web-pause-paper'));
      expect(tester.widget<Opacity>(paper).opacity, reduced ? 0 : 1);
      final content = find.byKey(const ValueKey('web-pause-content'));
      expect(tester.widget<Opacity>(content).opacity, reduced ? 1 : 0);
      if (!reduced) {
        expect(find.text('30:00'), findsOneWidget);
        final drop = tester
            .widget<Transform>(find.byKey(const ValueKey('web-pause-drop')));
        expect(drop.transform.storage[1], isNegative);
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
