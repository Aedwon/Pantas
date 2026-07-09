import 'package:cse_cet_reviewer/core/ui/components/ruled_panel.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_colors.dart';
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

  testWidgets('an action renders in board and fires', (tester) async {
    var tapped = false;
    await tester.pumpApp(
      RuledPanel(
        heading: 'Practice',
        action: 'See all',
        onAction: () => tapped = true,
        child: const Text('body'),
      ),
    );
    final action = tester.widget<Text>(find.text('See all'));
    expect(action.style?.color, AppColors.light.board);
    await tester.tap(find.text('See all'));
    expect(tapped, isTrue);
  });

  testWidgets('an action with no handler is muted, not board', (tester) async {
    await tester.pumpApp(
      const RuledPanel(
        heading: 'Practice',
        action: 'See all',
        child: Text('body'),
      ),
    );
    expect(
      tester.widget<Text>(find.text('See all')).style?.color,
      AppColors.light.inkMuted,
    );
  });

  testWidgets('a count and an action together is an error', (tester) async {
    expect(
      () => RuledPanel(
        heading: 'Practice',
        count: '3',
        action: 'See all',
        child: const Text('body'),
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}

