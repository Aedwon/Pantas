import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders serif numerals with labels and dividers',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: StatsBand(
            figures: [
              StatFigure(value: '78%', label: 'Average score'),
              StatFigure(value: '41', suffix: '/96', label: 'Lessons done'),
            ],
          ),
        ),
      ),
    );
    final numeral = tester.widget<Text>(find.text('78%'));
    expect(numeral.style?.fontFamily, 'SourceSans3');
    expect(numeral.style?.fontSize, 30);
    expect(find.text('/96'), findsOneWidget);
    expect(find.text('Average score'), findsOneWidget);
    expect(find.text('Lessons done'), findsOneWidget);
    // one vertical divider between two figures
    expect(find.byKey(const ValueKey('stats-divider-0')), findsOneWidget);
  });

  testWidgets('StatsBand asserts on empty figures', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(body: StatsBand(figures: [])),
      ),
    );
    expect(tester.takeException(), isA<AssertionError>());
  });

  testWidgets('figures use tabular numerals', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: StatsBand(figures: [StatFigure(value: '11', label: 'points')]),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('11'));
    expect(
      text.style!.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });
}
