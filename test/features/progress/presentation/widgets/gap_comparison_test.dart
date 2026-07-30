import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/progress/application/how_you_work_provider.dart';
import 'package:pantas/features/progress/presentation/widgets/gap_comparison.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const lossOf14 = Tendency(
    id: TendencyId.underPressure,
    heading: 'Under pressure',
    leftLabel: 'practising',
    rightLabel: 'under time',
    gap: '14',
    leftFigure: '68%',
    rightFigure: '54%',
    sentence: 'Accuracy drops 14% under exam pressure.',
    isLoss: true,
    unlockAction: 'Finish one full length mock',
  );

  const gainOf9 = Tendency(
    id: TendencyId.stamina,
    heading: 'Stamina',
    leftLabel: 'first half',
    rightLabel: 'second half',
    gap: '9',
    leftFigure: '58%',
    rightFigure: '67%',
    sentence: 'Accuracy rises 9% in the second half of a mock.',
    isLoss: false,
    unlockAction: 'Finish one full length mock',
  );

  const blocked = Tendency(
    id: TendencyId.stamina,
    heading: 'Stamina',
    leftLabel: 'first half',
    rightLabel: 'second half',
    gap: null,
    leftFigure: null,
    rightFigure: null,
    sentence: null,
    isLoss: false,
    unlockAction: 'Finish one full length mock',
  );

  Widget harness({required Tendency tendency, required bool isPro}) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: GapComparison(
          tendency: tendency,
          isPro: isPro,
        ),
      ),
    );
  }

  testWidgets('the gap leads at 34/700 serif', (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: true));
    final gap = tester.widget<Text>(find.text('14'));
    expect(gap.style?.fontSize, 34);
    expect(gap.style?.fontWeight, FontWeight.w700);
    expect(gap.style?.fontFamily, 'SourceSans3');
  });

  testWidgets('a loss is rust and a gain is ink', (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: true));
    expect(
      tester.widget<Text>(find.text('14')).style?.color,
      AppColors.light.rust,
    );

    await tester.pumpWidget(harness(tendency: gainOf9, isPro: true));
    expect(
      tester.widget<Text>(find.text('9')).style?.color,
      AppColors.light.ink,
    );
  });

  testWidgets('board green is never spent here', (tester) async {
    await tester.pumpWidget(harness(tendency: gainOf9, isPro: true));
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(t.style?.color, isNot(AppColors.light.board));
    }
  });

  testWidgets('the source figures are demoted to 11.5', (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: true));
    expect(
      tester.widget<Text>(find.textContaining('68%')).style?.fontSize,
      11.5,
    );
  });

  testWidgets('no hairline joins the two figures', (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: true));
    expect(find.byKey(const ValueKey('figure-divider')), findsNothing);
  });

  testWidgets('Free sees both labels and bars where the figures go',
      (tester) async {
    await tester.pumpWidget(harness(tendency: lossOf14, isPro: false));

    expect(find.text('practising'), findsOneWidget);
    expect(find.text('under time'), findsOneWidget);
    expect(find.text('14'), findsNothing);
    expect(find.byType(FaintBars), findsWidgets);
  });

  testWidgets('an unmet prerequisite is muted, never board', (tester) async {
    await tester.pumpWidget(harness(tendency: blocked, isPro: true));

    expect(find.text('Not enough data yet'), findsOneWidget);
    expect(find.text('Finish one full length mock'), findsOneWidget);
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(t.style?.color, isNot(AppColors.light.board));
    }
  });
}
