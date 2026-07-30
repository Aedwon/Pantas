import 'package:pantas/core/ui/components/empty_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders headline, body and CTA', (tester) async {
      await tester.pumpApp(
        EmptyState(
          headline: 'All caught up!',
          body: 'You have no cards due.',
          ctaLabel: 'Quiz instead',
          onCta: () {},
        ),
      );
      expect(find.text('All caught up!'), findsOneWidget);
      expect(find.text('You have no cards due.'), findsOneWidget);
      expect(find.text('Quiz instead'), findsOneWidget);
    });

    testWidgets('CTA fires callback', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        EmptyState(
          headline: 'No connection',
          body: 'Check your internet.',
          ctaLabel: 'Try again',
          onCta: () => tapped = true,
        ),
      );
      await tester.tap(find.text('Try again'));
      expect(tapped, isTrue);
    });
  });
}
