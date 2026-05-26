import 'package:cse_cet_reviewer/features/mock_exam/mock_exam.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('status card renders ready cooldown and in-progress states',
      (tester) async {
    await tester.pumpApp(
      MockStatusCard(
        availability: const MockAvailability.available(),
        onStart: () {},
        onResume: () {},
      ),
    );
    expect(find.text('Mock ready'), findsOneWidget);

    await tester.pumpApp(
      MockStatusCard(
        availability: const MockAvailability.cooldown(Duration(days: 2)),
        onStart: () {},
        onResume: () {},
      ),
    );
    expect(find.text('Next mock in 2 days'), findsOneWidget);

    await tester.pumpApp(
      MockStatusCard(
        availability: const MockAvailability.inProgress(null),
        onStart: () {},
        onResume: () {},
      ),
    );
    expect(find.text('Resume mock'), findsOneWidget);
  });
}
