import 'package:cse_cet_reviewer/core/ui/components/inline_meter.dart';
import 'package:cse_cet_reviewer/core/ui/components/progress_rule.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) => MaterialApp(
      theme: buildLightTheme(),
      home: Scaffold(body: Center(child: SizedBox(width: 200, child: child))),
    );

void main() {
  testWidgets('ProgressRule fills proportionally in board green',
      (tester) async {
    await tester.pumpWidget(harness(const ProgressRule(value: 0.5)));
    final fill =
        tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(fill.widthFactor, 0.5);
    final colored = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .whereType<Color>()
        .toList();
    expect(colored, contains(AppColors.light.board));
  });

  testWidgets('ProgressRule clamps out-of-range values', (tester) async {
    await tester.pumpWidget(harness(const ProgressRule(value: 1.7)));
    final fill =
        tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
    expect(fill.widthFactor, 1.0);
  });

  testWidgets('InlineMeter uses the caller color', (tester) async {
    await tester.pumpWidget(
      harness(InlineMeter(value: 0.38, color: AppColors.light.rust)),
    );
    final colored = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => (c.decoration as BoxDecoration?)?.color)
        .whereType<Color>()
        .toList();
    expect(colored, contains(AppColors.light.rust));
  });
}
