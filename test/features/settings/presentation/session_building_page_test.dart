import 'dart:ui' show CheckedState;

import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/features/settings/data/settings_repository.dart';
import 'package:pantas/features/settings/domain/session_ordering.dart';
import 'package:pantas/features/settings/presentation/pages/session_building_page.dart';

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

    expect(find.text('One topic only'), findsOneWidget);
    expect(find.text('Grouped by topic, one topic at a time.'), findsOneWidget);
    expect(find.text('Interleaved tail'), findsOneWidget);
    expect(
      find.text('Mostly one topic, some others.'),
      findsOneWidget,
    );
    expect(find.text('Fully mixed'), findsOneWidget);
    expect(
      find.text('No two in a row from the same topic.'),
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

  testWidgets('each ordering is one 48dp radio-like control', (tester) async {
    await tester.pumpAppWithProviders(
      const SessionBuildingPage(),
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();

    for (final label in ['One topic only', 'Interleaved tail', 'Fully mixed']) {
      final control = find.bySemanticsLabel(RegExp('^$label'));
      expect(control, findsOneWidget);
      final semantics = tester.getSemantics(control);
      expect(
        semantics.flagsCollection.isChecked,
        label == 'Interleaved tail'
            ? CheckedState.isTrue
            : CheckedState.isFalse,
      );
      expect(semantics.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(tester.getSize(control).height, greaterThanOrEqualTo(48));
    }
  });
}
