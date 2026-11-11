import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/routes/settings_routes_web.dart' as web;
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/sync/providers.dart';
import 'package:pantas/core/sync/sync_status.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/motion/pane_transition.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/legal/legal.dart';
import 'package:pantas/features/legal/presentation/legal_document_page.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../core/ui/motion/preview_curves.dart';
import '../features/settings/presentation/pro_page_payments_test.dart'
    show SettingsGateway;
import '../helpers/in_memory_database.dart';
import '../helpers/pump_app.dart';

// Items 1 and 15 on the real Settings and legal routes: the list and heading
// never move; only the detail does.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fonts = FontLoader('Geist');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(rootBundle.load('assets/fonts/Geist-$weight.ttf'));
    }
    await fonts.load();
  });
  setUp(() => debugWebPlatformOverride = true);
  tearDown(() => debugWebPlatformOverride = null);

  late GoRouter router;

  Color webAccent(WidgetTester tester) =>
      tester.element(find.byType(WebRow).first).webTokens.colors.accent;

  Future<void> pumpSettings(
    WidgetTester tester, {
    Size size = const Size(1440, 620),
    String initial = '/settings',
    bool onboarding = false,
    bool reduced = false,
    TargetPlatform platform = TargetPlatform.macOS,
  }) async {
    final db = inMemoryDatabase();
    addTearDown(db.close);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final routes = Provider(
      (ref) => GoRouter(
        initialLocation: initial,
        routes: [
          ...web.settingsRoutes(ref),
          GoRoute(
            path: '/onboarding',
            // The onboarding page draws the same top bar the legal page does,
            // with the same 10 px logo inset.
            builder: (_, __) => const Material(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: WebTopBar(
                      leading: PantasLogo(size: 28),
                      title: Text('Pantas'),
                    ),
                  ),
                  Text('Terms and Privacy'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        currentUserProvider.overrideWith((ref) async => null),
        isAnonymousProvider.overrideWith((ref) async => true),
        userSettingsProvider
            .overrideWith((ref) async => UserSettings.defaults()),
        activeExamFocusProvider.overrideWith(
          (ref) async => ActiveExamFocus.selected(
            buildExam(id: 'exam_cse_sub', shortName: 'CSE Subprofessional'),
          ),
        ),
        syncStatusProvider.overrideWith((ref) => Stream.value(const SyncOff())),
        revenueCatGatewayProvider.overrideWithValue(
          SettingsGateway(initial: const Entitlement.free()),
        ),
        proForActiveExamProvider.overrideWith((ref) async => false),
        legalInOnboardingProvider.overrideWithValue(onboarding),
      ],
    );
    addTearDown(container.dispose);
    router = container.read(routes);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: buildLightTheme(web: true).copyWith(platform: platform),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('every Settings page and every legal page declares its own page', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final routes =
        container.read(Provider(web.settingsRoutes)).whereType<GoRoute>();
    final pages = routes.where(
      (route) =>
          route.path.startsWith('/settings/') ||
          route.path.startsWith('/legal/'),
    );
    expect(pages.map((route) => route.path), contains('/legal/:doc'));
    expect(pages.map((route) => route.path), contains('/settings/pro'));
    for (final route in pages) {
      expect(route.pageBuilder, isNotNull, reason: route.path);
    }
    // The tab root stays an ordinary route inside the tab shell.
    expect(routes.singleWhere((r) => r.path == '/settings').builder, isNotNull);
  });

  Finder lists() => find.byKey(const ValueKey('settings-navigation'));
  Finder details() => find.byKey(const ValueKey('settings-detail'));
  Finder headings() => find.text('Settings');

  /// Taps a row of the list that is on top.
  Future<void> tapRow(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(of: lists().last, matching: find.text(label)).last,
    );
    // One frame puts the route in the Navigator, one builds it at 0 percent.
    await tester.pump();
    await tester.pump();
  }

  double opacityOfDetail(WidgetTester tester, int index) => tester
      .widget<Opacity>(
        find
            .ancestor(of: details().at(index), matching: find.byType(Opacity))
            .first,
      )
      .opacity;

  String where() =>
      router.routerDelegate.currentConfiguration.last.matchedLocation;

  const quarter = Duration(milliseconds: 60);
  const stops = [0.0, .25, .5, .75, 1.0];

  Future<void> chooseRowAndSample(WidgetTester tester) async {
    expect(headings(), findsOneWidget);
    final heading = tester.getRect(headings());
    final list = tester.getRect(lists());
    final detail = tester.getRect(details());

    await tapRow(tester, 'Practice');
    expect(where(), '/settings/practice');
    expect(details(), findsNWidgets(2));

    for (final stop in stops) {
      if (stop > 0) await tester.pump(quarter);
      final reason = 'at ${(stop * 100).round()} percent';
      expect(headings(), findsNWidgets(2), reason: reason);
      for (var i = 0; i < 2; i++) {
        expect(tester.getRect(headings().at(i)), heading, reason: reason);
        expect(tester.getRect(lists().at(i)), list, reason: reason);
      }
      // The first page's detail is leaving; the second's is arriving.
      expect(
        opacityOfDetail(tester, 0),
        closeTo(PaneMotion.outgoingOpacity(stop), .001),
        reason: reason,
      );
      expect(
        opacityOfDetail(tester, 1),
        closeTo(PaneMotion.incomingOpacity(stop), .001),
        reason: reason,
      );
      expect(tester.getRect(details().at(0)), detail, reason: reason);
      final arriving = tester.getRect(details().at(1));
      expect(arriving.left, detail.left, reason: reason);
      expect(arriving.width, detail.width, reason: reason);
      expect(
        arriving.top - detail.top,
        closeTo(PaneMotion.incomingLift(stop), .001),
        reason: reason,
      );
    }

    await tester.pumpAndSettle();
    expect(headings(), findsOneWidget);
    expect(tester.getRect(headings()), heading);
    expect(tester.getRect(lists()), list);
    expect(tester.getTopLeft(details()), detail.topLeft);
    expect(tester.getSize(details()).width, detail.width);
    expect(opacityOfDetail(tester, 0), 1);
  }

  for (final size in const [Size(1440, 620), Size(1100, 700)]) {
    testWidgets(
        'wide ${size.width.round()}: choosing a row moves only the detail',
        (tester) async {
      await pumpSettings(tester, size: size);
      await chooseRowAndSample(tester);
    });
  }

  testWidgets('wide: Back, Esc and the address work as before', (tester) async {
    await pumpSettings(tester);
    await tapRow(tester, 'Practice');
    await tester.pumpAndSettle();
    expect(where(), '/settings/practice');
    router.pop();
    await tester.pumpAndSettle();
    expect(where(), '/settings');

    // Esc leaves a page that has a Back link, as it does today.
    await tapRow(tester, 'About');
    await tester.pumpAndSettle();
    expect(where(), '/settings/about');
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
    expect(where(), '/legal/privacy');
    // A student presses Tab once to reach the page, then Esc.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(where(), '/settings/about');
  });

  testWidgets('wide: a deep link opens with the detail in place',
      (tester) async {
    await pumpSettings(tester, initial: '/settings/practice');
    expect(where(), '/settings/practice');
    expect(details(), findsOneWidget);
    expect(opacityOfDetail(tester, 0), 1);
    expect(find.text('How your sessions are put together.'), findsOneWidget);
  });

  testWidgets('wide: the list keeps its scroll position from row to row',
      (tester) async {
    await pumpSettings(tester, size: const Size(1440, 330));
    final scroller = find.ancestor(
      of: lists().first,
      matching: find.byType(SingleChildScrollView),
    );
    expect(
      tester
          .widget<SingleChildScrollView>(scroller.first)
          .controller!
          .position
          .maxScrollExtent,
      greaterThan(0),
      reason: 'the list must be taller than the window for this test',
    );
    await tester.drag(lists().first, const Offset(0, -80));
    await tester.pumpAndSettle();
    final offset =
        tester.widget<SingleChildScrollView>(scroller.first).controller!.offset;
    expect(offset, greaterThan(0));
    final list = tester.getRect(lists());
    expect(list.top, lessThan(0.0 + 330 - 200), reason: 'scrolled up');

    await tapRow(tester, 'Practice');
    for (final stop in stops) {
      if (stop > 0) await tester.pump(quarter);
      for (var i = 0; i < 2; i++) {
        expect(
          tester.getRect(lists().at(i)),
          list,
          reason: 'at ${(stop * 100).round()} percent',
        );
      }
    }
    await tester.pumpAndSettle();
    expect(tester.getRect(lists()), list);
    expect(
      ProviderScope.containerOf(tester.element(lists()))
          .read(settingsListOffsetProvider),
      closeTo(offset, .5),
    );
  });

  testWidgets('wide: reduced motion shows the final state at once',
      (tester) async {
    await pumpSettings(tester, reduced: true);
    final detail = tester.getRect(details());
    await tapRow(tester, 'Practice');
    expect(opacityOfDetail(tester, 1), 1);
    expect(opacityOfDetail(tester, 0), 1);
    expect(tester.getTopLeft(details().last), detail.topLeft);
    await tester.pumpAndSettle();
  });

  // Item 17, demo 4 (and item 15's "row tint fades 150 ms, the label stops
  // turning bold"): the page that opens rebuilds the list, so it starts with
  // the old row tinted and fades to the new one.
  group('item 17: the selected row fades', () {
    Finder row(WidgetTester tester, String label) => find.ancestor(
          of: find.descendant(of: lists().last, matching: find.text(label)),
          matching: find.byType(WebRow),
        );

    double tint(WidgetTester tester, String label) => tester
        .widget<ColoredBox>(
          find.descendant(
            of: find.descendant(
              of: row(tester, label),
              matching: find.byType(IgnorePointer),
            ),
            matching: find.byType(ColoredBox),
          ),
        )
        .color
        .a;

    Color? value(WidgetTester tester, String label, String text) => tester
        .widget<Text>(
          find.descendant(of: row(tester, label), matching: find.text(text)),
        )
        .style
        ?.color;

    testWidgets('the old tint fades out as the new one fades in, 150 ms',
        (tester) async {
      await pumpSettings(tester, initial: '/settings/pro');
      await tapRow(tester, 'Practice');
      // The first frame is the old list: Pro still tinted, Practice not.
      expect(tint(tester, 'Pantas Pro'), 1);
      expect(tint(tester, 'Practice'), 0);
      final accent = webAccent(tester);
      var elapsed = 0;
      for (final ms in [40, 40, 40]) {
        await tester.pump(Duration(milliseconds: ms));
        elapsed += ms;
        final p = previewEase(elapsed / 150);
        expect(tint(tester, 'Practice'), closeTo(p, .01), reason: '$elapsed');
        expect(
          tint(tester, 'Pantas Pro'),
          closeTo(1 - p, .01),
          reason: '$elapsed',
        );
        // The value turns accent together with the tint.
        final shown = value(tester, 'Practice', '10 questions')!;
        expect(shown.g, isNot(equals(accent.g)), reason: 'not yet at $elapsed');
      }
      await tester.pump(const Duration(milliseconds: 40));
      expect(tint(tester, 'Practice'), 1);
      expect(tint(tester, 'Pantas Pro'), 0);
      expect(value(tester, 'Practice', '10 questions'), accent);
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the label never turns bold', (tester) async {
      await pumpSettings(tester, initial: '/settings/pro');
      Iterable<FontWeight?> weights() => [
            for (final label in ['Pantas Pro', 'Practice', 'Appearance'])
              tester
                  .widget<Text>(
                    find.descendant(
                      of: lists().last,
                      matching: find.text(label),
                    ),
                  )
                  .style
                  ?.fontWeight,
          ];
      expect(weights().toSet(), {FontWeight.w400});
      await tapRow(tester, 'Practice');
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 40));
        expect(weights().toSet(), {FontWeight.w400}, reason: 'frame $i');
      }
      await tester.pumpAndSettle();
    });

    testWidgets('reduced motion shows the final tint in one frame',
        (tester) async {
      await pumpSettings(tester, initial: '/settings/pro', reduced: true);
      await tapRow(tester, 'Practice');
      expect(tint(tester, 'Practice'), 1);
      expect(tint(tester, 'Pantas Pro'), 0);
      expect(
        value(tester, 'Practice', '10 questions'),
        webAccent(tester),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('a deep link opens with the row already tinted',
        (tester) async {
      await pumpSettings(tester, initial: '/settings/practice');
      expect(tint(tester, 'Practice'), 1);
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  for (final platform in [TargetPlatform.macOS, TargetPlatform.iOS]) {
    testWidgets('phone, $platform: Settings keeps its own page slide',
        (tester) async {
      await pumpSettings(
        tester,
        size: const Size(390, 844),
        platform: platform,
      );
      final heading = tester.getRect(find.text('Settings').first);

      unawaited(router.push<void>('/settings/practice'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The new page comes in from the right, the old one drifts left.
      expect(
        tester.getRect(find.text('Practice').last).left,
        greaterThan(heading.left),
      );
      expect(find.byType(PaneDetailMotion), findsNothing);
      final route = ModalRoute.of(tester.element(find.text('Practice').last))!
          as PaneTransitionRoute<dynamic>;
      expect(route.transitionDuration, const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
    });
  }

  group('legal pages', () {
    Future<void> openLegal(WidgetTester tester) async {
      unawaited(router.push<void>('/legal/terms'));
      await tester.pump();
      await tester.pump();
    }

    testWidgets('wide, from About in Settings: it is a Settings detail',
        (tester) async {
      await pumpSettings(tester, initial: '/settings/about');
      final heading = tester.getRect(headings());
      final list = tester.getRect(lists());
      final detail = tester.getRect(details());
      await openLegal(tester);
      for (final stop in stops) {
        if (stop > 0) await tester.pump(quarter);
        final reason = 'at ${(stop * 100).round()} percent';
        for (var i = 0; i < 2; i++) {
          expect(tester.getRect(headings().at(i)), heading, reason: reason);
          expect(tester.getRect(lists().at(i)), list, reason: reason);
        }
        expect(
          opacityOfDetail(tester, 1),
          closeTo(PaneMotion.incomingOpacity(stop), .001),
          reason: reason,
        );
        expect(
          tester.getRect(details().at(1)).top - detail.top,
          closeTo(PaneMotion.incomingLift(stop), .001),
          reason: reason,
        );
      }
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(details()), detail.topLeft);
    });

    testWidgets('wide, from onboarding: the page fades, logo and frame still',
        (tester) async {
      await pumpSettings(tester, initial: '/onboarding', onboarding: true);
      expect(find.text('Terms and Privacy'), findsOneWidget);
      final logo = tester.getRect(find.byType(PantasLogo));
      final bar = tester.getRect(find.byType(WebTopBar));
      await openLegal(tester);
      expect(find.byType(OnboardingLegalPage), findsOneWidget);

      for (final stop in stops) {
        if (stop > 0) await tester.pump(quarter);
        final reason = 'at ${(stop * 100).round()} percent';
        expect(find.byType(PantasLogo), findsNWidgets(2), reason: reason);
        for (var i = 0; i < 2; i++) {
          expect(
            tester.getRect(find.byType(PantasLogo).at(i)),
            logo,
            reason: reason,
          );
          expect(
            tester.getRect(find.byType(WebTopBar).at(i)),
            bar,
            reason: reason,
          );
        }
        final fade = tester.widget<FadeTransition>(
          find
              .ancestor(
                of: find.byType(OnboardingLegalPage),
                matching: find.byType(FadeTransition),
              )
              .first,
        );
        expect(
          fade.opacity.value,
          closeTo(PaneMotion.fadeOpacity(stop), .001),
          reason: reason,
        );
        // Nothing slides: the title column does not move sideways either.
        expect(
          tester.getRect(find.text('Back')).left,
          tester.getRect(find.text('Back')).left,
        );
      }
      await tester.pumpAndSettle();
      expect(find.byType(PantasLogo), findsOneWidget);
      expect(tester.getRect(find.byType(PantasLogo)), logo);
      expect(where(), '/legal/terms');

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(where(), '/onboarding');
    });

    testWidgets('wide, reduced motion: the page is there at once',
        (tester) async {
      await pumpSettings(
        tester,
        initial: '/onboarding',
        onboarding: true,
        reduced: true,
      );
      await openLegal(tester);
      expect(
        find.ancestor(
          of: find.byType(OnboardingLegalPage),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );
      await tester.pumpAndSettle();
    });

    testWidgets('phone: the legal page keeps the platform slide',
        (tester) async {
      await pumpSettings(
        tester,
        size: const Size(390, 844),
        initial: '/onboarding',
        onboarding: true,
        platform: TargetPlatform.iOS,
      );
      final logo = tester.getRect(find.byType(PantasLogo));
      await openLegal(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(OnboardingLegalPage), findsNothing);
      expect(
        tester.getRect(find.byType(PantasLogo).first).left,
        lessThan(logo.left),
      );
      await tester.pumpAndSettle();
    });

    testWidgets('portrait tablet: the legal page keeps the platform slide',
        (tester) async {
      await pumpSettings(
        tester,
        size: const Size(800, 1000),
        initial: '/onboarding',
        onboarding: true,
      );
      final logo = tester.getRect(find.byType(PantasLogo));
      await openLegal(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        tester.getRect(find.byType(PantasLogo).first).left,
        lessThan(logo.left),
      );
      await tester.pumpAndSettle();
    });
  });
}
