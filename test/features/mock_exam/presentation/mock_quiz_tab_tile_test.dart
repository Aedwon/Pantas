import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('quiz tab mock tile shows ready cooldown and in-progress states',
      (tester) async {
    await tester.pumpApp(
      MockQuizTabTile(
        availability: const MockAvailability.available(),
        onStart: () {},
        onResume: () {},
      ),
    );
    expect(find.text('Mock ready'), findsOneWidget);

    await tester.pumpApp(
      MockQuizTabTile(
        availability: const MockAvailability.cooldown(Duration(days: 3)),
        onStart: () {},
        onResume: () {},
      ),
    );
    expect(find.text('Next mock in 3 days'), findsOneWidget);

    await tester.pumpApp(
      MockQuizTabTile(
        availability: const MockAvailability.inProgress(null),
        onStart: () {},
        onResume: () {},
      ),
    );
    expect(find.text('Mock in progress'), findsOneWidget);
  });
}
