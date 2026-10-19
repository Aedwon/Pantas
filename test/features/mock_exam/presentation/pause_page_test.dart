import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/presentation/mock_hourglass.dart';
import 'package:pantas/features/mock_exam/presentation/pause_page.dart';

const _parts = [
  'Language Proficiency',
  'Reading Comprehension',
  'Mathematics',
  'Science',
];

Widget _paused({
  Duration remaining = const Duration(minutes: 21, seconds: 47),
  Duration partLength = const Duration(minutes: 75),
  List<String> partNames = _parts,
  int current = 2,
  int answered = 144,
  VoidCallback? onResume,
  VoidCallback? onDiscard,
  bool still = false,
  double textScale = 1,
  bool dark = false,
}) =>
    MaterialApp(
      theme: dark ? buildDarkTheme() : buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          disableAnimations: still,
          textScaler: TextScaler.linear(textScale),
        ),
        child: PausePage(
          partNames: partNames,
          currentPartIndex: current,
          remaining: remaining,
          partLength: partLength,
          answeredCount: answered,
          onResume: onResume ?? () {},
          onDiscard: onDiscard ?? () {},
        ),
      ),
    );

HourglassPainter _painter(WidgetTester tester) => tester
    .widget<CustomPaint>(find.byKey(const ValueKey('pause-hourglass')))
    .painter! as HourglassPainter;

double _opacityOf(WidgetTester tester, Finder finder) =>
    tester.widget<Opacity>(finder).opacity;

Offset _hourglassTranslation(WidgetTester tester) {
  final translate = tester.widget<Transform>(
    find
        .ancestor(
          of: find.byKey(const ValueKey('pause-hourglass-tip')),
          matching: find.byType(Transform),
        )
        .at(1),
  );
  final t = translate.transform.getTranslation();
  return Offset(t.x, t.y);
}

double _hourglassScale(WidgetTester tester) {
  final scale = tester.widget<Transform>(
    find
        .ancestor(
          of: find.byKey(const ValueKey('pause-hourglass-tip')),
          matching: find.byType(Transform),
        )
        .first,
  );
  return scale.transform.getMaxScaleOnAxis();
}

void main() {
  testWidgets('the paused screen is the last frame of MK_PauseA',
      (tester) async {
    await tester.pumpWidget(_paused(still: true));
    await tester.pump();

    expect(find.text('Paused'), findsOneWidget);
    expect(find.text('21:47'), findsOneWidget);
    expect(find.text('left in this part'), findsOneWidget);
    for (final name in _parts) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Discard This Mock'), findsOneWidget);
    // Nothing from the paper is on screen while paused.
    expect(find.textContaining('answered'), findsNothing);
    expect(find.textContaining('flagged'), findsNothing);
    expect(_hourglassTranslation(tester), Offset.zero);
    expect(_hourglassScale(tester), 1);
    expect(_opacityOf(tester, find.byKey(const ValueKey('pause-content'))), 1);
  });

  testWidgets('the sand on top is the time left in the part', (tester) async {
    await tester.pumpWidget(_paused(still: true));
    await tester.pump();
    // 21:47 of 75 minutes, as the board draws it.
    final painter = _painter(tester);
    expect(painter.remainingFraction, closeTo(21.7833 / 75, 1e-4));
    expect(painter.topSandHeight, closeTo(15.1, .01));
    expect(painter.bottomSandHeight, closeTo(36.9, .01));
  });

  testWidgets('an empty or unbounded part never breaks the sand',
      (tester) async {
    await tester.pumpWidget(
      _paused(
        still: true,
        remaining: Duration.zero,
        partLength: Duration.zero,
        partNames: const [''],
        current: 0,
      ),
    );
    await tester.pump();
    expect(_painter(tester).topSandHeight, 0);
    // A one-block paper shows no list of parts.
    expect(find.byKey(const ValueKey('pause-part-arrow')), findsNothing);
  });

  testWidgets('the arrow marks the open part and parts show done or to come',
      (tester) async {
    await tester.pumpWidget(_paused(still: true));
    await tester.pump();
    final arrow = tester.widget<Transform>(
      find.byKey(const ValueKey('pause-part-arrow')),
    );
    // 18 down for the first row, then 50 for each part before the open one.
    expect(arrow.transform.getTranslation().y, 118);
  });

  testWidgets('entry: the large hourglass falls, then shrinks into place',
      (tester) async {
    await tester.pumpWidget(_paused());
    await tester.pump();
    // At the start only the page is arriving.
    expect(_opacityOf(tester, find.byKey(const ValueKey('pause-content'))), 0);

    await tester.pump(const Duration(milliseconds: 400));
    expect(_hourglassTranslation(tester).dy, closeTo(290, .001));
    expect(_hourglassScale(tester), closeTo(2.4, .001));
    expect(_painter(tester).streamOpacity, closeTo(1, .001));
    expect(_painter(tester).streamOffset, lessThan(-8));

    // The grains stop before it shrinks.
    await tester.pump(const Duration(milliseconds: 1500));
    expect(_painter(tester).streamOpacity, 0);
    expect(_hourglassTranslation(tester).dy, closeTo(290, .001));

    await tester.pump(const Duration(milliseconds: 300));
    // 200ms into the 600ms shrink.
    final third = PantasCurves.edgeGrow.transform(1 / 3);
    expect(
      _hourglassTranslation(tester).dy,
      closeTo(290 * (1 - third), 1),
    );

    await tester.pump(const Duration(milliseconds: 400));
    expect(_hourglassTranslation(tester).dy, closeTo(0, .001));
    // The rest of the screen starts arriving at 2500ms, so a quarter of the
    // way through its 400ms fade at 2600ms.
    expect(
      _opacityOf(tester, find.byKey(const ValueKey('pause-content'))),
      closeTo(.25, .01),
    );

    await tester.pump(const Duration(milliseconds: 300));
    expect(_opacityOf(tester, find.byKey(const ValueKey('pause-content'))), 1);
  });

  testWidgets('once in place the hourglass tips now and then', (tester) async {
    await tester.pumpWidget(_paused());
    await tester.pump(const Duration(milliseconds: 2900));
    double tip() => tester
        .widget<Transform>(find.byKey(const ValueKey('pause-hourglass-tip')))
        .transform
        .storage[1];
    // The loop starts on the next frame. Sine of the angle: zero at rest.
    await tester.pump(const Duration(milliseconds: 100));
    expect(tip(), closeTo(0, 1e-6));
    await tester.pump(const Duration(milliseconds: 2550));
    // 2.55s into the loop: moving towards the first tip.
    expect(tip(), isNot(closeTo(0, 1e-6)));
    await tester.pump(const Duration(milliseconds: 1500));
    expect(tip(), closeTo(0, 1e-6));
  });

  testWidgets('Resume plays the sequence back, then resumes', (tester) async {
    var resumed = 0;
    await tester.pumpWidget(_paused(onResume: () => resumed++));
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(resumed, 0);

    await tester.pump(const Duration(milliseconds: 250));
    expect(
      _opacityOf(tester, find.byKey(const ValueKey('pause-content'))),
      closeTo(0, 1e-6),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(_hourglassTranslation(tester).dy, closeTo(290, .001));
    expect(resumed, 0);
    await tester.pump(const Duration(milliseconds: 1700));
    expect(resumed, 0);
    await tester.pump(const Duration(milliseconds: 100));
    expect(resumed, 1);
  });

  testWidgets('with reduced motion Resume acts at once', (tester) async {
    var resumed = 0;
    await tester.pumpWidget(_paused(still: true, onResume: () => resumed++));
    await tester.pump();
    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(resumed, 1);
  });

  testWidgets('Resume is the only filled button; Discard is destructive text',
      (tester) async {
    await tester.pumpWidget(_paused(still: true));
    await tester.pump();
    expect(find.byType(PantasButton), findsOneWidget);
    final context = tester.element(find.byType(PausePage));
    final discard = tester.widget<Text>(find.text('Discard This Mock'));
    expect(discard.style!.color, context.colors.destructive);
    expect(
      tester.getSize(find.bySemanticsLabel('Discard This Mock')).height,
      greaterThanOrEqualTo(44),
    );
  });

  testWidgets('Discard asks first, says what goes, and can be backed out of',
      (tester) async {
    var discarded = 0;
    await tester.pumpWidget(
      _paused(still: true, onDiscard: () => discarded++),
    );
    await tester.pump();
    await tester.tap(find.text('Discard This Mock'));
    await tester.pumpAndSettle();

    expect(find.text('Discard this mock?'), findsOneWidget);
    expect(
      find.text(
        "Your 144 answers get deleted, and this attempt won't appear in your "
        "record. It also doesn't use up a mock attempt.",
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Keep It'));
    await tester.pumpAndSettle();
    expect(discarded, 0);

    await tester.tap(find.text('Discard This Mock'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(discarded, 1);
  });

  testWidgets('one answer reads in the singular', (tester) async {
    await tester.pumpWidget(_paused(still: true, answered: 1));
    await tester.pump();
    await tester.tap(find.text('Discard This Mock'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your 1 answer gets deleted'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets('fits 320 and 360 wide at 200 percent text, dark=$dark',
        (tester) async {
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [320.0, 360.0]) {
        await tester.pumpWidget(const SizedBox.shrink());
        tester.view.physicalSize = Size(width * 2, 1136);
        await tester.pumpWidget(
          _paused(still: true, textScale: 2, dark: dark),
        );
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '$width dp');
        expect(find.text('Resume'), findsOneWidget);
        expect(find.text('Discard This Mock'), findsOneWidget);
      }
    });
  }
}
