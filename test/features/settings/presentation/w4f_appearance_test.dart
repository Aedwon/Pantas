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
    // Slider README: the label reads "Lesson Text Size", 13/600, above the
    // control, and no section eyebrow says "Text size".
    expect(find.text('Lesson Text Size'), findsOneWidget);
    expect(find.text('TEXT SIZE'), findsNothing);
    expect(find.text('Text size'), findsNothing);
    final label = tester.widget<Text>(find.text('Lesson Text Size'));
    expect(label.style!.fontSize, 13);
    expect(label.style!.fontWeight, FontWeight.w600);
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(1.5);
    await tester.pumpAndSettle();
    // The system slider prints the size beside the track.
    expect(find.text('1.5\u00d7'), findsOneWidget);
    final prefs = AppPreferencesRepository(db);
    expect(await prefs.deviceValue('lesson_text_scale'), '1.5');
  });
}
