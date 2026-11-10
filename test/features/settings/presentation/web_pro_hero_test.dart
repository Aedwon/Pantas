import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/features/settings/presentation/widgets/web_pro_hero.dart';

// Aedwon, staging check: "in desktop view the icons are just checks instead of
// the custom ones per line (as seen in mobile)".
void main() {
  final icons = [
    PantasIcons.unlimitedMocks,
    PantasIcons.answerNotes,
    PantasIcons.studyHabits,
    PantasIcons.proBackup,
    PantasIcons.topicResults,
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
