import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/mock_exam/presentation/widgets/value_wheel_sheet.dart';

void main() {
  Widget harness(
    void Function(BuildContext) onTap, {
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return MaterialApp(
      theme: buildLightTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
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
          semanticLabel: 'Time wheel',
          format: formatDuration,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ValueWheel), findsOneWidget);
    expect(find.text('2h 00m'), findsOneWidget);
  });

  testWidgets('the wheel exposes its purpose, value, and adjustment actions',
      (tester) async {
    await tester.pumpWidget(
      harness(
        (context) => showValueWheelSheet(
          context: context,
          title: 'How long is it?',
          values: minuteValues,
          initial: 120,
          semanticLabel: 'Time wheel',
          format: formatDuration,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final wheel = tester.getSemantics(find.bySemanticsLabel('Time wheel'));
    expect(wheel.value, '2h 00m');
    expect(
      wheel.getSemanticsData().hasAction(SemanticsAction.increase),
      isTrue,
    );
    expect(
      wheel.getSemanticsData().hasAction(SemanticsAction.decrease),
      isTrue,
    );
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

  testWidgets('two columns fit at 320 and 360dp with 200 percent text',
      (tester) async {
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in [320.0, 360.0]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      tester.view.physicalSize = Size(width * 2, 1136);
      await tester.pumpWidget(
        harness(
          (context) => showTwoColumnWheelSheet(
            context: context,
            title: 'Mathematics',
            initialQuestions: 60,
            initialMinutes: 45,
          ),
          textScaler: const TextScaler.linear(2),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '$width dp');
      expect(find.bySemanticsLabel('Questions wheel'), findsOneWidget);
      expect(find.bySemanticsLabel('Minutes wheel'), findsOneWidget);
      final done = find.bySemanticsLabel('Done');
      expect(tester.getSize(done).height, greaterThanOrEqualTo(48));
    }
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
          semanticLabel: 'Questions wheel',
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
              semanticLabel: 'Questions wheel',
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
