import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/widgets/exam_marks_offer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness({
  required int count,
  VoidCallback? onKeepAll,
  VoidCallback? onDismiss,
}) {
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ExamMarksOffer(
        count: count,
        onKeepAll: onKeepAll ?? () {},
        onDismiss: onDismiss ?? () {},
      ),
    ),
  );
}

void main() {
  testWidgets('offers the exact count', (tester) async {
    await tester.pumpWidget(harness(count: 12));
    expect(
      find.textContaining(
        'You marked 12 to come back to while the clock was running.',
      ),
      findsOneWidget,
    );
    expect(find.text('Flag all 12'), findsOneWidget);
    expect(find.text('No thanks'), findsOneWidget);
  });

  testWidgets('one mark reads "1", singular throughout', (tester) async {
    await tester.pumpWidget(harness(count: 1));
    expect(find.text('Flag all 1'), findsOneWidget);
  });

  testWidgets('no marks renders nothing', (tester) async {
    await tester.pumpWidget(harness(count: 0));
    expect(find.byWidgetPredicate((w) => w is ExamMarksOffer && w.count > 0), findsNothing);
    expect(find.textContaining('You marked'), findsNothing);
  });

  testWidgets('taking it calls onKeepAll', (tester) async {
    var kept = false;
    await tester.pumpWidget(harness(count: 12, onKeepAll: () => kept = true));
    await tester.tap(find.text('Flag all 12'));
    expect(kept, isTrue);
  });

  testWidgets('dismissing it calls onDismiss', (tester) async {
    var dismissed = false;
    await tester.pumpWidget(harness(count: 12, onDismiss: () => dismissed = true));
    await tester.tap(find.text('No thanks'));
    expect(dismissed, isTrue);
  });
}
