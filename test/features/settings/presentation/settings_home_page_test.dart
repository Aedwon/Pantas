import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
      'root has profile and the approved destinations without a back link',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
        isAnonymousProvider.overrideWith((ref) async => true),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.byType(Avatar), findsOneWidget);
    expect(find.text('Add your name'), findsOneWidget);
    expect(find.text('Not signed in'), findsOneWidget);
    final titles =
        tester.widgetList<ListRow>(find.byType(ListRow)).map((r) => r.title);
    expect(
      titles,
      containsAllInOrder([
        'Pantas Pro',
        'Your exam',
        'Practice',
        'Reminders',
        'Appearance',
        'About',
      ]),
    );
    expect(find.text('Home'), findsNothing);
    expect(find.text('Exam date'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  test('Pro root value names the owned plan', () {
    final container = ProviderContainer(
      overrides: [
        entitlementProvider.overrideWith(
          (ref) =>
              Stream.value(const Entitlement(plan: EntitlementPlan.yearly)),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container.read(entitlementProvider.future).then((_) {
      expect(container.read(proRowValueProvider), 'Yearly');
    });
  });
}
