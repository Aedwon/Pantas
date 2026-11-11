import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/time/pantas_dates.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/mock_card.dart';

import '../../../helpers/accessibility.dart';

void main() {
  MockCard card(
    MockCardState state, {
    bool pro = false,
    bool paused = false,
    VoidCallback? action,
  }) =>
      MockCard(
        model: MockCardModel(
          state: state,
          name: 'UPCAT simulation',
          durationMinutes: 165,
          pro: pro,
          proPaused: paused,
          lastPercent: 69,
          lastAttemptAt: DateTime(2026, 9, 26),
          nextOpensAt: DateTime(2026, 10, 10),
          customQuestions: 120,
        ),
        onTake: action ?? () {},
        onResume: action ?? () {},
        onViewResults: action ?? () {},
        onSetUp: action ?? () {},
        onChangeSetup: action ?? () {},
      );

  testWidgets('web card states the approved 30-day Free interval',
      (tester) async {
    await expectSurvivesTextScale(
      tester,
      const MockCard(
        model: MockCardModel(
          state: MockCardState.neverTaken,
          name: 'CSE Professional simulation',
          freeIntervalDays: 30,
        ),
      ),
      viewportSize: const Size(390, 844),
      disableAnimations: true,
    );
    expect(find.textContaining('one mock every 30 days'), findsOneWidget);
    expect(find.textContaining('14 days'), findsNothing);
  });

  Future<void> pumpTitle(
    WidgetTester tester, {
    required double width,
    required double cardWidth,
    required bool wide,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    debugWebPlatformOverride = wide;
    addTearDown(() => debugWebPlatformOverride = null);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(web: wide),
        home: MediaQuery(
          data: MediaQueryData(size: Size(width, 900), disableAnimations: true),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: cardWidth,
                  child: const MockCard(
                    model: MockCardModel(
                      state: MockCardState.neverTaken,
                      name: 'Mock simulation',
                      durationMinutes: 190,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // The test font is as wide as it is tall, so the name here is short enough
  // to fit alone and long enough that the length does not fit beside it in a
  // narrow card.
  group('the name keeps one line (2E-8)', () {
    for (final (width, cardWidth, wide, beside) in [
      (1280.0, 520.0, true, false),
      (1280.0, 700.0, true, true),
      (390.0, 358.0, false, false),
      (800.0, 640.0, false, true),
    ]) {
      testWidgets(
        'at $width px, card $cardWidth px wide: '
        '${beside ? 'length beside' : 'length under'}',
        (tester) async {
          await pumpTitle(
            tester,
            width: width,
            cardWidth: cardWidth,
            wide: wide,
          );
          final name = find.text('Mock simulation');
          final style = tester.widget<Text>(name).style!;
          // One line: no taller than a single line of its own font.
          expect(
            tester.getSize(name).height,
            lessThan(style.fontSize! * 1.6),
          );
          final length = find.text('3 hr 10 min');
          expect(length, findsOneWidget);
          final nameTop = tester.getTopLeft(name).dy;
          final lengthTop = tester.getTopLeft(length).dy;
          if (beside) {
            expect(lengthTop - nameTop, lessThan(style.fontSize!));
          } else {
            expect(
              lengthTop,
              greaterThanOrEqualTo(tester.getBottomLeft(name).dy),
            );
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  });

  for (final brightness in Brightness.values) {
    for (final state in MockCardState.values) {
      testWidgets('$brightness $state matches copy and survives 200%',
          (tester) async {
        final widget = SingleChildScrollView(
          child: Padding(padding: const EdgeInsets.all(16), child: card(state)),
        );
        await expectSurvivesTextScale(
          tester,
          widget,
          viewportSize: const Size(390, 844),
          brightness: brightness,
          disableAnimations: true,
        );
        expect(find.text('MOCK EXAM'), findsOneWidget);
        final expected = switch (state) {
          MockCardState.neverTaken => 'Take the Exam',
          MockCardState.ready => 'Take the Exam',
          MockCardState.waiting => 'View Last Results',
          MockCardState.inProgress => 'Resume',
          MockCardState.quizPaused => 'Finish your quiz session first.',
          MockCardState.customUnset => 'Set one up',
          MockCardState.customReady => 'Change the setup',
          MockCardState.unavailable => 'This exam has no mock paper ready yet.',
        };
        expect(find.text(expected), findsOneWidget);
        if (state == MockCardState.quizPaused ||
            state == MockCardState.unavailable) {
          expect(find.byType(PantasButton), findsNothing);
        }
      });
    }
    testWidgets('$brightness drawn metrics and real contrast', (tester) async {
      await pumpAccessibilitySurface(
        tester,
        SizedBox(width: 358, child: card(MockCardState.waiting)),
        brightness: brightness,
        viewportSize: const Size(390, 844),
        disableAnimations: true,
      );
      final title = tester.widget<Text>(find.text('UPCAT simulation'));
      expect(title.style!.fontSize, 20);
      expect(title.style!.fontWeight, FontWeight.w700);
      expect(title.style!.height, 1.35);
      expect(title.style!.letterSpacing, -.24);
      final score = tester.widget<Text>(find.text('69'));
      expect(score.style!.fontSize, 28);
      expect(score.style!.fontWeight, FontWeight.w700);
      // The system's phone title 1: 28/700, line 1.2, tracking -0.616.
      expect(score.style!.height, 1.2);
      expect(score.style!.letterSpacing, -.616);
      final button = find.byType(TextButton);
      expect(tester.getSize(button).height, 48);
      expect(tester.getSize(button).width, 326);
      final top = tester.getTopLeft(find.text('UPCAT simulation'));
      final surface = find.byKey(const ValueKey('grouped-section-surface'));
      expect(top.dx - tester.getTopLeft(surface).dx, 16);
      expect(top.dy - tester.getTopLeft(surface).dy, 16);
      final rule = tester.widget<Text>(find.textContaining('Free includes'));
      expect(rule.style!.fontSize, 13);
      expect(rule.style!.height, 1.4);
      expect(
        find.text('Free includes one mock every 14 days. '
            'Your next one opens Sat, Oct 10.'),
        findsOneWidget,
      );
      await expectMeetsAccessibilityGuidelines(tester);
    });
  }

  testWidgets('Pro and paused coverage announce the actual state',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpAccessibilitySurface(
      tester,
      card(MockCardState.ready, pro: true),
      disableAnimations: true,
    );
    expect(
      find.text("You're on Pro. Take as many mocks as you like."),
      findsOneWidget,
    );
    await pumpAccessibilitySurface(
      tester,
      card(MockCardState.ready, paused: true),
      disableAnimations: true,
    );
    expect(find.text('Connect once to keep using Pro.'), findsOneWidget);
    expect(find.textContaining("You're on Pro"), findsNothing);
    expect(
      tester
          .getSemantics(find.byKey(const ValueKey('mock-card-state')))
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('each action activates from the keyboard', (tester) async {
    for (final state in [
      MockCardState.neverTaken,
      MockCardState.waiting,
      MockCardState.inProgress,
      MockCardState.customUnset,
      MockCardState.customReady,
    ]) {
      var calls = 0;
      await pumpAccessibilitySurface(
        tester,
        card(state, action: () => calls++),
        disableAnimations: true,
      );
      final buttons =
          tester.widgetList<TextButton>(find.byType(TextButton)).toList();
      for (var i = 0; i < buttons.length; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
      }
      expect(calls, buttons.length);
      await tester.pumpWidget(const SizedBox());
    }
  });

  // A mock taken just after midnight in the student's day is still the
  // previous day in UTC. The card must print the student's day. The instant
  // is chosen so the local date differs from the UTC date wherever the test
  // runs (it cannot differ where local time is UTC).
  for (final wide in [false, true]) {
    testWidgets(
        '${wide ? 'wide' : 'phone'}: Last attempt and the next date '
        'print the local day of a UTC time', (tester) async {
      final offset = DateTime(2026, 11, 5, 12).timeZoneOffset;
      final taken = (offset.isNegative
              ? DateTime(2026, 11, 5, 23, 30)
              : DateTime(2026, 11, 5, 0, 30))
          .toUtc();
      final next = taken.add(const Duration(days: 30));
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(wide ? 1440 : 390, 1400);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      debugWebPlatformOverride = wide;
      addTearDown(() => debugWebPlatformOverride = null);
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(web: wide),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(wide ? 1440 : 390, 1400),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: MockCard(
                  model: MockCardModel(
                    state: MockCardState.ready,
                    name: 'CSE simulation',
                    lastPercent: 69,
                    lastAttemptAt: taken,
                    nextOpensAt: next,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(taken.isUtc, isTrue);
      expect(
        find.text(PantasDates.short(taken.toLocal())),
        findsOneWidget,
      );
      expect(
        mockNextOpensLine(next),
        contains(PantasDates.withWeekday(next.toLocal())),
      );
      if (offset != Duration.zero) {
        expect(
          PantasDates.short(taken.toLocal()),
          isNot(PantasDates.short(taken)),
        );
      }
    });
  }

  testWidgets('entry matches board stops and intermediate curve',
      (tester) async {
    await pumpAccessibilitySurface(tester, card(MockCardState.ready));
    double opacity() => tester
        .widget<Opacity>(find.byKey(const ValueKey('mock-card-opacity')))
        .opacity;
    expect(opacity(), 0);
    await tester.pump(const Duration(milliseconds: 190));
    expect(opacity(), 0);
    await tester.pump(const Duration(milliseconds: 225));
    final progress = PantasCurves.house.transform(.5);
    expect(opacity(), closeTo(progress, .001));
    final transform =
        tester.widget<Transform>(find.byKey(const ValueKey('mock-card-rise')));
    expect(transform.transform.storage[13], closeTo(12 * (1 - progress), .001));
    await tester.pump(const Duration(milliseconds: 225));
    expect(opacity(), 1);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
