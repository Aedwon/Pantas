import 'package:cse_cet_reviewer/core/ui/components/ruled_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('a panel shows its heading and its child', (tester) async {
    await tester.pumpApp(
      const RuledPanel(
        heading: "Today's session",
        child: Text('body'),
      ),
    );

    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('a panel shows a count when given one', (tester) async {
    await tester.pumpApp(
      const RuledPanel(
        heading: 'Still going',
        count: '6 of 10',
        child: Text('body'),
      ),
    );

    expect(find.text('6 of 10'), findsOneWidget);
  });

  testWidgets('a panel without a count renders no trailing text',
      (tester) async {
    await tester.pumpApp(
      const RuledPanel(heading: 'Mock exam', child: Text('body')),
    );

    expect(find.text('Mock exam'), findsOneWidget);
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('the panel is a square-cornered bordered rectangle',
      (tester) async {
    await tester.pumpApp(
      const RuledPanel(heading: 'Mock exam', child: Text('body')),
    );

    final container = tester.widget<Container>(
      find
          .ancestor(
            of: find.text('Mock exam'),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.borderRadius, isNull);
    expect(decoration.boxShadow, isNull);
    expect(decoration.border, isNotNull);
  });
}
