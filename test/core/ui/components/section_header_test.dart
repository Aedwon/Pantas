import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget harness(Widget child) =>
    MaterialApp(theme: buildLightTheme(), home: Scaffold(body: child));

void main() {
  testWidgets('renders serif title and tappable action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      harness(
        SectionHeader(
          title: "Today's plan",
          action: '2 of 3 done',
          onAction: () => tapped = true,
        ),
      ),
    );
    final title = tester.widget<Text>(find.text("Today's plan"));
    expect(title.style?.fontFamily, 'SourceSans3');
    await tester.tap(find.text('2 of 3 done'));
    expect(tapped, isTrue);
  });

  testWidgets('action meets the minimum tap target', (tester) async {
    await tester.pumpWidget(
      harness(
        SectionHeader(
          title: "Today's plan",
          action: '2 of 3 done',
          onAction: () {},
        ),
      ),
    );
    final size = tester.getSize(
      find.descendant(
        of: find.byType(SectionHeader),
        matching: find.byType(InkWell),
      ),
    );
    expect(size.height, greaterThanOrEqualTo(AppDimensions.minTapTarget));
  });

  testWidgets('action is optional', (tester) async {
    await tester.pumpWidget(harness(const SectionHeader(title: 'Up next')));
    expect(find.text('Up next'), findsOneWidget);
  });
}
