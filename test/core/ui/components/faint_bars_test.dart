import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/theme/app_colors.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('renders one faint bar per width factor', (tester) async {
    await tester.pumpWidget(
      harness(const FaintBars(widthFactors: [0.9, 0.5])),
    );
    expect(find.byType(FractionallySizedBox), findsNWidgets(2));
    final bar = tester.widget<Container>(find.byType(Container).first);
    final decoration = bar.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.light.ruleFaint);
  });

  testWidgets('status semantics are optional and can be a live region',
      (tester) async {
    await tester.pumpWidget(harness(const FaintBars()));
    expect(find.bySemanticsLabel('Loading questions'), findsNothing);

    await tester.pumpWidget(
      harness(
        const FaintBars(semanticsLabel: 'Loading questions', liveRegion: true),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Loading questions')),
      matchesSemantics(label: 'Loading questions', isLiveRegion: true),
    );
  });
}
