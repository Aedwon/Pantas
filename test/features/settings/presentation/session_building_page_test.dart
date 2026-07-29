import 'package:cse_cet_reviewer/core/storage/data/app_database.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/features/settings/data/settings_repository.dart';
import 'package:cse_cet_reviewer/features/settings/domain/session_ordering.dart';
import 'package:cse_cet_reviewer/features/settings/presentation/pages/session_building_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = inMemoryDatabase());
  tearDown(() => db.close());

  testWidgets('every ordering is offered with its explanation', (tester) async {
    await tester.pumpAppWithProviders(
      const SessionBuildingPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Every question from the chosen topic'), findsOneWidget);
    expect(find.text('Interleaved tail'), findsOneWidget);
    expect(
      find.text('Seven from the topic, three from elsewhere'),
      findsOneWidget,
    );
    expect(find.text('Fully mixed'), findsOneWidget);
    expect(
      find.text('No two consecutive questions from the same topic'),
      findsOneWidget,
    );
  });

  testWidgets('the default carries a recommended marker', (tester) async {
    await tester.pumpAppWithProviders(
      const SessionBuildingPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    expect(find.text('Recommended'), findsOneWidget);
  });

  testWidgets('choosing an ordering writes it', (tester) async {
    await tester.pumpAppWithProviders(
      const SessionBuildingPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fully mixed'));
    await tester.pumpAndSettle();

    final saved = await DriftSettingsRepository(db).readUserSettings();
    expect(saved.sessionOrdering, SessionOrdering.fullyMixed);
  });
}
