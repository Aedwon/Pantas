import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/widgets/value_wheel_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget harness(void Function(BuildContext) onTap) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => onTap(context),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }

  test('the questions wheel steps in fives', () {
    expect(questionValues.first, 10);
    expect(questionValues, isNot(contains(117)));
    expect(questionValues.last, 240);
  });

  test('time renders as hours and minutes', () {
    expect(formatDuration(120), '2h 00m');
    expect(formatDuration(15), '0h 15m');
    expect(formatDuration(360), '6h 00m');
  });

  test('the time wheel runs from a quarter hour to six', () {
    expect(minuteValues.first, 15);
    expect(minuteValues.last, 360);
  });

  testWidgets('the time sheet is one column', (tester) async {
    await tester.pumpWidget(
      harness(
        (context) => showValueWheelSheet(
          context: context,
          title: 'How long is it?',
          values: minuteValues,
          initial: 120,
          format: formatDuration,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ValueWheel), findsOneWidget);
    expect(find.text('2h 00m'), findsOneWidget);
  });

  testWidgets('the section sheet labels its two columns', (tester) async {
    await tester.pumpWidget(
      harness(
        (context) => showTwoColumnWheelSheet(
          context: context,
          title: 'This part',
          initialQuestions: 60,
          initialMinutes: 45,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Questions'), findsOneWidget);
    expect(find.text('Minutes'), findsOneWidget);
    expect(find.byType(ValueWheel), findsNWidgets(2));
  });

  testWidgets('Done returns the value under the band', (tester) async {
    int? chosen;
    await tester.pumpWidget(
      harness(
        (context) async => chosen = await showValueWheelSheet(
          context: context,
          title: 'How many questions?',
          values: questionValues,
          initial: 60,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(chosen, 60);
  });

  testWidgets('dismissing returns nothing and changes no value',
      (tester) async {
    var returned = -1;
    await tester.pumpWidget(
      harness(
        (context) async => returned = await showValueWheelSheet(
              context: context,
              title: 'How many questions?',
              values: questionValues,
              initial: 60,
            ) ??
            -1,
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(returned, -1);
  });
}
