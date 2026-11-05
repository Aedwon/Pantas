import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
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

  group('a strict break', () {
    Widget breakPage({
      Duration? left = const Duration(seconds: 42),
      bool starting = false,
      VoidCallback? onStart,
      bool wide = false,
    }) =>
        MaterialApp(
          theme: wide ? buildLightTheme(web: true) : buildLightTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: PartTransitionPage(
            partNames: const ['Mathematics', 'Reasoning', 'Science'],
            nextPartIndex: 2,
            endedEarly: false,
            answeredQuestions: const [true, true, false],
            onStartNext: onStart ?? () {},
            starting: starting,
            breakRemaining: left,
            examTitle: 'PUP CET simulation',
          ),
        );

    testWidgets('the phone shows the clock, its bar and no hint',
        (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(breakPage());
      expect(find.text('0:42'), findsOneWidget);
      expect(find.text('until Part 3 starts'), findsOneWidget);
      expect(find.textContaining('The clock starts when'), findsNothing);
      expect(find.text('Start Part 3'), findsOneWidget);
      final bar = tester.widget<FractionallySizedBox>(
        find.descendant(
          of: find.byType(Scaffold),
          matching: find.byType(FractionallySizedBox),
        ),
      );
      expect(bar.widthFactor, closeTo(.7, .0001));
    });

    testWidgets('the wide page puts the closed part under the exam name',
        (tester) async {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
      tester.view
        ..physicalSize = const Size(1440, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var started = 0;
      await tester.pumpWidget(breakPage(wide: true, onStart: () => started++));
      expect(find.text('PUP CET simulation'), findsOneWidget);
      expect(find.text('Part 2 of 3 · Reasoning'), findsOneWidget);
      expect(find.text('0:42'), findsOneWidget);
      expect(find.text('until Part 3 starts'), findsOneWidget);
      expect(find.text('The clock starts when you click.'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(started, 1);
    });

    testWidgets('the clock never goes past 0:00 or shows a negative',
        (tester) async {
      await tester.pumpWidget(breakPage(left: Duration.zero));
      expect(find.text('0:00'), findsOneWidget);
    });

    testWidgets('a start on its way cannot be asked for again', (tester) async {
      var started = 0;
      await tester.pumpWidget(
        breakPage(starting: true, onStart: () => started++),
      );
      await tester.tap(find.text('Start Part 3'), warnIfMissed: false);
      expect(started, 0);
    });
  });

  testWidgets('a wait for the student keeps its hint and takes no clock',
      (tester) async {
    await tester.pumpWidget(transition());
    expect(find.text('The clock starts when you tap.'), findsOneWidget);
    expect(find.textContaining('until Part'), findsNothing);
    var started = 0;
    await tester.pumpWidget(transition(onStart: () => started++));
    await tester.tap(find.text('Start Part 4'));
    expect(started, 1);
  });
}
