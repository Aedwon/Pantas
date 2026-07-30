import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/presentation/part_transition_page.dart';

void main() {
  Widget buildTransition({VoidCallback? onStartNext}) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: PartTransitionPage(
        closedPartName: 'Numerical Ability',
        closedPartMinutes: 30,
        answered: 28,
        total: 30,
        blank: 2,
        flagged: 3,
        nextPartName: 'Analytical Ability',
        nextPartQuestions: 30,
        nextPartMinutes: 35,
        closedPartNumber: 1,
        nextPartNumber: 2,
        onStartNext: onStartNext ?? () {},
      ),
    );
  }

  Future<void> pumpTransition(
    WidgetTester tester, {
    VoidCallback? onStartNext,
  }) async {
    await tester.pumpWidget(buildTransition(onStartNext: onStartNext));
  }

  testWidgets('the figure and its label share one line', (tester) async {
    await pumpTransition(tester);
    expect(find.text('28'), findsOneWidget);
    expect(find.text('of 30 answered'), findsOneWidget);
  });

  testWidgets('blank and flagged are one quiet line, not two rows',
      (tester) async {
    await pumpTransition(tester);
    expect(find.textContaining('2 left blank'), findsOneWidget);
    expect(find.textContaining('3 you flagged'), findsOneWidget);
  });

  testWidgets('it states the closure plainly', (tester) async {
    await pumpTransition(tester);
    expect(
      find.text('Part 1 is closed. You cannot go back to it.'),
      findsOneWidget,
    );
  });

  testWidgets('there is no clock, no bar, no back arrow', (tester) async {
    await pumpTransition(tester);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('nothing on it is a score', (tester) async {
    await pumpTransition(tester);
    for (final word in ['correct', 'wrong', 'score', '%']) {
      expect(find.textContaining(word), findsNothing, reason: word);
    }
  });

  testWidgets('the button starts the next part', (tester) async {
    var started = 0;
    await pumpTransition(tester, onStartNext: () => started++);
    await tester.tap(find.text('Start Part 2'));
    await tester.pump();
    expect(started, 1);
  });
}
