import 'package:cse_cet_reviewer/features/progress/presentation/paywall_teaser_panel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('prints the heading with an unlock action', (tester) async {
    var unlocked = false;
    await tester.pumpApp(
      PaywallTeaserPanel(
        title: 'Accuracy trend',
        onUnlock: () => unlocked = true,
      ),
    );

    expect(find.text('Accuracy trend'), findsOneWidget);
    expect(find.text('Unlock with Pro'), findsOneWidget);

    await tester.tap(find.text('Unlock with Pro'));
    expect(unlocked, isTrue);
  });
}
