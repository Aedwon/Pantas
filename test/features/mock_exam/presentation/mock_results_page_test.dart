import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/domain/mock_results.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/pages/mock_results_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget resultsHarness({
  int raw = 82,
  int total = 120,
  ScoreBand? band = ScoreBand.close,
  bool proIsActive = false,
  bool forfeited = false,
  String blueprintName = 'UPCAT full length',
  String dateFormatted = '2 August 2026',
}) {
  return MaterialApp(
    theme: buildLightTheme(),
    home: MockResultsPage(
      results: MockResults(
        scoreRaw: raw,
        scoreTotal: total,
        percent: total > 0 ? (raw / total * 100) : 0,
        band: band,
        sections: const [
          SectionResult(
            sectionId: 's1',
            name: 'Part 1',
            correct: 82,
            total: 120,
            retiredCount: 0,
            timeSeconds: 3600,
          ),
        ],
        topWeak: const [
          WeakTopic(topicId: 'topic_a', correct: 10, total: 30),
        ],
        totalTimeSeconds: 3600,
        wasStrict: false,
      ),
      proIsActive: proIsActive,
      blueprintName: blueprintName,
      dateFormatted: dateFormatted,
      forfeited: forfeited,
      disableAnimations: true,
    ),
  );
}

void main() {
  testWidgets('the header carries the name and the date, never a duration',
      (tester) async {
    await tester.pumpWidget(resultsHarness());
    await tester.pumpAndSettle();

    expect(find.text('UPCAT full length'), findsOneWidget);
    expect(find.text('2 August 2026'), findsOneWidget);
    expect(find.textContaining('3 hours'), findsNothing);
  });

  testWidgets('the review row stands alone with no heading above it',
      (tester) async {
    await tester.pumpWidget(resultsHarness());
    await tester.pumpAndSettle();

    expect(find.text('Go through all 120 questions'), findsOneWidget);
    expect(find.text('Review'), findsNothing);
  });

  testWidgets('Practice these next rows carry a chevron and no verb',
      (tester) async {
    await tester.pumpWidget(resultsHarness());
    await tester.pumpAndSettle();

    expect(find.text('Practice these next'), findsOneWidget);
    expect(find.textContaining('Practice these next'), findsOneWidget);
    expect(find.text('Practice'), findsNothing);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('the copy never says paper, sit, marks or borderline',
      (tester) async {
    await tester.pumpWidget(resultsHarness());
    await tester.pumpAndSettle();
    for (final word in ['paper', 'Borderline', 'borderline', 'marks', '—']) {
      expect(find.textContaining(word), findsNothing);
    }
  });
}
