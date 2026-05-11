import 'package:cse_cet_reviewer/core/ui/components/streak_banner.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('StreakBanner', () {
    testWidgets('active state shows streak count and personal best',
        (tester) async {
      await tester.pumpApp(
        StreakBanner(
          streakCount: 7,
          personalBest: 12,
          variant: StreakBannerVariant.active,
          onReviewTap: () {},
        ),
      );
      expect(find.textContaining('7'), findsAtLeast(1));
      expect(find.textContaining('12'), findsOneWidget);
    });

    testWidgets('atRisk state shows review CTA', (tester) async {
      await tester.pumpApp(
        StreakBanner(
          streakCount: 5,
          personalBest: 10,
          variant: StreakBannerVariant.atRisk,
          onReviewTap: () {},
        ),
      );
      expect(find.textContaining('Review'), findsAtLeast(1));
    });

    testWidgets('atRisk fires onReviewTap when CTA tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        StreakBanner(
          streakCount: 3,
          personalBest: 8,
          variant: StreakBannerVariant.atRisk,
          onReviewTap: () => tapped = true,
        ),
      );
      await tester.tap(find.text('Review\nnow'));
      expect(tapped, isTrue);
    });
  });
}
