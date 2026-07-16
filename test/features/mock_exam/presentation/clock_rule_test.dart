import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/mock_exam/presentation/clock_rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp({required Duration remaining, required Duration partLength}) {
    return MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(
        appBar: AppBar(
          bottom: ClockRule(
            remaining: remaining,
            partLength: partLength,
          ),
        ),
      ),
    );
  }

  Future<void> pumpRule(
    WidgetTester tester, {
    required Duration remaining,
    required Duration partLength,
  }) async {
    await tester.pumpWidget(
      buildApp(remaining: remaining, partLength: partLength),
    );
  }

  Color amberOf(WidgetTester tester) {
    final context = tester.element(find.byType(ClockRule));
    return context.colors.amber;
  }

  testWidgets('the rule retreats as time runs out', (tester) async {
    await pumpRule(
      tester,
      remaining: const Duration(minutes: 15),
      partLength: const Duration(minutes: 30),
    );
    final half = tester.widget<FractionallySizedBox>(
      find.byKey(const Key('clock-rule-fill')),
    );
    expect(half.widthFactor, closeTo(0.5, 0.001));
  });

  testWidgets('ample time draws a soft hairline', (tester) async {
    await pumpRule(
      tester,
      remaining: const Duration(minutes: 20),
      partLength: const Duration(minutes: 30),
    );
    final box =
        tester.widget<Container>(find.byKey(const Key('clock-rule-bar')));
    final decoration = box.decoration! as BoxDecoration;
    expect(box.constraints?.maxHeight ?? 1, 1);
    expect(decoration.color!.a, lessThan(1.0));
  });

  testWidgets('under five minutes the rule thickens and goes full strength',
      (tester) async {
    await pumpRule(
      tester,
      remaining: const Duration(minutes: 4),
      partLength: const Duration(minutes: 30),
    );
    final box =
        tester.widget<Container>(find.byKey(const Key('clock-rule-bar')));
    expect(box.constraints?.maxHeight, 1.6);
  });

  testWidgets('under one minute the rule and the clock turn amber',
      (tester) async {
    await pumpRule(
      tester,
      remaining: const Duration(seconds: 45),
      partLength: const Duration(minutes: 30),
    );
    final box =
        tester.widget<Container>(find.byKey(const Key('clock-rule-bar')));
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, amberOf(tester));
  });
}
