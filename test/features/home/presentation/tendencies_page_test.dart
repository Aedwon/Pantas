import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/how_you_work_provider.dart';
import 'package:pantas/features/home/presentation/tendencies_page.dart';
import 'package:pantas/features/metrics/domain/tendency_confidence.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
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
  for (final reduced in [true, false]) {
    testWidgets('empty profile card says it needs data, reduced=$reduced',
        (tester) async {
      const data = HowYouWork(
        name: 'Aerol',
        archetype: null,
        archetypeLine: null,
        whenYouWork: [],
        tendencies: [],
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: buildLightTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(390, 844),
              disableAnimations: reduced,
            ),
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
      // Reduced motion stands still at once; otherwise the ghost mark is
      // still sliding in.
      final ghost = find.byKey(const ValueKey('tendencies-ghost'));
      final card = find.byKey(const ValueKey('tendencies-profile'));
      if (!reduced) {
        await tester.pump();
        final start = tester.getTopLeft(ghost).dx;
        await tester.pumpAndSettle();
        expect(start, greaterThan(tester.getTopLeft(ghost).dx));
      } else {
        await tester.pump();
      }
      final rect = tester.getRect(card);
      // 20 px padding, a 15 px name on a 20 px line, 6 px, then the 30 px
      // headline on 1.14.
      final name = tester.getRect(find.text('Aerol'));
      expect(name.left, rect.left + 20);
      expect(name.top, rect.top + 20);
      expect(name.height, 20);
      final headline = find.descendant(
        of: card,
        matching: find.text('Needs more usage data'),
      );
      final style = tester.widget<Text>(headline).style!;
      expect(style.fontSize, 30);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.letterSpacing, -.6);
      expect(style.height, 1.14);
      expect(style.color, Colors.white);
      expect(tester.getTopLeft(headline).dy, name.bottom + 6);
      // The headline wraps inside 270 px.
      expect(tester.getSize(headline).width, lessThanOrEqualTo(270));
      expect(tester.getSize(headline).height, closeTo(2 * 30 * 1.14, 0.5));
      // The card is at least 130 px tall, and not taller than its content.
      expect(rect.height, closeTo(20 + 20 + 6 + 2 * 30 * 1.14 + 20, 0.5));
      // The ghost mark: 150 px, 2 px from the right and 8 px above the top,
      // dim gray.
      final mark = tester.getRect(ghost);
      expect(mark.right, closeTo(rect.right - 2, 0.5));
      expect(mark.top, closeTo(rect.top - 8, 0.5));
      expect(mark.height, 150);
      final markStyle = tester.widget<Text>(ghost).style!;
      expect(markStyle.fontSize, 150);
      expect(markStyle.fontWeight, FontWeight.w400);
      expect(markStyle.color, const Color(0xff3a3a3d));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('a profile with an archetype has no question mark',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: TendenciesPage(
            data: work,
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
    expect(find.byKey(const ValueKey('tendencies-ghost')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('tendencies-profile')),
        matching: find.text('Needs more usage data'),
      ),
      findsNothing,
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
