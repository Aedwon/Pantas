import 'package:cse_cet_reviewer/features/progress/presentation/paywall_teaser_panel.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/progress_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('free users see identity panels and analytical teasers',
      (tester) async {
    await tester.pumpAppWithProviders(
      const ProgressPage(proIsActive: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personality fingerprint'), findsOneWidget);
    expect(find.text('Current study signals'), findsOneWidget);
    expect(find.byType(PaywallTeaserPanel), findsNWidgets(3));
  });

  testWidgets('pro users see full analytical panels', (tester) async {
    await tester.pumpAppWithProviders(
      const ProgressPage(proIsActive: true),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PaywallTeaserPanel), findsNothing);
    expect(find.text('Pro analytical panel.'), findsNWidgets(3));
  });
}
