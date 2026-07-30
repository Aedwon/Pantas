import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/tendencies_provider.dart';
import 'package:pantas/features/home/presentation/widgets/tendency_card.dart';

void main() {
  const withFigures = TendencyCard(
    kind: TendencyKind.underPressure,
    heading: 'Under pressure',
    leftLabel: 'practising',
    rightLabel: 'under time',
    figures: (left: '68%', right: '54%'),
    sentence: 'Accuracy drops 14% under exam pressure.',
    unlockAction: 'Finish one full length mock',
    pointsAtStake: 0.14,
  );

  const blocked = TendencyCard(
    kind: TendencyKind.stamina,
    heading: 'Stamina',
    leftLabel: 'first half',
    rightLabel: 'second half',
    figures: null,
    sentence: null,
    unlockAction: 'Finish one full length mock',
    pointsAtStake: -1,
  );

  const readsFirst = TendencyCard(
    kind: TendencyKind.howYouStudy,
    heading: 'How you study',
    leftLabel: 'read first',
    rightLabel: 'answered first',
    figures: (left: '12', right: '4'),
    sentence: 'You usually read the lesson first.',
    unlockAction: 'Read lessons or attempt topics',
    pointsAtStake: 0,
  );

  const answersFirst = TendencyCard(
    kind: TendencyKind.howYouStudy,
    heading: 'How you study',
    leftLabel: 'read first',
    rightLabel: 'answered first',
    figures: (left: '4', right: '12'),
    sentence: 'You usually go straight to the questions.',
    unlockAction: 'Read lessons or attempt topics',
    pointsAtStake: 0,
  );

  const evenSplit = TendencyCard(
    kind: TendencyKind.howYouStudy,
    heading: 'How you study',
    leftLabel: 'read first',
    rightLabel: 'answered first',
    figures: (left: '8', right: '8'),
    sentence: 'You split about evenly between the two.',
    unlockAction: 'Read lessons or attempt topics',
    pointsAtStake: 0,
  );

  Widget harness(Widget child) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: child,
          ),
        ),
      ),
    );
  }

  testWidgets('every rendering is exactly 112 tall', (tester) async {
    for (final card in [withFigures, blocked]) {
      for (final isPro in [true, false]) {
        await tester.pumpWidget(
          harness(TendencyCardView(card: card, isPro: isPro)),
        );
        expect(
          tester.getSize(find.byType(TendencyCardView)).height,
          112,
          reason: 'nothing may jump mid-swipe',
        );
      }
    }
  });

  testWidgets('Pro with figures shows both figures and the sentence',
      (tester) async {
    await tester.pumpWidget(
      harness(const TendencyCardView(card: withFigures, isPro: true)),
    );
    expect(find.text('68%'), findsOneWidget);
    expect(find.text('54%'), findsOneWidget);
    expect(find.byType(FaintBars), findsNothing);
  });

  testWidgets('Pro without figures shows the unlock action, muted not board',
      (tester) async {
    await tester.pumpWidget(
      harness(const TendencyCardView(card: blocked, isPro: true)),
    );
    expect(find.text('Not enough data yet'), findsOneWidget);
    expect(find.text('Finish one full length mock'), findsOneWidget);

    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      expect(text.style?.color, isNot(AppColors.light.board));
    }
  });

  testWidgets('Free sees both labels and bars where the figures go',
      (tester) async {
    await tester.pumpWidget(
      harness(const TendencyCardView(card: withFigures, isPro: false)),
    );
    expect(find.text('practising'), findsOneWidget);
    expect(find.text('under time'), findsOneWidget);
    expect(find.text('68%'), findsNothing);
    expect(find.byType(FaintBars), findsWidgets);
  });

  testWidgets('no lock icon, no blur, anywhere', (tester) async {
    await tester.pumpWidget(
      harness(const TendencyCardView(card: withFigures, isPro: false)),
    );
    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNothing);
    expect(find.byType(BackdropFilter), findsNothing);
  });

  testWidgets('how you study names the pattern and not its payoff',
      (tester) async {
    await tester.pumpWidget(
      harness(const TendencyCardView(card: readsFirst, isPro: true)),
    );

    expect(find.text('How you study'), findsOneWidget);
    expect(find.text('You usually read the lesson first.'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    for (final claim in ['works better', 'better for you', 'What works']) {
      expect(find.textContaining(claim), findsNothing);
    }
  });

  testWidgets('the three sentences are the whole vocabulary', (tester) async {
    for (final (card, sentence) in [
      (readsFirst, 'You usually read the lesson first.'),
      (answersFirst, 'You usually go straight to the questions.'),
      (evenSplit, 'You split about evenly between the two.'),
    ]) {
      await tester
          .pumpWidget(harness(TendencyCardView(card: card, isPro: true)));
      expect(find.text(sentence), findsOneWidget);
    }
  });
}
