import 'dart:ui' show CheckedState, Tristate;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/gestures.dart';
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
import 'package:pantas/core/ui/web/web_tokens.dart';
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
  var grantReads = 0;
  var guardianReads = 0;
  var onWeb = true;
  Exception? refusal;

  setUp(() {
    calls = [];
    refusal = null;
    grantReads = 0;
    guardianReads = 0;
    onWeb = true;
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
      readGrants: (_) async {
        grantReads++;
        return [];
      },
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
      paymentsOnWebProvider.overrideWithValue(onWeb),
      guardianConfirmedProvider.overrideWith((ref) async {
        guardianReads++;
        return guardian || ref.watch(_guardianSignal);
      }),
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

  /// What Pay does when pressed; null while it is off. On a phone Pay stays
  /// tappable while off (ruling C6), so off there means `inactive`.
  VoidCallback? buyPressed(WidgetTester tester, {required bool wide}) {
    if (wide) {
      return tester
          .widget<WebButton>(find.widgetWithText(WebButton, _buy))
          .onPressed;
    }
    final pay =
        tester.widget<PantasButton>(find.widgetWithText(PantasButton, _buy));
    return pay.inactive ? null : pay.onPressed;
  }

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

  group('guardian status is read only when the declaration card shows', () {
    testWidgets('web with the card reads it', (tester) async {
      await pumpPro(tester, wide: false);
      expect(box(), findsOneWidget);
      expect(guardianReads, greaterThan(0));
    });

    testWidgets('native makes no read', (tester) async {
      onWeb = false;
      await pumpPro(tester, wide: false);
      expect(box(), findsNothing);
      expect(guardianReads, 0);
    });

    testWidgets('the free-trial state makes no read', (tester) async {
      await pumpPro(tester, wide: false, trialEligible: true);
      expect(box(), findsNothing);
      expect(guardianReads, 0);
    });
  });

  testWidgets('the link shows the design system focus ring from the keyboard',
      (tester) async {
    resetWebKeyboardFocus();
    await pumpPro(tester, wide: true);
    final ring = find.descendant(
      of: box(),
      matching: find.byKey(const ValueKey('focus-ring')),
    );
    expect(ring, findsNothing);
    await tester.ensureVisible(box());
    Focus.of(tester.element(find.text(_link))).requestFocus();
    await tester.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(ring, findsOneWidget);
    final decoration =
        tester.widget<DecoratedBox>(ring).decoration as BoxDecoration;
    final side = (decoration.border! as Border).top;
    expect(side.width, 2);
    expect(
      side.color,
      tester.element(find.text(_link)).webTokens.colors.accent,
    );
    // Drawn 2 px outside the link, so its 2 px line sits 4 px out in all.
    final link = tester.getRect(find.text(_link));
    final drawn = tester.getRect(ring);
    expect(link.left - drawn.left, 4);
    expect(drawn.right - link.right, 4);
  });

  testWidgets('the link goes accent to accent-hover on hover', (tester) async {
    await pumpPro(tester, wide: true);
    await tester.ensureVisible(box());
    Color? color() => tester.widget<Text>(find.text(_link)).style?.color;
    final tokens = tester.element(find.text(_link)).webTokens;
    expect(color(), tokens.colors.accent);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text(_link)));
    await tester.pump();
    expect(color(), tokens.accentHover);
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(color(), tokens.colors.accent);
  });

  testWidgets(
      'wide: the seller line is fine print of Pay, right-aligned in the Pay '
      'column and wrapping within it', (tester) async {
    await pumpPro(tester, wide: true);
    final seller = find.byWidgetPredicate(
      (w) => w is RichText && w.text.toPlainText().startsWith('Sold by'),
    );
    final pay = tester.getRect(find.widgetWithText(WebButton, _buy));
    final line = tester.getRect(seller);
    expect(line.width, lessThanOrEqualTo(480));
    expect(line.right, closeTo(pay.right, 1));
    expect(line.top, greaterThan(pay.bottom - 1));
    expect(line.height, greaterThan(24), reason: 'it wraps');
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

  group('ruling C6: phone Pay while the box is unticked', () {
    const hint = 'Tick the box to pay.';
    final pulse = find.byKey(const ValueKey('ring-pulse'));
    final payFinder = find.widgetWithText(PantasButton, _buy);

    double barHeight(WidgetTester tester) =>
        tester.getSize(find.byKey(const ValueKey('pro-bar'))).height;

    double scrolled(WidgetTester tester) => tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;

    double barTop(WidgetTester tester) =>
        tester.getTopLeft(find.byKey(const ValueKey('pro-bar'))).dy;

    Future<void> tapPay(WidgetTester tester) async {
      await tester.tap(payFinder);
    }

    bool focusOnTick() =>
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<CheckboxRow>() !=
        null;

    testWidgets('the status line reads the hint while Pay is off',
        (tester) async {
      await pumpPro(tester, wide: false);
      expect(find.text(hint), findsOneWidget);
      expect(
        tester
            .widget<AnimatedOpacity>(
              find.ancestor(
                of: find.text(hint),
                matching: find.byType(AnimatedOpacity),
              ),
            )
            .opacity,
        1,
      );
    });

    testWidgets('the bar is the same height ticked and unticked',
        (tester) async {
      await pumpPro(tester, wide: false);
      final off = barHeight(tester);
      await tick(tester);
      await tester.pumpAndSettle();
      expect(barHeight(tester), off);
      await tick(tester);
      await tester.pumpAndSettle();
      expect(barHeight(tester), off);
    });

    testWidgets('on tick the hint fades out over 150 ms', (tester) async {
      await pumpPro(tester, wide: false);
      double opacity() => tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.text(hint),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;
      await tick(tester);
      final animated = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text(hint),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(animated.duration, const Duration(milliseconds: 150));
      expect(opacity(), 0);
    });

    testWidgets('Pay is a button with the hint, enabled for focus',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpPro(tester, wide: false);
      final node = tester.getSemantics(
        find.descendant(of: payFinder, matching: find.text(_buy)),
      );
      final data = node.getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.flagsCollection.isEnabled, Tristate.isTrue);
      expect(data.hint, hint);
      expect(data.label, contains(_buy));
      expect(data.hasAction(SemanticsAction.tap), isTrue);
      // Ticked: no hint, still a button.
      await tick(tester);
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(
              find.descendant(of: payFinder, matching: find.text(_buy)),
            )
            .getSemanticsData()
            .hint,
        '',
      );
      handle.dispose();
    });

    testWidgets(
        'a tap while off scrolls a hidden card to rest 16 px above '
        'the bar, then focuses the tick and pulses once', (tester) async {
      await pumpPro(tester, wide: false);
      expect(scrolled(tester), 0);
      await tapPay(tester);
      expect(calls, isEmpty);
      // Mid-scroll: moving, no pulse, focus not yet on the tick.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(scrolled(tester), greaterThan(0));
      expect(pulse, findsNothing);
      expect(focusOnTick(), isFalse);
      // The scroll takes 400 ms.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 40));
      final cardBottom = tester.getBottomLeft(box()).dy;
      expect(barTop(tester) - cardBottom, closeTo(16, 1.5));
      expect(focusOnTick(), isTrue);
      expect(pulse, findsOneWidget);
      // The pulse runs 0.7 s and ends.
      await tester.pump(const Duration(milliseconds: 750));
      expect(pulse, findsNothing);
      expect(calls, isEmpty);
      expect(tester.widget<CheckboxRow>(box()).selected, isFalse);
    });

    testWidgets('Enter on Pay while off does the same', (tester) async {
      await pumpPro(tester, wide: false);
      Focus.of(
        tester.element(
          find.descendant(of: payFinder, matching: find.text(_buy)),
        ),
      ).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 450));
      expect(scrolled(tester), greaterThan(0));
      expect(focusOnTick(), isTrue);
      expect(calls, isEmpty);
    });

    testWidgets('a card already fully visible: no scroll, focus and pulse',
        (tester) async {
      await pumpPro(tester, wide: false);
      await tester.ensureVisible(box());
      await tester.pumpAndSettle();
      final before = scrolled(tester);
      await tapPay(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 40));
      expect(scrolled(tester), before);
      expect(focusOnTick(), isTrue);
      expect(pulse, findsOneWidget);
      expect(calls, isEmpty);
    });

    testWidgets('reduced motion: the scroll jumps and there is no pulse',
        (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await pumpPro(tester, wide: false);
      await tapPay(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final cardBottom = tester.getBottomLeft(box()).dy;
      expect(barTop(tester) - cardBottom, closeTo(16, 1.5));
      expect(focusOnTick(), isTrue);
      expect(pulse, findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(pulse, findsNothing);
    });

    testWidgets('ticked, Pay starts checkout and does not scroll',
        (tester) async {
      await pumpPro(tester, wide: false);
      await tick(tester);
      final before = scrolled(tester);
      await buy(tester, wide: false);
      expect(calls, hasLength(1));
      expect(scrolled(tester), before);
    });
  });
}
