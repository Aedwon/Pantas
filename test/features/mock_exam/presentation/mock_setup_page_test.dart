import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'setup page shows blueprint table, total and start action',
    (tester) async {
      await tester.pumpApp(
        MockSetupPage(
          parsedBlueprint: const ParsedMockBlueprint(
            blueprint: MockBlueprint(
              id: 'bp_cse',
              examId: 'exam_cse_pro',
              name: 'CSE Professional Practice Paper',
              durationMinutes: 90,
              sectionsJson: '[]',
              sectionalTiming: SectionalTiming.roamable,
              totalPublishedItems: 10,
            ),
            sections: [
              BlueprintSection(
                id: 's1',
                name: 'General Information',
                questionCount: 10,
                suggestedMinutes: 12,
                topicIds: ['topic'],
                topicWeights: {'topic': 1},
              ),
            ],
          ),
          onStart: (_) {},
        ),
      );

      expect(find.text('CSE Professional simulation'), findsOneWidget);
      expect(find.text('10 total items · 1 hr 30 min'), findsOneWidget);
      expect(find.text('General Information'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Start the Mock Exam'), 300);
      expect(find.text('Start the Mock Exam'), findsOneWidget);
    },
  );

  testWidgets('strict mode row toggles from the text and the switch once',
      (tester) async {
    await tester.pumpApp(
      MockSetupPage(
        parsedBlueprint: const ParsedMockBlueprint(
          blueprint: MockBlueprint(
            id: 'bp_cse',
            examId: 'exam_cse_pro',
            name: 'CSE Professional Practice Paper',
            durationMinutes: 90,
            sectionsJson: '[]',
            sectionalTiming: SectionalTiming.roamable,
            totalPublishedItems: 10,
          ),
          sections: [
            BlueprintSection(
              id: 's1',
              name: 'General Information',
              questionCount: 10,
              suggestedMinutes: 12,
              topicIds: ['topic'],
              topicWeights: {'topic': 1},
            ),
          ],
        ),
        onStart: (_) {},
      ),
    );
    await tester.scrollUntilVisible(find.text('Strict mode'), 300);
    final semantics = tester.ensureSemantics();
    await tester.pump();
    final node = tester.getSemantics(find.byType(PantasSwitch));
    expect(node.label, contains('Strict mode for this mock'));
    expect(
      RegExp('Strict mode for this mock').allMatches(node.label),
      hasLength(1),
    );
    expect(
      node.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(find.textContaining('No pausing'), findsNothing);
    await tester.tap(find.text('Strict mode'));
    await tester.pump();
    expect(find.textContaining('No pausing'), findsOneWidget);
    await tester.tap(find.byType(PantasSwitch));
    await tester.pump();
    expect(find.textContaining('No pausing'), findsNothing);
    await tester.tap(find.textContaining('Closest to the real exam'));
    await tester.pump();
    expect(find.textContaining('No pausing'), findsOneWidget);
    semantics.dispose();
  });
}
