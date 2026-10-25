import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/presentation/pages/session_building_page.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('Practice edits the actual quiz length and shows strict mode',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      const SessionBuildingPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();
    expect(find.text('SESSION LENGTH'), findsOneWidget);
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();
    final row = await (db.select(db.accountPrefs)
          ..where((p) => p.key.equals('quiz_session_length')))
        .getSingle();
    expect(row.value, '20');
    expect(find.text('Strict mode'), findsOneWidget);
  });
}
