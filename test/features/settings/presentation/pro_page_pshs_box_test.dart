// Under-13 build T9: the checkout box on every PSHS-NCE purchase, any age
// group, and the child's name under the buy button. The client table has no
// PSHS-NCE product yet, so these tests give the page a fake one.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/time/study_days.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';
import 'package:pantas/features/settings/settings.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

const _pshsPass = 'pantas_pass_pshs_nce';
const _minorLabel = 'I am the parent or guardian and accept the Terms.';
const _buyPass = 'Buy Season Pass';
const _buyMonth = 'Buy 1 Month for ₱149';

/// Records what the page asked the gateway for. The real pass check reads the
/// client product table, which has no PSHS-NCE product yet.
class _RecordingGateway extends WebPaymentGateway {
  _RecordingGateway()
      : super(
          callable: (name, data) async => <String, Object?>{},
          readGrants: (_) async => [],
          refreshClaims: (_) async {},
          openUrl: (_) async => true,
        );

  final passCalls = <({bool guardian, bool box})>[];
  final calls = <({bool guardian, bool box})>[];

  @override
  Future<PaymentOperationResult> purchasePass(
    PaywallPassPackage package, {
    required ExamCatalogEntry exam,
    Future<void> Function(String sessionId, String reference)? beforeRedirect,
    bool guardianAttested = false,
    bool checkoutBoxAttested = false,
  }) async {
    passCalls.add((guardian: guardianAttested, box: checkoutBoxAttested));
    return const PaymentOperationResult.failure(
      status: PaymentOperationStatus.operationAlreadyInProgress,
    );
  }

  @override
  Future<PaymentOperationResult> purchase(
    PaywallPackage package, {
    Future<void> Function(String sessionId, String reference)? beforeRedirect,
    bool guardianAttested = false,
    bool checkoutBoxAttested = false,
  }) async {
    calls.add((guardian: guardianAttested, box: checkoutBoxAttested));
    return const PaymentOperationResult.failure(
      status: PaymentOperationStatus.operationAlreadyInProgress,
    );
  }
}

ProductDefinition? _lookup(String id) => id == _pshsPass
    ? const ProductDefinition(
        tier: PriceTier.student,
        kind: ProductKind.pass,
        examId: 'exam_pshs_nce',
      )
    : productForId(id);

void main() {
  late _RecordingGateway gateway;

  Future<void> pumpPro(
    WidgetTester tester, {
    required String? group,
    required bool wide,
    String? name,
  }) async {
    if (wide) {
      debugWebPlatformOverride = true;
      addTearDown(() => debugWebPlatformOverride = null);
    }
    tester.view
      ..physicalSize = wide ? const Size(1440, 900) : const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view
        ..resetPhysicalSize()
        ..resetDevicePixelRatio();
    });
    final db = inMemoryDatabase();
    addTearDown(db.close);
    gateway = _RecordingGateway();
    await gateway.logIn('owner');
    final day = DateTime.now().add(const Duration(days: 40));
    final sittingDay = DateTime.utc(day.year, day.month, day.day);
    await tester.pumpAppWithProviders(
      const ProPage(),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        currentUserProvider.overrideWith(
          (ref) async => const AuthUser(
            uid: 'owner',
            email: 'o@example.com',
            displayName: 'Owner',
          ),
        ),
        isAnonymousProvider.overrideWith((ref) async => false),
        paymentsOnWebProvider.overrideWithValue(true),
        ageGroupProvider.overrideWith((ref) async => AgeGroup.parse(group)),
        userSettingsProvider.overrideWith(
          (ref) async => UserSettings(
            name: name,
            dailyReminderTime: null,
            studyDays: StudyDays.all,
            examDate: null,
            strictMockMode: false,
            helpImproveApp: false,
            carryOverProgress: true,
            sessionOrdering: SessionOrdering.interleavedTail,
            retainTableOrder: true,
            updatedAt: null,
          ),
        ),
        revenueCatGatewayProvider.overrideWithValue(gateway),
        proPageProductLookupProvider.overrideWithValue(_lookup),
        proForActiveExamProvider.overrideWith((ref) async => false),
        activeExamFocusProvider.overrideWith(
          (ref) async => ActiveExamFocus.selected(
            buildExam(id: 'exam_pshs_nce', shortName: 'PSHS-NCE'),
          ),
        ),
        activeProCatalogEntryProvider.overrideWith(
          (ref) async => ExamCatalogEntry(
            id: 'exam_pshs_nce',
            name: 'PSHS-NCE',
            shortName: 'PSHS-NCE',
            priceTier: 'Student',
            group: 'High school',
            comingSoon: false,
            publishedSittings: [
              PublishedExamSitting(
                firstDay: sittingDay,
                lastDay: sittingDay,
                sourceUrl: 'https://pshs.example.test',
              ),
            ],
            hasContent: true,
          ),
        ),
        paywallOfferingProvider.overrideWith(
          (ref) async => const PaywallOfferingResult(
            status: PaywallOfferingStatus.available,
            recognizedPackages: [
              PaywallPackage(
                sku: PaywallSku.monthly,
                productId: 'pantas_pro_monthly',
                priceString: '₱149',
                priceAmount: 149,
              ),
            ],
            passPackages: [
              PaywallPassPackage(
                productId: _pshsPass,
                priceString: '₱1,499',
                priceAmount: 1499,
              ),
            ],
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();
    // Test fonts overflow one wide-web row in some cases; not under test.
    tester.takeException();
  }

  Finder box(String label) => find.byWidgetPredicate(
        (w) => w is CheckboxRow && w.title == label,
      );

  Future<void> choosePass(WidgetTester tester) async {
    final tile = find.text('Season Pass').first;
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  Future<void> chooseMonthly(WidgetTester tester) async {
    final tile = find.textContaining('Monthly').first;
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pump();
  }

  VoidCallback? buyPressed(
    WidgetTester tester,
    String label, {
    required bool wide,
  }) =>
      wide
          ? tester
              .widget<WebButton>(find.widgetWithText(WebButton, label))
              .onPressed
          : tester
              .widget<PantasButton>(find.widgetWithText(PantasButton, label))
              .onPressed;

  Future<void> tick(WidgetTester tester, Finder box) async {
    await tester.ensureVisible(box);
    await tester.tap(box);
    await tester.pump();
  }

  Future<void> buy(
    WidgetTester tester,
    String label, {
    required bool wide,
  }) async {
    await tester.tap(
      wide
          ? find.widgetWithText(WebButton, label)
          : find.widgetWithText(PantasButton, label),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  for (final wide in [false, true]) {
    final where = wide ? 'wide web' : 'phone';
    for (final group in ['adult', 'minor', 'child']) {
      testWidgets(
          'a PSHS-NCE pass shows the checkout box and needs the tick for '
          'a $group, $where', (tester) async {
        await pumpPro(tester, group: group, wide: wide);
        await choosePass(tester);
        expect(box(checkoutBoxText), findsOneWidget);
        expect(box(_minorLabel), findsNothing);
        expect(
          tester.widget<CheckboxRow>(box(checkoutBoxText)).selected,
          isFalse,
        );
        expect(buyPressed(tester, _buyPass, wide: wide), isNull);
        await tick(tester, box(checkoutBoxText));
        expect(buyPressed(tester, _buyPass, wide: wide), isNotNull);
      });

      testWidgets(
          'buying a PSHS-NCE pass sends the box text version for a $group, '
          '$where', (tester) async {
        await pumpPro(tester, group: group, wide: wide);
        await choosePass(tester);
        await tick(tester, box(checkoutBoxText));
        await buy(tester, _buyPass, wide: wide);
        expect(gateway.passCalls, [(guardian: false, box: true)]);
      });
    }

    testWidgets('an adult sees no box on a plan for the same exam, $where',
        (tester) async {
      await pumpPro(tester, group: 'adult', wide: wide);
      await chooseMonthly(tester);
      expect(box(checkoutBoxText), findsNothing);
      expect(box(_minorLabel), findsNothing);
      expect(buyPressed(tester, _buyMonth, wide: wide), isNotNull);
      await buy(tester, _buyMonth, wide: wide);
      expect(gateway.calls, [(guardian: false, box: false)]);
    });

    testWidgets('a minor keeps the old box on a plan, unchanged, $where',
        (tester) async {
      await pumpPro(tester, group: 'minor', wide: wide);
      await chooseMonthly(tester);
      expect(box(_minorLabel), findsOneWidget);
      expect(box(checkoutBoxText), findsNothing);
      expect(buyPressed(tester, _buyMonth, wide: wide), isNull);
      await tick(tester, box(_minorLabel));
      await buy(tester, _buyMonth, wide: wide);
      expect(gateway.calls, [(guardian: true, box: false)]);
    });

    testWidgets('a tick on one box does not carry to the other, $where',
        (tester) async {
      await pumpPro(tester, group: 'minor', wide: wide);
      await chooseMonthly(tester);
      await tick(tester, box(_minorLabel));
      expect(buyPressed(tester, _buyMonth, wide: wide), isNotNull);
      await choosePass(tester);
      expect(
        tester.widget<CheckboxRow>(box(checkoutBoxText)).selected,
        isFalse,
      );
      expect(buyPressed(tester, _buyPass, wide: wide), isNull);
    });

    testWidgets('a child sees whose pass it is under the buy button, $where',
        (tester) async {
      await pumpPro(tester, group: 'child', wide: wide, name: 'Nico');
      await choosePass(tester);
      expect(find.text('This pass is for Nico.'), findsOneWidget);
    });

    testWidgets('an adult sees no name line, $where', (tester) async {
      await pumpPro(tester, group: 'adult', wide: wide, name: 'Nico');
      await choosePass(tester);
      expect(find.textContaining('This pass is for'), findsNothing);
    });

    testWidgets('a child sees no name line on a plan, $where', (tester) async {
      await pumpPro(tester, group: 'child', wide: wide, name: 'Nico');
      await chooseMonthly(tester);
      expect(find.textContaining('This pass is for'), findsNothing);
    });

    testWidgets('a child with no name gets no empty line, $where',
        (tester) async {
      await pumpPro(tester, group: 'child', wide: wide);
      await choosePass(tester);
      expect(find.textContaining('This pass is for'), findsNothing);
    });
  }
}
