// Route /settings/account.
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';

import '../../helpers/in_memory_database.dart';
import 'fixtures/settings_fixtures.dart';
import 'screen_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  goldenScreen('settings_account', (tester, width) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    return pumpScreen(
      tester,
      width,
      settingsFramed(const AccountPage(), web: width >= 1024),
      overrides: settingsOverrides(db),
    );
  });
}
