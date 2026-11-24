import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';
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

  final earned = fakeReward(
    days: betaDays.take(5).toList(),
    surveySubmitted: true,
    eligible: true,
  );
  final activated = fakeReward(
    days: betaDays.take(5).toList(),
    surveySubmitted: true,
    activatedAt: ph(11, 20),
    rewardStartsAt: ph(11, 20),
    rewardEndsAt: ph(11, 20, 12, 0, 2027),
  );

  Future<void> pumpPhone(
    WidgetTester tester,
    FakeBetaFeedbackApi api, {
    bool isTester = true,
    List<String>? pushed,
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    // The earned notice was dismissed for good with Later.
    await AppPreferencesRepository(db)
        .setDeviceValue('home_notice_dismissed_beta', 'earned');
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SettingsHomePage()),
        GoRoute(
          path: '/settings/beta-feedback',
          builder: (_, __) {
            pushed?.add('/settings/beta-feedback');
            return const Scaffold(body: Text('reward page'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: phone(db, api, tester: isTester),
        child: MaterialApp.router(
          routerConfig: router,
          theme: buildLightTheme(web: false),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
      'phone: a tester who dismissed the notice still reaches the '
      'reward', (tester) async {
    final pushed = <String>[];
    await pumpPhone(
      tester,
      FakeBetaFeedbackApi(reward: earned),
      pushed: pushed,
    );
    expect(find.text('Beta Reward'), findsOneWidget);
    expect(find.text('BETA'), findsNothing);
    expect(find.textContaining('of 5 days'), findsNothing);
    expect(find.text('Feedback'), findsNothing);
    await tester.tap(find.text('Beta Reward'));
    await tester.pumpAndSettle();
    expect(find.text('reward page'), findsOneWidget);
  });

  for (final (label, reward, isTester) in [
    ('no earned reward', fakeReward(), true),
    ('already turned on', activated, true),
    ('not a tester', earned, false),
  ]) {
    testWidgets('phone: no Beta Reward row ($label)', (tester) async {
      await pumpPhone(
        tester,
        FakeBetaFeedbackApi(reward: reward),
        isTester: isTester,
      );
      expect(find.text('Beta Reward'), findsNothing);
    });
  }

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
      expect(find.text('Beta Reward'), findsNothing);
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
      BetaReward? reward,
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
              api: FakeBetaFeedbackApi(reward: reward),
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

    testWidgets('the list has a Beta Reward row for an earned reward',
        (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await pumpWide(tester, db, isTester: true, reward: earned);
      expect(find.text('Beta Reward'), findsOneWidget);
      expect(find.text('BETA'), findsNothing);
      expect(find.textContaining('of 5 days'), findsNothing);
      expect(find.text('Feedback'), findsNothing);
    });

    for (final isTester in [true, false]) {
      testWidgets(
          'the list (${isTester ? 'tester' : 'student'}) has no Feedback '
          'row and no beta switch', (tester) async {
        final db = inMemoryDatabase();
        addTearDown(db.close);
        await pumpWide(tester, db, isTester: isTester);
        expect(find.text('Pantas Pro'), findsOneWidget);
        expect(find.text('Beta Reward'), findsNothing);
        expect(find.text('Feedback'), findsNothing);
        expect(find.text('BETA'), findsNothing);
        expect(find.textContaining('of 5 days'), findsNothing);
        expect(find.text('Beta: Pro Features'), findsNothing);
        expect(find.textContaining('on for the beta'), findsNothing);
      });
    }
  });
}
