import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/features/settings/presentation/widgets/web_pro_hero.dart';

// Aedwon, staging check: "in desktop view the icons are just checks instead of
// the custom ones per line (as seen in mobile)".
const proLines = [
  'Full adaptive plan, tailored for you',
  'Unlimited mock exams',
  'Detailed explanations',
  'Concept-specific results',
  'Your tendencies as a test-taker',
];
const oldProLines = [
  'Notes on why your answer was wrong',
  'The figures behind your study habits',
  "Progress that's always backed up",
  'Results by topic and lesson',
];

void main() {
  final icons = [
    PantasIcons.calendarBlank,
    PantasIcons.unlimitedMocks,
    PantasIcons.answerNotes,
    PantasIcons.topicResults,
    PantasIcons.tendencies,
  ];

  Future<void> pump(
    WidgetTester tester, {
    required double width,
    required bool dark,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = Size(width, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? buildDarkTheme(web: true) : buildLightTheme(web: true),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 900),
            textScaler: TextScaler.linear(textScale),
          ),
          child: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(24),
              child: WebProHero(heading: 'Study without limits'),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the five benefit icons in order, no drawn tick', (
    tester,
  ) async {
    await pump(tester, width: 1440, dark: false);
    final hero = find.byKey(const ValueKey('pro-hero'));
    final iconFinder = find.descendant(of: hero, matching: find.byType(Icon));
    final found = tester.widgetList<Icon>(iconFinder).toList();
    expect(found.map((i) => i.icon), icons);
    for (final i in found) {
      expect(i.size, PantasSize.icon);
    }
    expect(
      find.descendant(of: hero, matching: find.byType(CustomPaint)),
      findsNothing,
    );
  });

  // Aedwon, Nov 26, after rewriting the website lists: "you can update the Pro
  // texts in other places as well".
  testWidgets('lists his five Pro lines in his order, and none of the old ones',
      (tester) async {
    await pump(tester, width: 1440, dark: false);
    final hero = find.byKey(const ValueKey('pro-hero'));
    final texts = tester
        .widgetList<Text>(
          find.descendant(of: hero, matching: find.byType(Text)),
        )
        .map((t) => t.data)
        .toList();
    expect(texts.where(proLines.contains).toList(), proLines);
    for (final old in oldProLines) {
      expect(texts, isNot(contains(old)), reason: old);
    }
  });

  // Aedwon, Nov 26: "can you make the web view ver as green as the mobile
  // view ver."
  for (final dark in [false, true]) {
    testWidgets('wide hero is the phone green, dark=$dark', (tester) async {
      await pump(tester, width: 1440, dark: dark);
      final heroFinder = find.byKey(const ValueKey('pro-hero'));
      final c = tester.element(heroFinder).colors;
      final box =
          tester.widget<Container>(heroFinder).decoration! as BoxDecoration;
      final gradient = box.gradient! as LinearGradient;
      expect(gradient.colors, [c.heroStart, c.heroMid, c.heroEnd]);
      expect(gradient.stops, const [0, .4, 1]);
      expect(gradient.begin, const Alignment(-0.342, -0.94));
      expect(gradient.end, const Alignment(0.342, 0.94));
      expect(
        tester
            .widget<Text>(
              find.descendant(
                of: heroFinder,
                matching: find.text('Study without limits'),
              ),
            )
            .style!
            .color,
        c.onHero,
      );
      for (final i in tester.widgetList<Icon>(
        find.descendant(of: heroFinder, matching: find.byType(Icon)),
      )) {
        expect(i.color, c.onHeroSecondary);
      }
    });
  }

  for (final width in [1024.0, 1440.0]) {
    for (final dark in [false, true]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('fits at $width dark=$dark scale=$scale', (tester) async {
          await pump(tester, width: width, dark: dark, textScale: scale);
          expect(tester.takeException(), isNull);
          expect(find.byType(Icon), findsNWidgets(5));
        });
      }
    }
  }
}
