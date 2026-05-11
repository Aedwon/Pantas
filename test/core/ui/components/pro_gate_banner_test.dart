import 'package:cse_cet_reviewer/core/ui/components/pro_gate_banner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('ProGateBanner', () {
    testWidgets('shows PRO badge, feature name, value prop, and price CTA',
        (tester) async {
      await tester.pumpApp(
        ProGateBanner(
          featureName: 'Full Mock Exams',
          valueProp: 'Practice with a real timed exam.',
          ctaLabel: 'View Pro — ₱99/mo',
          featureEmoji: '📝',
          onCta: () {},
          onDismiss: () {},
        ),
      );
      expect(find.text('PRO'), findsOneWidget);
      expect(find.text('Full Mock Exams'), findsOneWidget);
      expect(find.textContaining('timed exam'), findsOneWidget);
      expect(find.text('View Pro — ₱99/mo'), findsOneWidget);
    });

    testWidgets('shows Maybe later dismiss button', (tester) async {
      await tester.pumpApp(
        ProGateBanner(
          featureName: 'Feature',
          valueProp: 'Value',
          ctaLabel: 'CTA',
          featureEmoji: '🔒',
          onCta: () {},
          onDismiss: () {},
        ),
      );
      expect(find.text('Maybe later'), findsOneWidget);
    });

    testWidgets('fires onCta when CTA tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        ProGateBanner(
          featureName: 'Feature',
          valueProp: 'Value',
          ctaLabel: 'Upgrade',
          featureEmoji: '⭐',
          onCta: () => tapped = true,
          onDismiss: () {},
        ),
      );
      await tester.tap(find.text('Upgrade'));
      expect(tapped, isTrue);
    });

    testWidgets('fires onDismiss when Maybe later tapped', (tester) async {
      var dismissed = false;
      await tester.pumpApp(
        ProGateBanner(
          featureName: 'Feature',
          valueProp: 'Value',
          ctaLabel: 'CTA',
          featureEmoji: '⭐',
          onCta: () {},
          onDismiss: () => dismissed = true,
        ),
      );
      await tester.tap(find.text('Maybe later'));
      expect(dismissed, isTrue);
    });
  });
}
