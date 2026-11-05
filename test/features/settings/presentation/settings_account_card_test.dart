import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

void main() {
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  // 7W-16: the card read "Not signed in" for a frame while auth loaded.
  testWidgets('the account card is a skeleton until auth is known',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final auth = Completer<AuthUser?>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          currentUserProvider.overrideWith((ref) => auth.future),
          isAnonymousProvider.overrideWith((ref) async => false),
          userSettingsProvider
              .overrideWith((ref) async => UserSettings.defaults()),
          activeExamFocusProvider.overrideWith(
            (ref) async => ActiveExamFocus.selected(buildExam(id: 'e')),
          ),
          syncStatusProvider
              .overrideWith((ref) => Stream.value(const SyncOff())),
          revenueCatGatewayProvider.overrideWithValue(
            SettingsGateway(initial: const Entitlement.free()),
          ),
          proForActiveExamProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp(
          theme: buildLightTheme(web: true),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: SettingsNavigation(selected: 'Account'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Not signed in'), findsNothing);

    auth.complete(
      const AuthUser(
        uid: 'u',
        email: 'free@pantas.local',
        displayName: 'Free',
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('free@pantas.local'), findsOneWidget);
    expect(find.text('Not signed in'), findsNothing);
  });
}
