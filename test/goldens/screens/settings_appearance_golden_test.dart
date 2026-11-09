// Route /settings/appearance.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/settings/presentation/pages/appearance_page.dart';

import '../../helpers/in_memory_database.dart';
import 'fixtures/settings_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen('settings_appearance', (tester, width) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    return pumpScreen(
      tester,
      width,
      settingsFramed(const AppearancePage(), web: width >= 1024),
      overrides: settingsOverrides(db),
    );
  });
}
