import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/home/presentation/tendencies_page.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';

void main() {
  const work = HowYouWork(
    name: 'Ana',
    archetype: 'Deep Thinker',
    archetypeLine: 'You take your sweet time, and it shows.',
    whenYouWork: [],
    tendencies: [
      Tendency(
        id: TendencyId.underPressure,
        heading: 'Under pressure',
        leftLabel: 'practicing',
        rightLabel: 'under time',
        gap: '10',
        leftFigure: '80%',
        rightFigure: '70%',
        sentence: null,
        isLoss: true,
        unlockAction: 'Finish one full length mock',
        confidence: TendencyConfidence.forming,
      ),
    ],
  );
  testWidgets('clear pressure and stamina show their measured axes',
      (tester) async {
    const data = HowYouWork(
      name: 'Ana',
      archetype: null,
      archetypeLine: null,
      whenYouWork: [],
      tendencies: [
        Tendency(
          id: TendencyId.underPressure,
          heading: 'Under pressure',
          leftLabel: 'practicing',
          rightLabel: 'under time',
          gap: '10',
          leftFigure: '80%',
          rightFigure: '70%',
          sentence: 'Your accuracy drops under exam pressure.',
          isLoss: true,
          unlockAction: '',
          confidence: TendencyConfidence.clear,
        ),
        Tendency(
          id: TendencyId.stamina,
          heading: 'Stamina',
          leftLabel: 'first half',
          rightLabel: 'second half',
          gap: '10',
          leftFigure: '80%',
          rightFigure: '70%',
          sentence: 'Your accuracy drops in the second half of a mock.',
          isLoss: true,
          unlockAction: '',
          confidence: TendencyConfidence.clear,
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: TendenciesPage(
            data: data,
            pro: true,
            paused: false,
            onBack: () {},
            onName: () {},
            onPro: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('40%'), findsNWidgets(2));
    expect(find.text('Accuracy in your mocks'), findsOneWidget);
    expect(find.text('80%'), findsWidgets);
    await tester.scrollUntilVisible(find.text('1H'), 150);
    expect(find.text('2H'), findsOneWidget);
  });
  testWidgets('profile reserves the same space for long and short identities',
      (tester) async {
    Future<double> height(String label, String line) async {
      final data = HowYouWork(
        name: 'Ana',
        archetype: label,
        archetypeLine: line,
        whenYouWork: const [],
        tendencies: const [],
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: TendenciesPage(
            data: data,
            pro: true,
            paused: false,
            onBack: () {},
            onName: () {},
            onPro: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester
          .getSize(find.byKey(const ValueKey('tendencies-profile')))
          .height;
    }

    expect(
      await height(
        'Thorough Reviewer',
        'You never leave a question unchecked.',
      ),
      await height('Closer', 'You save your best for last.'),
    );
  });
  for (final pro in [false, true]) {
    testWidgets('tendencies $pro hides forming figures at large text',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildDarkTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: TendenciesPage(
              data: work,
              pro: pro,
              paused: false,
              onBack: () {},
              onName: () {},
              onPro: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Deep Thinker'), findsOneWidget);
      expect(find.text('80%'), findsNothing);
      expect(find.text('70%'), findsNothing);
      expect(find.text('When you work'), findsNothing);
      if (pro) expect(find.text('No clear difference so far.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
