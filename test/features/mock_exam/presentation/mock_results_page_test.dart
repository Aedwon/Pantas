import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'free results show score sections weak topics and pro review card',
    (tester) async {
      await tester.pumpApp(
        MockResultsPage(results: _results(), proIsActive: false),
      );

      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('Part 1'), findsOneWidget);
      expect(find.text('Practice these next'), findsOneWidget);
      expect(
        find.text('This is what Pro shows after every mock.'),
        findsOneWidget,
      );
      expect(find.text('Try Pro free'), findsOneWidget);
    },
  );

  testWidgets('pro results show per-question review section', (tester) async {
    await tester.pumpApp(
      MockResultsPage(results: _results(), proIsActive: true),
    );

    expect(find.text('Answer review'), findsOneWidget);
  });

  testWidgets('forfeited attempts show forfeit header', (tester) async {
    await tester.pumpApp(
      MockResultsPage(
        results: _results(),
        proIsActive: false,
        forfeited: true,
      ),
    );

    expect(find.text('Forfeited during strict mode'), findsOneWidget);
  });

  testWidgets('weak topic practice button exposes drill route', (tester) async {
    await tester.pumpApp(
      MockResultsPage(results: _results(), proIsActive: false),
    );

    expect(find.text('/quiz/drill?topicId=topic_a'), findsOneWidget);
  });
}

MockResults _results() {
  return const MockResults(
    scoreRaw: 1,
    scoreTotal: 2,
    percent: 50,
    band: ScoreBand.fail,
    sections: [
      SectionResult(
        sectionId: 's1',
        name: 'Part 1',
        correct: 1,
        total: 2,
        retiredCount: 0,
        timeSeconds: 60,
      ),
    ],
    topWeak: [
      WeakTopic(topicId: 'topic_a', correct: 0, total: 2),
    ],
    totalTimeSeconds: 120,
    wasStrict: false,
  );
}
