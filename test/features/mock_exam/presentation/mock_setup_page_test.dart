import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/content/domain/mock_blueprint.dart';
import 'package:pantas/features/mock_exam/mock_exam.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'setup page shows blueprint duration section count and start button',
      (tester) async {
    await tester.pumpApp(
      MockSetupPage(
        parsedBlueprint: const ParsedMockBlueprint(
          blueprint: MockBlueprint(
            id: 'bp_cse',
            examId: 'exam_cse',
            name: 'CSE Practice',
            durationMinutes: 90,
            sectionsJson: '[]',
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
        onStart: () {},
      ),
    );

    expect(find.text('Ready to practice?'), findsOneWidget);
    expect(find.text('CSE Practice'), findsOneWidget);
    expect(find.text('90 min · 10 questions'), findsOneWidget);
    expect(find.text('General Information'), findsOneWidget);
    expect(find.text('Start mock'), findsOneWidget);
  });
}
