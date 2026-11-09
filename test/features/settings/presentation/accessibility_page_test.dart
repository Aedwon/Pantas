import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/letter_shortcuts.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/settings/presentation/pages/accessibility_page.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  List<Override> overrides(AppDatabase db) => [
        appDatabaseProvider.overrideWithValue(db),
        currentUserProvider.overrideWith((ref) async => null),
        isAnonymousProvider.overrideWith((ref) async => true),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
      ];

  Future<void> pumpWide(
    WidgetTester tester,
    AppDatabase db,
    Widget page,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpAppWithProviders(
      Theme(
        data: buildLightTheme(web: true),
        child: MediaQuery(
          data: const MediaQueryData(
            size: Size(1440, 1000),
            disableAnimations: true,
          ),
          child: page,
        ),
      ),
      overrides: overrides(db),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('wide Settings lists Accessibility between Appearance and About',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpWide(tester, db, const AccessibilityPage());
    final nav = find.byKey(const ValueKey('settings-navigation'));
    double top(String label) => tester
        .getTopLeft(find.descendant(of: nav, matching: find.text(label)))
        .dy;
    expect(top('Appearance'), lessThan(top('Accessibility')));
    expect(top('Accessibility'), lessThan(top('About')));
  });

  testWidgets('the Keyboard Shortcuts row is a switch that starts on',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpWide(tester, db, const AccessibilityPage());
    expect(find.text('Keyboard Shortcuts'), findsOneWidget);
    expect(
      find.text('Letter keys pick and flag answers in a quiz.'),
      findsOneWidget,
    );
    expect(
      tester.widget<PantasSwitch>(find.byType(PantasSwitch)).value,
      isTrue,
    );
  });

  testWidgets('tapping the row turns the shortcuts off at once and keeps it',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpWide(tester, db, const AccessibilityPage());
    await tester.tap(find.text('Keyboard Shortcuts'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PantasSwitch>(find.byType(PantasSwitch)).value,
      isFalse,
    );
    // A new container over the same storage reads the saved choice.
    final again = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(again.dispose);
    expect(again.read(letterShortcutsProvider), isTrue, reason: 'loading');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(again.read(letterShortcutsProvider), isFalse);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping again turns them back on', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await pumpWide(tester, db, const AccessibilityPage());
    await tester.tap(find.text('Keyboard Shortcuts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keyboard Shortcuts'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PantasSwitch>(find.byType(PantasSwitch)).value,
      isTrue,
    );
  });

  testWidgets('the phone Settings list has no Accessibility row',
      (tester) async {
    debugWebPlatformOverride = null;
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: overrides(db),
    );
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Accessibility'), findsNothing);
  });
}
