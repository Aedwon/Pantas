import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/ui/components/ink_checkbox.dart';
import 'package:pantas/core/ui/components/topic_scope_index.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

void main() {
  final subjects = [
    const TopicScopeSubjectData(
      id: 'sub_math',
      name: 'Mathematics',
      topics: [
        TopicScopeTopicData(id: 'top_alg', name: 'Algebra'),
        TopicScopeTopicData(id: 'top_geo', name: 'Geometry'),
      ],
    ),
  ];

  testWidgets('renders subject heading and topic rows', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: TopicScopeIndex(
            subjects: subjects,
            topicState: (_) => TopicScopeCheckState.on,
            onToggleTopic: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mathematics'), findsOneWidget);
    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('Geometry'), findsOneWidget);
  });

  testWidgets('displays topic check state correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: TopicScopeIndex(
            subjects: subjects,
            topicState: (topic) => topic.id == 'top_alg'
                ? TopicScopeCheckState.on
                : TopicScopeCheckState.off,
            onToggleTopic: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final checkboxFinder = find.byWidgetPredicate((w) => w is InkCheckbox);
    final checkboxes = tester.widgetList<InkCheckbox>(checkboxFinder).toList();
    expect(checkboxes[0].state, equals(InkCheckState.on));
    expect(checkboxes[1].state, equals(InkCheckState.off));
  });

  testWidgets('invokes onToggleTopic when a topic is tapped', (tester) async {
    TopicScopeTopicData? toggled;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        home: Scaffold(
          body: TopicScopeIndex(
            subjects: subjects,
            topicState: (_) => TopicScopeCheckState.on,
            onToggleTopic: (t) => toggled = t,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Algebra'));
    await tester.pump();

    expect(toggled, isNotNull);
    expect(toggled!.id, equals('top_alg'));
  });
}
