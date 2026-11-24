// U10: the Account header and block gaps of board ST_Account (avatar, name and
// email 8 px apart, 22 px between the header and every card) and the weight of
// the name on the Settings root card (ST_Root: 22/600).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/avatar.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/settings/presentation/pages/account_page.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import 'account_page_test.dart' show SequencedAuthRepository;

void main() {
  testWidgets('the Account header and cards use the board gaps',
      (tester) async {
    tester.view
      ..physicalSize = const Size(390, 1000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith(
            (ref) => const AuthUser(
              uid: 'u',
              email: 'aerol@gmail.com',
              displayName: 'Aerol',
            ),
          ),
          authRepositoryProvider
              .overrideWithValue(SequencedAuthRepository(const [])),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const AccountPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final avatar = tester.getRect(find.byType(Avatar));
    final email = tester.getRect(find.text('aerol@gmail.com').first);
    // The name is the text between the avatar and the email.
    final name = tester.getRect(find.text('Add your name').first);
    expect(name.top - avatar.bottom, 8);
    // ST_Account: the name is 24/700.
    final nameText = tester.widget<Text>(find.text('Add your name').first);
    expect(nameText.style!.fontSize, 24);
    expect(nameText.style!.fontWeight, FontWeight.w700);
    expect(email.top - name.bottom, 8);

    final sections = find.byType(SettingsSection);
    final first = tester.getRect(sections.first);
    // 6 px under the header block plus the 22 px column gap.
    expect(first.top - email.bottom, 28);
    for (var i = 1; i < sections.evaluate().length; i++) {
      final above = tester.getRect(sections.at(i - 1));
      final below = tester.getRect(sections.at(i));
      expect(
        below.top - above.bottom,
        22,
        reason: 'between cards ${i - 1}, $i',
      );
    }
  });

  testWidgets('the Settings root card name is 22/600', (tester) async {
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
    final name = tester.widget<Text>(find.text('Add your name'));
    expect(name.style!.fontSize, 22);
    expect(name.style!.fontWeight, FontWeight.w600);
  });
}
