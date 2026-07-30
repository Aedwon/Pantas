import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/tendencies_provider.dart';
import 'package:pantas/features/home/presentation/widgets/tendencies_panel.dart';
import 'package:pantas/features/home/presentation/widgets/tendency_card.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fourCards = [
    TendencyCard(
      kind: TendencyKind.underPressure,
      heading: 'Under pressure',
      leftLabel: 'practising',
      rightLabel: 'under time',
      figures: (left: '68%', right: '54%'),
      sentence: 'Accuracy drops 14% under exam pressure.',
      unlockAction: 'Finish one full length mock',
      pointsAtStake: 0.14,
    ),
    TendencyCard(
      kind: TendencyKind.stamina,
      heading: 'Stamina',
      leftLabel: 'first half',
      rightLabel: 'second half',
      figures: (left: '80%', right: '60%'),
      sentence: 'Accuracy drops 20% in the second half of a mock.',
      unlockAction: 'Finish one full length mock',
      pointsAtStake: 0.20,
    ),
    TendencyCard(
      kind: TendencyKind.howYouStudy,
      heading: 'How you study',
      leftLabel: 'read first',
      rightLabel: 'answered first',
      figures: (left: '12', right: '4'),
      sentence: 'You usually read the lesson first.',
      unlockAction: 'Read lessons or attempt topics',
      pointsAtStake: 0,
    ),
    TendencyCard(
      kind: TendencyKind.howYouAnswer,
      heading: 'How you answer',
      leftLabel: 'when correct',
      rightLabel: 'when wrong',
      figures: (left: '5s', right: '12s'),
      sentence: 'You spend 7s longer on questions you get wrong.',
      unlockAction: 'Answer more questions',
      pointsAtStake: 7,
    ),
  ];

  const twoMeasurableTwoBlocked = [
    TendencyCard(
      kind: TendencyKind.howYouStudy,
      heading: 'How you study',
      leftLabel: 'read first',
      rightLabel: 'answered first',
      figures: (left: '12', right: '4'),
      sentence: 'You usually read the lesson first.',
      unlockAction: 'Read lessons or attempt topics',
      pointsAtStake: 0,
    ),
    TendencyCard(
      kind: TendencyKind.howYouAnswer,
      heading: 'How you answer',
      leftLabel: 'when correct',
      rightLabel: 'when wrong',
      figures: (left: '5s', right: '12s'),
      sentence: 'You spend 7s longer on questions you get wrong.',
      unlockAction: 'Answer more questions',
      pointsAtStake: 7,
    ),
    TendencyCard(
      kind: TendencyKind.underPressure,
      heading: 'Under pressure',
      leftLabel: 'practising',
      rightLabel: 'under time',
      figures: null,
      sentence: null,
      unlockAction: 'Finish one full length mock',
      pointsAtStake: -1,
    ),
    TendencyCard(
      kind: TendencyKind.stamina,
      heading: 'Stamina',
      leftLabel: 'first half',
      rightLabel: 'second half',
      figures: null,
      sentence: null,
      unlockAction: 'Finish one full length mock',
      pointsAtStake: -1,
    ),
  ];

  Widget harness({required List<TendencyCard> cards, required bool isPro}) {
    final entitlement = isPro
        ? const Entitlement(plan: EntitlementPlan.monthly)
        : const Entitlement.free();

    return ProviderScope(
      overrides: [
        tendenciesProvider.overrideWith((ref) => cards),
        entitlementProvider.overrideWith((ref) => Stream.value(entitlement)),
      ],
      child: MaterialApp(
        theme: buildLightTheme(),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: TendenciesPanel(),
            ),
          ),
        ),
      ),
    );
  }

  String currentCardHeading(WidgetTester tester) {
    final cardView = tester.widget<TendencyCardView>(
      find.byType(TendencyCardView).first,
    );
    return cardView.card.heading;
  }

  testWidgets('swipes through four cards and never changes height',
      (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: true));
    await tester.pumpAndSettle();

    final before = tester.getSize(find.byType(TendenciesPanel));
    for (var i = 0; i < 3; i++) {
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(TendenciesPanel)), before);
    }
  });

  testWidgets('nothing advances on its own', (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: true));
    await tester.pumpAndSettle();
    final first = currentCardHeading(tester);

    await tester.pump(const Duration(seconds: 12));
    expect(currentCardHeading(tester), first);
  });

  testWidgets('hollow dots mark cards with no figures, on both tiers',
      (tester) async {
    for (final isPro in [true, false]) {
      await tester.pumpWidget(
        harness(cards: twoMeasurableTwoBlocked, isPro: isPro),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('tendency-dot-hollow')),
        findsNWidgets(2),
      );
    }
  });

  testWidgets('Free gets Unlock with Pro in board, in the header',
      (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: false));
    await tester.pumpAndSettle();

    final action = tester.widget<Text>(find.text('Unlock with Pro'));
    expect(action.style?.color, AppColors.light.board);
    expect(find.text('See full details'), findsNothing);
  });

  testWidgets('Pro gets See full details and no teaser at all', (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: true));
    await tester.pumpAndSettle();

    expect(find.text('See full details'), findsOneWidget);
    expect(find.text('Unlock with Pro'), findsNothing);
  });

  testWidgets('exactly one teaser on the panel', (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: false));
    await tester.pumpAndSettle();
    expect(find.text('Unlock with Pro'), findsOneWidget);
  });

  testWidgets('the panel is titled Your tendencies and never says readiness',
      (tester) async {
    await tester.pumpWidget(harness(cards: fourCards, isPro: true));
    await tester.pumpAndSettle();
    expect(find.text('Your tendencies'), findsOneWidget);
    expect(find.textContaining('readiness'), findsNothing);
    expect(find.textContaining('Readiness'), findsNothing);
  });
}
