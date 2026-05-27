import 'package:cse_cet_reviewer/features/settings/presentation/pages/debug_settings_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('debug page renders unavailable state when flag is false',
      (tester) async {
    await tester.pumpApp(const DebugSettingsPage());

    expect(find.text('Debug settings are unavailable.'), findsOneWidget);
    expect(find.text('Wipe local data'), findsNothing);
  });
}
