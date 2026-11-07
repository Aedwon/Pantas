import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/data/app_database.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/application/beta_pro_provider.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/settings_home_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';
import '../../beta_feedback/presentation/beta_feedback_fakes.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

Finder _card(String text) => find.ancestor(
      of: find.text(text),
      matching: find.byType(GroupedSection),
    );

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
        betaProProvider.overrideWith(
          (ref) => Stream.value(
            BetaProState(until: DateTime(2026, 11, 16), enabled: true),
          ),
        ),
        ...betaOverrides(api: api, now: now, tester: tester),
      ];

  testWidgets('a tester gets Feedback and Beta: Pro Features in a first card',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: phone(db, FakeBetaFeedbackApi()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Feedback'), findsOneWidget);
    expect(find.text('BETA'), findsOneWidget);
    expect(find.text('3 of 5 days'), findsOneWidget);
    // Feedback and the Beta switch share the first card; Pantas Pro is alone.
    final first = tester.widget(_card('Feedback'));
    expect(tester.widget(_card('Beta: Pro Features')), same(first));
    expect(tester.widget(_card('Pantas Pro')), isNot(same(first)));
    final feedbackY = tester.getTopLeft(find.text('Feedback')).dy;
    final proY = tester.getTopLeft(find.text('Pantas Pro')).dy;
    final noteY = tester
        .getTopLeft(
          find.text('Pro features are on for the beta, until Nov 16.'),
        )
        .dy;
    final accountY = tester.getTopLeft(find.text('Add your name')).dy;
    expect(accountY, lessThan(feedbackY));
    expect(feedbackY, lessThan(noteY));
    expect(noteY, lessThan(proY));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a person who is not a tester sees no Feedback row',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: phone(db, FakeBetaFeedbackApi(), tester: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Feedback'), findsNothing);
    // Beta: Pro Features stays under Pantas Pro, where it is today.
    expect(
      tester.widget(_card('Beta: Pro Features')),
      same(tester.widget(_card('Pantas Pro'))),
    );
  });

  testWidgets('the value is empty while it loads, then fades in',
      (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    final gate = Completer<void>();
    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: phone(db, FakeBetaFeedbackApi(rewardGate: gate)),
    );
    await tester.pump();
    expect(find.text('Feedback'), findsOneWidget);
    expect(find.textContaining('days'), findsNothing);

    gate.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    final fade = find.ancestor(
      of: find.text('3 of 5 days'),
      matching: find.byType(Opacity),
    );
    expect(fade, findsWidgets);
    final opacity = tester
        .widgetList<Opacity>(fade)
        .map((f) => f.opacity)
        .reduce((a, b) => a < b ? a : b);
    expect(opacity, lessThan(1));
    await tester.pumpAndSettle();
    expect(find.text('3 of 5 days'), findsOneWidget);
  });

  testWidgets('a count over 5 reads "5 of 5 days"', (tester) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    await tester.pumpAppWithProviders(
      const SettingsHomePage(),
      overrides: phone(
        db,
        FakeBetaFeedbackApi(
          reward: fakeReward(days: betaDays),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('5 of 5 days'), findsOneWidget);
    expect(find.text('7 of 5 days'), findsNothing);
  });

  group('wide web', () {
    setUp(() => debugWebPlatformOverride = true);
    tearDown(() => debugWebPlatformOverride = null);

    Future<void> pumpWide(
      WidgetTester tester,
      AppDatabase db, {
      bool selected = true,
      bool tester_ = true,
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
            betaProProvider.overrideWith(
              (ref) => Stream.value(
                BetaProState(until: DateTime(2026, 11, 16), enabled: true),
              ),
            ),
            ...betaOverrides(
              api: FakeBetaFeedbackApi(),
              now: now,
              tester: tester_,
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: true),
            home: Scaffold(
              body: SingleChildScrollView(
                child: SettingsNavigation(
                  selected: selected ? 'Feedback' : 'Account',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the list has the Feedback row, selected, with no chevron',
        (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await pumpWide(tester, db);
      expect(find.text('Feedback'), findsOneWidget);
      expect(find.text('BETA'), findsOneWidget);
      expect(find.text('3 of 5 days'), findsOneWidget);
      final rows = tester
          .widgetList<WebRow>(find.byType(WebRow))
          .where((r) => r.title == 'Feedback');
      expect(rows, hasLength(1));
      expect(rows.single.selected, isTrue);
      expect(rows.single.chevron, WebRowChevron.none);
      // Same card as Beta: Pro Features, above Pantas Pro.
      final feedbackY = tester.getTopLeft(find.text('Feedback')).dy;
      final betaY = tester.getTopLeft(find.text('Beta: Pro Features')).dy;
      final proY = tester.getTopLeft(find.text('Pantas Pro')).dy;
      expect(feedbackY, lessThan(betaY));
      expect(betaY, lessThan(proY));
      final card = find.ancestor(
        of: find.text('Feedback'),
        matching: find.byType(WebCard),
      );
      expect(
        find.descendant(of: card, matching: find.text('Beta: Pro Features')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('Pantas Pro')),
        findsNothing,
      );
    });

    testWidgets('a non-tester has no Feedback row', (tester) async {
      final db = inMemoryDatabase();
      addTearDown(db.close);
      await pumpWide(tester, db, tester_: false, selected: false);
      expect(find.text('Feedback'), findsNothing);
    });
  });
}
