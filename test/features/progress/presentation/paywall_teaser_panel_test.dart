import 'package:cse_cet_reviewer/features/progress/domain/progress_panel.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/paywall_teaser_panel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders locked analytical teaser copy', (tester) async {
    await tester.pumpApp(
      const PaywallTeaserPanel(
        panel: ProgressPanel(
          id: 'trend_lines',
          intent: ProgressPanelIntent.retrospective,
          contentType: ProgressPanelContent.analytical,
          window: ProgressPanelWindow.prepWindow,
          access: ProgressPanelAccess.teaser,
        ),
      ),
    );

    expect(find.text('Trend lines'), findsOneWidget);
    expect(find.text('Unlock Pro to see the full analysis.'), findsOneWidget);
  });
}
