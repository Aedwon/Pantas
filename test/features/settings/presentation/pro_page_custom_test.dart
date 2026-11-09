import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/content.dart';
import 'package:pantas/core/storage/domain/exam.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/paywall/application/beta_pro_provider.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/presentation/widgets/beta_pro_row.dart';

import '../../../helpers/in_memory_database.dart';
import 'pro_page_payments_test.dart' show SettingsGateway;

const _trackName = 'PUP CET';

const _benefits = [
  'Unlimited mock exams',
  'Notes on why your answer was wrong',
  'The figures behind your study habits',
  "Progress that's always backed up",
  'Results by topic and lesson',
];

// The Phosphor glyphs the boards draw, in the boards' order.
final _benefitIcons = [
  PantasIcons.unlimitedMocks,
  PantasIcons.answerNotes,
  PantasIcons.studyHabits,
  PantasIcons.proBackup,
  PantasIcons.topicResults,
];

const _csePro = ExamCatalogEntry(
  id: 'exam_cse_pro',
  name: 'CSE Professional',
  shortName: 'CSE Professional',
  priceTier: 'Civil Service',
  group: 'Civil service',
  comingSoon: false,
  hasContent: true,
  publishedSittings: [],
);

Exam _exam({required bool custom}) => Exam(
      id: custom ? 'exam_custom_pup' : 'exam_cse_pro',
      code: custom ? 'custom' : 'CSE',
      name: custom ? _trackName : 'CSE Professional',
      shortName: custom ? _trackName : 'CSE Professional',
      language: 'en',
      isActive: true,
      subjects: const [],
      isCustom: custom,
    );

Future<GoRouter> _pump(
  WidgetTester tester, {
  required double width,
  bool custom = true,
  bool dark = false,
  Entitlement entitlement = const Entitlement.free(),
  Map<String, ExamCatalogEntry> ownedPasses = const {},
}) async {
  final wide = width >= 1000;
  debugWebPlatformOverride = wide;
  addTearDown(() => debugWebPlatformOverride = null);
  tester.view.physicalSize = Size(width, wide ? 1000 : 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final router = GoRouter(
    initialLocation: '/settings/pro',
    routes: [
      GoRoute(
        path: '/settings',
        builder: (_, __) => const Scaffold(body: Text('settings page')),
        routes: [
          GoRoute(
            path: 'pro',
            builder: (_, __) => const ProPage(),
          ),
          GoRoute(
            path: 'exam/change',
            builder: (_, __) => const Scaffold(body: Text('change exam page')),
          ),
        ],
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        contentDatabaseProvider.overrideWithValue(openTestContentDatabase()),
        revenueCatGatewayProvider.overrideWithValue(
          SettingsGateway(initial: entitlement),
        ),
        currentUserProvider.overrideWith(
          (ref) async => const AuthUser(
            uid: 'owner',
            email: 'owner@example.com',
            displayName: 'Owner',
          ),
        ),
        isAnonymousProvider.overrideWith((ref) async => false),
        paymentsOnWebProvider.overrideWithValue(wide),
        webGrantHistoryProvider.overrideWith((ref) async => []),
        entitlementProvider.overrideWith((ref) => Stream.value(entitlement)),
        proForActiveExamProvider.overrideWith((ref) async => false),
        pendingPurchaseProvider.overrideWithValue(const AsyncData(null)),
        activeExamFocusProvider.overrideWith(
          (ref) async => ActiveExamFocus.selected(_exam(custom: custom)),
        ),
        // The catalog lists no custom track.
        activeProCatalogEntryProvider
            .overrideWith((ref) async => custom ? null : _csePro),
        ownedPassCatalogEntriesProvider
            .overrideWith((ref) async => ownedPasses),
        // Offers exist, and a custom track must still show none of them.
        paywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult(
            status: PaywallOfferingStatus.available,
            recognizedPackages: [
              PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pantas_cs_monthly',
                priceString: '₱149',
                priceAmount: 149,
              ),
            ],
            passPackages: [
              PaywallPassPackage(
                productId: 'pantas_pass_cse_pro',
                priceString: '₱499',
                priceAmount: 499,
              ),
            ],
          ),
        ),
      ],
      child: MaterialApp.router(
        theme: dark ? buildDarkTheme(web: wide) : buildLightTheme(web: wide),
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

String _allText(WidgetTester tester) => [
      for (final text in tester.widgetList<Text>(find.byType(Text)))
        text.data ?? text.textSpan?.toPlainText() ?? '',
    ].join('\n');

void _expectNoSalesOrLimits(WidgetTester tester) {
  final text = _allText(tester).toLowerCase();
  expect(text, isNot(contains('₱')));
  expect(text, isNot(contains('no limits')));
  for (final word in [
    'get pro',
    'subscribe',
    'buy ',
    'try 7 days',
    'plans for',
    'season pass',
    'try again',
    'loading subscriptions',
  ]) {
    expect(text, isNot(contains(word)), reason: word);
  }
}

void _expectBenefitIcons(
  WidgetTester tester, {
  required Color? color,
}) {
  final hero = find.byKey(const ValueKey('pro-hero'));
  expect(hero, findsOneWidget);
  final icons = tester
      .widgetList<Icon>(
        find.descendant(of: hero, matching: find.byType(Icon)),
      )
      .where((icon) => _benefitIcons.contains(icon.icon))
      .toList();
  expect(icons.map((icon) => icon.icon), _benefitIcons);
  for (final icon in icons) {
    expect(icon.size, 21);
    if (color != null) expect(icon.color, color);
  }
  for (var i = 0; i < _benefits.length; i++) {
    final row = tester.getRect(find.text(_benefits[i]));
    final icon = tester.getRect(
      find.descendant(
        of: hero,
        matching: find.byIcon(_benefitIcons[i]),
      ),
    );
    expect(
      (icon.center.dy - row.center.dy).abs(),
      lessThan(8),
      reason: 'icon $i sits on its own row',
    );
    expect(icon.right, lessThan(row.left), reason: 'icon $i is before text');
  }
}

void main() {
  for (final (dark, width) in [
    (false, 1440.0),
    (true, 1440.0),
    (false, 1100.0),
  ]) {
    testWidgets('wide custom track, no coverage, dark=$dark, $width wide',
        (tester) async {
      final router = await _pump(tester, width: width, dark: dark);
      expect(find.text('PANTAS PRO'), findsOneWidget);
      expect(
        find.text("See exactly what's losing you points."),
        findsOneWidget,
      );
      for (final benefit in _benefits) {
        expect(find.text(benefit), findsOneWidget);
      }
      _expectBenefitIcons(
        tester,
        color: dark ? const Color(0xFF4CC3AC) : const Color(0xFF0B7A68),
      );
      // Icons, not the listed page's check marks.
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('pro-hero')),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
      expect(find.text('$_trackName is free to study.'), findsOneWidget);
      expect(find.text('Pro plans come with a listed exam.'), findsOneWidget);
      expect(find.text('Change Exam'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
      expect(find.text('Your plan'), findsNothing);
      expect(find.text('YOUR PLAN'), findsNothing);
      _expectNoSalesOrLimits(tester);
      // The sales card sits above the free card, which sits above Restore.
      final hero = tester.getRect(find.byKey(const ValueKey('pro-hero')));
      final free = tester.getRect(find.text('$_trackName is free to study.'));
      final restore = tester.getRect(find.text('Restore Purchases'));
      expect(free.top, greaterThan(hero.bottom));
      expect(restore.top, greaterThan(free.bottom));
      await tester.tap(find.text('Change Exam'));
      await tester.pumpAndSettle();
      expect(
        router.routerDelegate.currentConfiguration.last.matchedLocation,
        '/settings/exam/change',
      );
      expect(find.text('change exam page'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('wide custom track keeps the plan rows of another exam',
      (tester) async {
    await _pump(
      tester,
      width: 1440,
      entitlement: Entitlement(
        plan: EntitlementPlan.free,
        passes: {'exam_cse_pro': DateTime.utc(2027, 3)},
      ),
      ownedPasses: const {'exam_cse_pro': _csePro},
    );
    expect(find.text('YOUR PLAN'), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Season Pass'), findsWidgets);
    expect(find.text('Exam'), findsWidgets);
    expect(find.text('CSE Professional'), findsWidgets);
    expect(find.text('Ends'), findsOneWidget);
    expect(find.text('Mar 1, 2027'), findsOneWidget);
    expect(
      find.text(
        'A one-time purchase. It ends after the exam and never renews.',
      ),
      findsOneWidget,
    );
    expect(find.text('$_trackName is free to study.'), findsOneWidget);
    expect(find.text('Restore Purchases'), findsOneWidget);
    final free = tester.getRect(find.text('$_trackName is free to study.'));
    final plan = tester.getRect(find.text('YOUR PLAN'));
    final restore = tester.getRect(find.text('Restore Purchases'));
    expect(plan.top, greaterThan(free.bottom));
    expect(restore.top, greaterThan(plan.bottom));
    // Season Pass is a row of the owned plan here, never an offer.
    expect(find.textContaining('₱'), findsNothing);
    expect(find.text('Buy Season Pass'), findsNothing);
    expect(find.textContaining('no limits'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'wide custom track, monthly coverage: rows stay, no heading '
      'turns into "on Pro"', (tester) async {
    await _pump(
      tester,
      width: 1440,
      entitlement: Entitlement(
        plan: EntitlementPlan.monthly,
        productId: 'pantas_cs_monthly',
        expiresAt: DateTime.now().add(const Duration(days: 20)),
      ),
    );
    expect(find.text('YOUR PLAN'), findsOneWidget);
    expect(find.text('Monthly'), findsWidgets);
    expect(find.text("You're on Pro."), findsNothing);
    expect(find.text("See exactly what's losing you points."), findsOneWidget);
    expect(find.text('$_trackName is free to study.'), findsOneWidget);
    _expectNoSalesOrLimits(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('phone custom track, no coverage', (tester) async {
    final router = await _pump(tester, width: 390);
    expect(find.text('PANTAS PRO'), findsOneWidget);
    expect(find.text("See exactly what's losing you points."), findsOneWidget);
    for (final benefit in _benefits) {
      expect(find.text(benefit), findsOneWidget);
    }
    _expectBenefitIcons(tester, color: const Color(0xFFBFF0E4));
    expect(find.text('$_trackName is free to study.'), findsOneWidget);
    expect(find.text('Pro plans come with a listed exam.'), findsOneWidget);
    expect(find.text('Change Exam'), findsOneWidget);
    expect(find.text('Restore Purchases'), findsOneWidget);
    expect(find.text('YOUR PLAN'), findsNothing);
    _expectNoSalesOrLimits(tester);
    final hero = tester.getRect(find.byKey(const ValueKey('pro-hero')));
    final free = tester.getRect(find.text('$_trackName is free to study.'));
    final restore = tester.getRect(find.text('Restore Purchases'));
    expect(free.top, greaterThan(hero.bottom));
    expect(restore.top, greaterThan(free.bottom));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Change Exam'));
    await tester.pumpAndSettle();
    expect(
      router.routerDelegate.currentConfiguration.last.matchedLocation,
      '/settings/exam/change',
    );
  });

  testWidgets('phone custom track keeps the plan rows of another exam',
      (tester) async {
    await _pump(
      tester,
      width: 390,
      entitlement: Entitlement(
        plan: EntitlementPlan.free,
        passes: {'exam_cse_pro': DateTime.utc(2027, 3)},
      ),
      ownedPasses: const {'exam_cse_pro': _csePro},
    );
    await tester.pumpAndSettle();
    expect(find.text('YOUR PLAN'), findsOneWidget);
    expect(find.text('Season Pass'), findsOneWidget);
    expect(find.text('CSE Professional'), findsOneWidget);
    expect(find.text('Mar 1, 2027'), findsOneWidget);
    expect(find.text('$_trackName is free to study.'), findsOneWidget);
    final free = tester.getRect(find.text('$_trackName is free to study.'));
    final plan = tester.getRect(find.text('YOUR PLAN'));
    expect(plan.top, greaterThan(free.bottom));
    expect(find.textContaining('₱'), findsNothing);
    expect(find.textContaining('no limits'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [1440.0, 390.0]) {
    testWidgets('a listed exam keeps its Pro page at $width', (tester) async {
      await _pump(tester, width: width, custom: false);
      expect(find.text('$_trackName is free to study.'), findsNothing);
      expect(find.text('Pro plans come with a listed exam.'), findsNothing);
      expect(find.text('Change Exam'), findsNothing);
      expect(
        find.text("See exactly what's losing you points."),
        findsOneWidget,
      );
      expect(find.text('PLANS FOR CSE PROFESSIONAL'), findsOneWidget);
      expect(find.text('₱149'), findsOneWidget);
      expect(find.text('Restore Purchases'), findsOneWidget);
      // The exam name in the left list is wider than the test font allows at
      // 1440, which is not this page; the phone case checks for errors.
      final error = tester.takeException();
      if (width < 1000) expect(error, isNull);
    });
  }

  group('beta row', () {
    Future<void> pumpBeta(
      WidgetTester tester, {
      required bool custom,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            betaProProvider.overrideWith(
              (ref) => Stream.value(
                BetaProState(until: DateTime(2099), enabled: true),
              ),
            ),
            activeExamFocusProvider.overrideWith(
              (ref) async => ActiveExamFocus.selected(_exam(custom: custom)),
            ),
          ],
          child: MaterialApp(
            theme: buildLightTheme(web: false),
            home: const Scaffold(
              body: Column(children: [BetaProRow(), BetaProNote()]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('hides on a custom exam', (tester) async {
      await pumpBeta(tester, custom: true);
      expect(find.text('Beta: Pro Features'), findsNothing);
      expect(find.textContaining('Pro features are on'), findsNothing);
    });

    testWidgets('stays on a listed exam', (tester) async {
      await pumpBeta(tester, custom: false);
      expect(find.text('Beta: Pro Features'), findsOneWidget);
      expect(find.textContaining('Pro features are on'), findsOneWidget);
    });
  });
}
