import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import '../../beta_feedback/presentation/beta_feedback_fakes.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

void main() {
  final now = ph(11, 12, 20);

  List<Override> phone(
    AppDatabase db,
    FakeBetaFeedbackApi api, {
    bool tester = true,
  }) =>
      [
        appDatabaseProvider.overrideWithValue(db),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
        isAnonymousProvider.overrideWith((ref) async => true),
        ...betaOverrides(api: api, now: now, tester: tester),
      ];

  for (final isTester in [true, false]) {
    testWidgets(
        'phone (${isTester ? 'tester' : 'student'}): no Feedback row, '
        'no beta switch', (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await tester.pumpAppWithProviders(
        const SettingsHomePage(),
        overrides: phone(db, FakeBetaFeedbackApi(), tester: isTester),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pantas Pro'), findsOneWidget);
      expect(find.text('Feedback'), findsNothing);
      expect(find.text('BETA'), findsNothing);
      expect(find.textContaining('of 5 days'), findsNothing);
      expect(find.text('Beta: Pro Features'), findsNothing);
      expect(find.textContaining('on for the beta'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  group('wide web', () {
    setUp(() => debugWebPlatformOverride = true);
    tearDown(() => debugWebPlatformOverride = null);

    Future<void> pumpWide(
      WidgetTester tester,
      AppDatabase db, {
      required bool isTester,
    }) async {
      tester.view
        ..physicalSize = const Size(1440, 1000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            currentUserProvider.overrideWith((ref) async => null),
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
            ...betaOverrides(
              api: FakeBetaFeedbackApi(),
              now: now,
              tester: isTester,
            ),
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
      await tester.pumpAndSettle();
    }

    for (final isTester in [true, false]) {
      testWidgets(
          'the list (${isTester ? 'tester' : 'student'}) has no Feedback '
          'row and no beta switch', (tester) async {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        await pumpWide(tester, db, isTester: isTester);
        expect(find.text('Pantas Pro'), findsOneWidget);
        expect(find.text('Feedback'), findsNothing);
        expect(find.text('BETA'), findsNothing);
        expect(find.textContaining('of 5 days'), findsNothing);
        expect(find.text('Beta: Pro Features'), findsNothing);
        expect(find.textContaining('on for the beta'), findsNothing);
      });
    }
  });
}
