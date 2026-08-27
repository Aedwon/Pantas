import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/domain/mock_results.dart';
import 'package:pantas/features/mock_exam/presentation/pages/mock_results_page.dart';

Widget resultsHarness({
  int raw = 82,
  int total = 120,
  ScoreBand? band = ScoreBand.close,
  bool proIsActive = false,
  bool forfeited = false,
  String blueprintName = 'UPCAT full length',
  String dateFormatted = '2 August 2026',
  String sectionName = 'Part 1',
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    theme: buildLightTheme(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: child!,
    ),
    home: MockResultsPage(
      results: MockResults(
        scoreRaw: raw,
        scoreTotal: total,
        percent: total > 0 ? (raw / total * 100) : 0,
        band: band,
        sections: [
          SectionResult(
            sectionId: 's1',
            name: sectionName,
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

  testWidgets('results fit 320 and 360dp at 200 percent text', (tester) async {
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in [320.0, 360.0]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      tester.view.physicalSize = Size(width * 2, 1136);
      await tester.pumpWidget(
        resultsHarness(
          blueprintName: 'UPCAT full length mock',
          sectionName: 'Numerical Ability',
          textScaler: const TextScaler.linear(2),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -420));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '$width dp');
      expect(find.text('Numerical Ability'), findsOneWidget);
      expect(find.text('60m'), findsOneWidget);
    }
  });
}
