import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/presentation/widgets/home_exam_day.dart';

Widget harness({
  required int total,
  int done = 0,
  bool large = false,
  VoidCallback? onStart,
}) =>
    MaterialApp(
      theme: buildLightTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(large ? 2 : 1),
          disableAnimations: true,
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: HomeExamDay(
              examShortName: 'UPCAT',
              reviewsTotal: total,
              reviewsDone: done,
              onRow: () {},
              onStart: onStart ?? () {},
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows the actual count in the sentence and the row',
      (tester) async {
    await tester.pumpWidget(harness(total: 7));
    await tester.pumpAndSettle();
    expect(find.text('UPCAT is today.'), findsOneWidget);
    expect(
      find.text(
        'Nothing new today. If you want a warm-up, 7 easy reviews are here.',
      ),
      findsOneWidget,
    );
    expect(find.text('Warm-up reviews'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
    expect(find.text('0 of 7'), findsOneWidget);
    expect(find.text('Start Warm-up'), findsOneWidget);
    expect(find.textContaining('10'), findsNothing);
  });

  testWidgets('one review reads in the singular', (tester) async {
    await tester.pumpWidget(harness(total: 1));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Nothing new today. If you want a warm-up, 1 easy review is here.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('with no eligible reviews no warm-up row, button or count',
      (tester) async {
    await tester.pumpWidget(harness(total: 0));
    await tester.pumpAndSettle();
    expect(find.text('UPCAT is today.'), findsOneWidget);
    expect(find.text('Nothing new today.'), findsOneWidget);
    expect(find.text('Warm-up reviews'), findsNothing);
    expect(find.text('Start Warm-up'), findsNothing);
    expect(find.text('TODAY'), findsNothing);
  });

  testWidgets('start launches and large text does not overflow',
      (tester) async {
    var started = 0;
    await tester.pumpWidget(
      harness(total: 10, large: true, onStart: () => started++),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Warm-up'));
    expect(started, 1);
    expect(tester.takeException(), isNull);
  });
}
