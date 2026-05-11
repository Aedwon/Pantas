import 'package:cse_cet_reviewer/core/ui/components/coach_mark.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('CoachMark', () {
    testWidgets('renders headline and body', (tester) async {
      await tester.pumpApp(
        CoachMark(
          headline: 'Tap this every day 🔁',
          body: 'This FSRS review keeps knowledge in long-term memory.',
          onDismiss: () {},
        ),
      );
      expect(find.text('Tap this every day 🔁'), findsOneWidget);
      expect(find.textContaining('long-term memory'), findsOneWidget);
    });

    testWidgets('shows dismiss CTA', (tester) async {
      await tester.pumpApp(
        CoachMark(
          headline: 'Got it',
          body: 'Body text',
          onDismiss: () {},
        ),
      );
      expect(find.textContaining('Got it'), findsAtLeast(1));
    });

    testWidgets('fires onDismiss when CTA tapped', (tester) async {
      var dismissed = false;
      await tester.pumpApp(
        CoachMark(
          headline: 'Headline',
          body: 'Body',
          onDismiss: () => dismissed = true,
        ),
      );
      await tester.tap(find.textContaining('Got it →'));
      expect(dismissed, isTrue);
    });
  });
}
