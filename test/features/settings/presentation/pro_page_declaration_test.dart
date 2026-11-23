import 'dart:ui' show CheckedState;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/app/theme.dart';
import 'package:pantas/core/auth/auth_user.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/legal/domain/legal_document.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/paywall.dart';
import 'package:pantas/features/settings/presentation/pages/pro_page.dart';

import '../../../helpers/in_memory_database.dart';
import '../../../helpers/pump_app.dart';

const _adultLabel =
    "I'm 18+, authorized to use the payment method, and accept the "
    'Terms and refund policy.';
const _guardianLabel =
    "I'm 18+ and buying for this student as their parent or legal guardian. "
    "I'm authorized to use the payment method and accept the "
    'Terms and refund policy.';
const _link = 'Terms and refund policy';
const _buy = 'Buy 1 Month for ₱149';
const _generic = "We couldn't confirm your subscription. Try again.";

final _guardianSignal = StateProvider<bool>((ref) => false);
final _accountSignal = StateProvider<String>((ref) => 'owner');

void main() {
  late List<(String, Map<String, Object?>)> calls;
  Exception? refusal;

  setUp(() {
    calls = [];
    refusal = null;
  });

  Future<void> pumpPro(
    WidgetTester tester, {
    required bool wide,
    bool guardian = false,
    bool trialEligible = false,
    bool router = false,
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
    final gateway = WebPaymentGateway(
      callable: (name, data) async {
        calls.add((name, data));
        final failure = refusal;
        if (failure != null) throw failure;
        return <String, Object?>{
          'checkoutUrl': 'https://pay.example.test/ck_1',
          'sessionId': 'cs_1',
          'reference': 'ref_1',
        };
      },
      readGrants: (_) async => [],
      refreshClaims: (_) async {},
      openUrl: (_) async => true,
    );
    await gateway.logIn('owner');
    final overrides = [
      appDatabaseProvider.overrideWithValue(db),
      currentUserProvider.overrideWith(
        (ref) async => AuthUser(
          uid: ref.watch(_accountSignal),
          email: 'o@example.com',
          displayName: 'Owner',
        ),
      ),
      isAnonymousProvider.overrideWith((ref) async => false),
      paymentsOnWebProvider.overrideWithValue(true),
      guardianConfirmedProvider.overrideWith(
        (ref) async => guardian || ref.watch(_guardianSignal),
      ),
      revenueCatGatewayProvider.overrideWithValue(gateway),
      proForActiveExamProvider.overrideWith((ref) async => false),
      activeExamFocusProvider.overrideWith(
        (ref) async => ActiveExamFocus.selected(
          buildExam(id: 'exam_cse_pro', shortName: 'CSE Professional'),
        ),
      ),
      activeProCatalogEntryProvider.overrideWith(
        (ref) async => const ExamCatalogEntry(
          id: 'exam_cse_pro',
          name: 'CSE Professional',
          shortName: 'CSE Professional',
          priceTier: 'Civil Service',
          group: 'Civil service',
          comingSoon: false,
          publishedSittings: [],
          hasContent: true,
        ),
      ),
      paywallOfferingProvider.overrideWith(
        (ref) async => PaywallOfferingResult(
          status: PaywallOfferingStatus.available,
          recognizedPackages: [
            PaywallPackage(
              sku: PaywallSku.monthly,
              productId: 'pantas_cs_monthly',
              priceString: '₱149',
              priceAmount: 149,
              trialEligible: trialEligible,
            ),
            const PaywallPackage(
              sku: PaywallSku.yearly,
              productId: 'pantas_cs_yearly',
              priceString: '₱1,199',
              priceAmount: 1199,
            ),
          ],
        ),
      ),
    ];
    if (router) {
      final goRouter = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, __) => const ProPage()),
          GoRoute(
            path: '/legal/terms',
            builder: (_, __) => const Scaffold(body: Text('The Terms page')),
          ),
        ],
      );
      addTearDown(goRouter.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: overrides,
          child: MaterialApp.router(
            theme: appLightTheme(),
            routerConfig: goRouter,
          ),
        ),
      );
    } else {
      await tester.pumpAppWithProviders(const ProPage(), overrides: overrides);
    }
    await tester.pumpAndSettle();
    // Test fonts overflow one wide-web row in some cases; not under test.
    tester.takeException();
  }

  VoidCallback? buyPressed(WidgetTester tester, {required bool wide}) => wide
      ? tester.widget<WebButton>(find.widgetWithText(WebButton, _buy)).onPressed
      : tester
          .widget<PantasButton>(find.widgetWithText(PantasButton, _buy))
          .onPressed;

  /// A started checkout leaves the page spinning until the tab leaves, so
  /// the page never settles; a few frames are enough for the call and result.
  Future<void> afterBuy(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Finder box([String label = _adultLabel]) => find.byWidgetPredicate(
        (w) => w is CheckboxRow && w.title == label,
      );

  Finder anyBox() => find.byType(CheckboxRow);

  Future<void> tick(WidgetTester tester) async {
    await tester.ensureVisible(anyBox());
    await tester.tapAt(tester.getTopLeft(anyBox()) + const Offset(14, 20));
    await tester.pump();
  }

  Future<void> buy(WidgetTester tester, {required bool wide}) async {
    await tester.tap(
      wide
          ? find.widgetWithText(WebButton, _buy)
          : find.widgetWithText(PantasButton, _buy),
    );
    await afterBuy(tester);
  }

  for (final wide in [false, true]) {
    final where = wide ? 'wide web' : 'phone';

    testWidgets('every web buyer sees the adult declaration, unticked, $where',
        (tester) async {
      await pumpPro(tester, wide: wide);
      expect(box(), findsOneWidget);
      expect(tester.widget<CheckboxRow>(box()).selected, isFalse);
    });

    testWidgets('a confirmed guardian sees the guardian wording, $where',
        (tester) async {
      await pumpPro(tester, wide: wide, guardian: true);
      expect(box(_guardianLabel), findsOneWidget);
      expect(box(), findsNothing);
      expect(tester.widget<CheckboxRow>(box(_guardianLabel)).selected, isFalse);
    });

    testWidgets('Pay is off until the box is ticked, $where', (tester) async {
      await pumpPro(tester, wide: wide);
      expect(buyPressed(tester, wide: wide), isNull);
      await tick(tester);
      expect(buyPressed(tester, wide: wide), isNotNull);
      await tick(tester);
      expect(buyPressed(tester, wide: wide), isNull);
    });

    testWidgets('buying sends the adult declaration, $where', (tester) async {
      await pumpPro(tester, wide: wide);
      await tick(tester);
      await buy(tester, wide: wide);
      expect(calls.single.$1, 'createPaymongoCheckout');
      expect(calls.single.$2, {
        'product': 'pantas_cs_monthly',
        'declaration': {
          'kind': 'adult',
          'wordingVersion': 'checkout-adult-2026-11-23',
          'termsVersion': guardianDocumentVersions['terms'],
        },
      });
    });

    testWidgets(
        'buying with a confirmed guardian sends the guardian one, '
        '$where', (tester) async {
      await pumpPro(tester, wide: wide, guardian: true);
      await tick(tester);
      await buy(tester, wide: wide);
      expect(
        (calls.single.$2['declaration']! as Map)['kind'],
        'guardian',
      );
      expect(
        (calls.single.$2['declaration']! as Map)['wordingVersion'],
        'checkout-guardian-2026-11-23',
      );
    });

    testWidgets(
        'the seller line sits beside Pay with visible placeholders, '
        '$where', (tester) async {
      await pumpPro(tester, wide: wide);
      final line = find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText() ==
                'Sold by Aerol Dwayne Daños Balayon, trading as '
                    '[registered business name] · [full place of business] · '
                    '[business phone] · support@pantas.study',
      );
      expect(line, findsOneWidget);
    });

    testWidgets(
        'the free trial takes no payment, so no box and no seller line, '
        '$where', (tester) async {
      await pumpPro(tester, wide: wide, trialEligible: true);
      expect(find.text('Try 7 Days Free'), findsWidgets);
      expect(anyBox(), findsNothing);
      expect(find.textContaining('Sold by'), findsNothing);
    });

    testWidgets(
        'the server naming the other wording swaps it and unticks, '
        '$where', (tester) async {
      refusal = FirebaseFunctionsException(
        message: 'Confirm the declaration to continue.',
        code: 'failed-precondition',
        details: const {'reason': 'declaration-required', 'kind': 'guardian'},
      );
      await pumpPro(tester, wide: wide);
      await tick(tester);
      await buy(tester, wide: wide);
      expect(box(_guardianLabel), findsOneWidget);
      expect(tester.widget<CheckboxRow>(box(_guardianLabel)).selected, isFalse);
      expect(buyPressed(tester, wide: wide), isNull);
      expect(
        find.text('Read the box again, then tick it to pay.'),
        findsOneWidget,
      );
      expect(find.text(_generic), findsNothing);
    });

    testWidgets('any other refusal keeps the generic line, $where',
        (tester) async {
      refusal = FirebaseFunctionsException(
        message: 'Something else.',
        code: 'failed-precondition',
        details: const {'reason': 'other'},
      );
      await pumpPro(tester, wide: wide);
      await tick(tester);
      await buy(tester, wide: wide);
      expect(find.text(_generic), findsOneWidget);
      expect(
        find.text('Read the box again, then tick it to pay.'),
        findsNothing,
      );
    });
  }

  for (final guardian in [false, true]) {
    final label = guardian ? _guardianLabel : _adultLabel;
    final who = guardian ? 'guardian wording' : 'adult wording';

    testWidgets('a tap on the link opens the Terms and changes nothing, $who',
        (tester) async {
      await pumpPro(tester, wide: false, guardian: guardian, router: true);
      await tester.ensureVisible(box(label));
      await tester.tap(find.text(_link));
      await tester.pumpAndSettle();
      expect(find.text('The Terms page'), findsOneWidget);
      // Back on the page, the box is still unticked and Pay is still off.
      tester.element(find.text('The Terms page')).pop();
      await tester.pumpAndSettle();
      expect(tester.widget<CheckboxRow>(box(label)).selected, isFalse);
      expect(buyPressed(tester, wide: false), isNull);
    });

    testWidgets(
        'the link takes keyboard focus and Enter opens the Terms, '
        '$who', (tester) async {
      await pumpPro(tester, wide: false, guardian: guardian, router: true);
      await tester.ensureVisible(box(label));
      Focus.of(tester.element(find.text(_link))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('The Terms page'), findsOneWidget);
    });
  }

  testWidgets(
      'a tick belongs to the wording it was given for: a changed '
      'wording unticks and turns Pay off', (tester) async {
    await pumpPro(tester, wide: false);
    await tick(tester);
    expect(buyPressed(tester, wide: false), isNotNull);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProPage)),
    );
    container.read(_guardianSignal.notifier).state = true;
    await tester.pumpAndSettle();
    expect(box(_guardianLabel), findsOneWidget);
    expect(tester.widget<CheckboxRow>(box(_guardianLabel)).selected, isFalse);
    expect(buyPressed(tester, wide: false), isNull);
    // The same box ticked again works for the new wording.
    await tick(tester);
    expect(buyPressed(tester, wide: false), isNotNull);
  });

  testWidgets(
      'a tick is not remembered: wording A, B, then A again is '
      'unticked with Pay off', (tester) async {
    await pumpPro(tester, wide: false);
    await tick(tester);
    expect(buyPressed(tester, wide: false), isNotNull);
    final signal = ProviderScope.containerOf(
      tester.element(find.byType(ProPage)),
    ).read(_guardianSignal.notifier)
      ..state = true;
    await tester.pumpAndSettle();
    expect(buyPressed(tester, wide: false), isNull);
    signal.state = false;
    await tester.pumpAndSettle();
    expect(box(), findsOneWidget);
    expect(tester.widget<CheckboxRow>(box()).selected, isFalse);
    expect(buyPressed(tester, wide: false), isNull);
  });

  testWidgets('a tick does not carry over to another account', (tester) async {
    await pumpPro(tester, wide: false);
    await tick(tester);
    expect(buyPressed(tester, wide: false), isNotNull);
    ProviderScope.containerOf(tester.element(find.byType(ProPage)))
        .read(_accountSignal.notifier)
        .state = 'someone-else';
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxRow>(box()).selected, isFalse);
    expect(buyPressed(tester, wide: false), isNull);
  });

  testWidgets('the label reads as one sentence and the row ticks',
      (tester) async {
    await pumpPro(tester, wide: false);
    await tester.ensureVisible(box());
    await tester.pump();
    final text = tester.renderObject<RenderParagraph>(
      find.descendant(of: box(), matching: find.byType(RichText)).first,
    );
    // The link is an inline widget, so its words are not in the paragraph.
    expect(
      text.text.toPlainText().replaceAll('\uFFFC', _link),
      _adultLabel,
    );
    expect(tester.widget<CheckboxRow>(box()).selected, isFalse);
    await tester.tapAt(tester.getTopLeft(box()) + const Offset(14, 20));
    await tester.pump();
    expect(tester.widget<CheckboxRow>(box()).selected, isTrue);
  });

  testWidgets('a screen reader reads one label and a link', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPro(tester, wide: false);
    await tester.ensureVisible(box());
    await tester.pump();
    final node = tester.getSemantics(find.bySemanticsLabel(_adultLabel));
    expect(node.label, _adultLabel);
    final checked = node.getSemanticsData().flagsCollection.isChecked;
    expect(checked, isNot(CheckedState.none));
    var links = 0;
    void walk(SemanticsNode n) {
      if (n.label == _link &&
          n.getSemanticsData().hasAction(SemanticsAction.tap)) {
        links++;
      }
      n.visitChildren((c) {
        walk(c);
        return true;
      });
    }

    walk(node);
    expect(links, 1);
    handle.dispose();
  });
}
