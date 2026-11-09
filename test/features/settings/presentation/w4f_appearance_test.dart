import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/settings_routes.dart';
import 'package:pantas/core/storage/storage.dart';
import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

final _routes = Provider(settingsRoutes);
void main() {
  testWidgets('Appearance route writes text scale and offers all themes',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/settings/appearance',
      routes: container.read(_routes),
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    for (final label in ['Light', 'Dark', 'Automatic']) {
      expect(find.text(label), findsOneWidget);
    }
    // Board TS_A: the section header reads "Lesson Text Size" and no second
    // label sits above the slider.
    expect(find.text('LESSON TEXT SIZE'), findsOneWidget);
    expect(find.text('Lesson Text Size'), findsNothing);
    expect(find.text('TEXT SIZE'), findsNothing);
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(1.5);
    await tester.pumpAndSettle();
    // The system slider prints the size beside the track.
    expect(find.text('1.5\u00d7'), findsOneWidget);
    final prefs = AppPreferencesRepository(db);
    expect(await prefs.deviceValue('lesson_text_scale'), '1.5');
  });
  _phoneSelection();
}

/// The phone tiles show which theme is in effect: while Automatic is on, the
/// tile of the OS theme; with Automatic off, the chosen one.
void _phoneSelection() {
  Finder tileCheck(String label) => find.descendant(
        of: find
            .ancestor(
              of: find.text(label),
              matching: find.byType(GestureDetector),
            )
            .first,
        matching: find.byIcon(Icons.check),
      );

  Future<void> open(WidgetTester tester, Brightness os) async {
    tester.view
      ..physicalSize = const Size(390, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.platformBrightnessTestValue = os;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/settings/appearance',
      routes: container.read(_routes),
    );
    addTearDown(router.dispose);
    await tester.pumpAppWithRouter(
      router,
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Automatic on, OS dark: the Dark tile shows selected',
      (tester) async {
    await open(tester, Brightness.dark);
    expect(tileCheck('Dark'), findsOneWidget);
    expect(tileCheck('Light'), findsNothing);
  });

  testWidgets('Automatic on, OS light: the Light tile shows selected',
      (tester) async {
    await open(tester, Brightness.light);
    expect(tileCheck('Light'), findsOneWidget);
    expect(tileCheck('Dark'), findsNothing);
  });

  testWidgets('Automatic off: the chosen tile shows, not the OS theme',
      (tester) async {
    await open(tester, Brightness.light);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(tileCheck('Dark'), findsOneWidget);
    expect(tileCheck('Light'), findsNothing);
  });
}
