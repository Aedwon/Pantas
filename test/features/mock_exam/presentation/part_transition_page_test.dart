import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/presentation/part_transition_page.dart';

void main() {
  Widget transition({
    bool dark = false,
    bool early = false,
    bool still = true,
    double scale = 1,
    VoidCallback? onStart,
  }) =>
      MaterialApp(
        theme: dark ? buildDarkTheme() : buildLightTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(scale),
            disableAnimations: still,
          ),
          child: PartTransitionPage(
            partNames: const [
              'Language Proficiency',
              'Reading Comprehension',
              'Mathematics',
              'Science',
            ],
            nextPartIndex: 3,
            endedEarly: early,
            answeredQuestions: [
              for (var i = 0; i < 60; i++) i != 22 && i != 47,
            ],
            onStartNext: onStart ?? () {},
          ),
        ),
      );
  for (final dark in [false, true]) {
    testWidgets('transition uses actual dots and no flags, dark=$dark',
        (tester) async {
      await tester.pumpWidget(transition(dark: dark));
      expect(find.text('Time is up.'), findsOneWidget);
      expect(find.text('Part 3 · Mathematics'), findsOneWidget);
      expect(find.text('58 answered'), findsOneWidget);
      expect(find.text('2 blank'), findsOneWidget);
      expect(find.byKey(const ValueKey('part-dot-22')), findsOneWidget);
      expect(find.textContaining('flagged'), findsNothing);
      expect(find.byType(AppBar), findsNothing);
      expect(find.text('The clock starts when you tap.'), findsOneWidget);
      final arrow =
          tester.widget<Transform>(find.byKey(const ValueKey('part-arrow')));
      expect(arrow.transform.getTranslation().y, 168);
      var started = false;
      await tester.pumpWidget(
        transition(dark: dark, early: true, onStart: () => started = true),
      );
      expect(find.text('Part 3 ended.'), findsOneWidget);
      await tester.tap(find.text('Start Part 4'));
      expect(started, isTrue);
    });
    testWidgets('transition fits phone with 200 percent text, dark=$dark',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(transition(dark: dark, scale: 2));
      expect(tester.takeException(), isNull);
      final button = tester.getRect(find.text('Start Part 4'));
      expect(button.bottom, lessThanOrEqualTo(640));
      await tester.scrollUntilVisible(find.text('Science'), 100);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('dots, completion and arrow retain their ordered overlap',
      (tester) async {
    await tester.pumpWidget(transition(still: false));
    final initial = tester
        .widget<Opacity>(find.byKey(const ValueKey('part-dot-opacity-0')));
    expect(initial.opacity, 0);
    await tester.pump(const Duration(milliseconds: 400));
    expect(
      tester
          .widget<Opacity>(find.byKey(const ValueKey('part-dot-opacity-0')))
          .opacity,
      1,
    );
    expect(
      tester
          .widget<Opacity>(find.byKey(const ValueKey('part-dot-opacity-59')))
          .opacity,
      0,
    );
    await tester.pump(const Duration(milliseconds: 1200));
    final middle =
        tester.widget<Transform>(find.byKey(const ValueKey('part-arrow')));
    expect(middle.transform.getTranslation().y, 118);
    await tester.pump(const Duration(milliseconds: 450));
    final finalArrow =
        tester.widget<Transform>(find.byKey(const ValueKey('part-arrow')));
    expect(finalArrow.transform.getTranslation().y, 168);
    expect(
      tester
          .widget<Opacity>(find.byKey(const ValueKey('part-dot-opacity-59')))
          .opacity,
      1,
    );
  });
}
