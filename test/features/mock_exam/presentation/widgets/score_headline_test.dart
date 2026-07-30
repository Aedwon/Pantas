import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/score_headline.dart';

Widget harness({
  required int scoreRaw,
  required int scoreTotal,
  required ScoreBand? band,
  bool wasForfeited = false,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ScoreHeadline(
        scoreRaw: scoreRaw,
        scoreTotal: scoreTotal,
        band: band,
        wasForfeited: wasForfeited,
        disableAnimations: disableAnimations,
      ),
    ),
  );
}

void main() {
  testWidgets('prints the figure, the band and the raw score', (tester) async {
    await tester.pumpWidget(
      harness(scoreRaw: 82, scoreTotal: 120, band: ScoreBand.close),
    );
    await tester.pumpAndSettle();

    expect(find.text('68'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
    expect(find.text('Close to passing'), findsOneWidget);
    expect(find.text('82 of 120'), findsOneWidget);
  });

  testWidgets('an exam with no published thresholds prints no band',
      (tester) async {
    await tester.pumpWidget(
      harness(scoreRaw: 82, scoreTotal: 120, band: null),
    );
    await tester.pumpAndSettle();

    expect(find.text('68'), findsOneWidget);
    expect(find.textContaining('passing'), findsNothing);
    expect(find.textContaining('Passing'), findsNothing);
  });

  testWidgets('a forfeited exam shows the score and withholds the verdict',
      (tester) async {
    await tester.pumpWidget(
      harness(
        scoreRaw: 30,
        scoreTotal: 120,
        band: ScoreBand.fail,
        wasForfeited: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('30 of 120'), findsOneWidget);
    expect(find.textContaining('passing'), findsNothing);
  });

  testWidgets('reduce-motion lands on the figure immediately', (tester) async {
    await tester.pumpWidget(
      harness(
        scoreRaw: 82,
        scoreTotal: 120,
        band: ScoreBand.close,
        disableAnimations: true,
      ),
    );
    await tester.pump();
    expect(find.text('68'), findsOneWidget);
  });

  testWidgets('no gauge, no confetti, no emoji', (tester) async {
    await tester.pumpWidget(
      harness(scoreRaw: 110, scoreTotal: 120, band: ScoreBand.pass),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      expect(
        t.data ?? '',
        isNot(matches(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true))),
      );
    }
  });
}
