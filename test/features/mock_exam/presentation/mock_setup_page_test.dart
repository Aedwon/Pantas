import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
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
}
