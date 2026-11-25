import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/config/seller_facts.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/google_sign_in_button.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/components/ring_pulse.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/guardian/application/guardian_providers.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/paywall/application/custom_subject_tiers.dart';
import 'package:pantas/features/paywall/application/custom_track_tier.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/checkout_declaration.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_providers.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
import 'package:pantas/features/settings/presentation/widgets/declaration_card.dart';
import 'package:pantas/features/settings/presentation/widgets/phone_pro_hero.dart';
import 'package:pantas/features/settings/presentation/widgets/pro_plan_tile.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_pane_page.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_row.dart';
import 'package:pantas/features/settings/presentation/widgets/settings_section.dart';
import 'package:pantas/features/settings/presentation/widgets/web_pro_hero.dart';
import 'package:pantas/features/settings/settings.dart';
import 'package:url_launcher/url_launcher.dart';

const _googlePlaySubscriptionsPath = '/store/account/subscriptions';
const _productionPackageName = 'com.aedwon.pantas';

typedef SubscriptionManagementLauncher = Future<bool> Function(Uri uri);

Future<bool> launchGooglePlaySubscriptionManagement(Uri uri) {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Uri googlePlaySubscriptionManagementUri(Entitlement entitlement) {
  final rawProductId = entitlement.productId;
  final canLinkDirectly = entitlement.proIsActive &&
      !entitlement.isUnknownPlan &&
      rawProductId != null &&
      rawProductId.isNotEmpty;
  if (!canLinkDirectly) {
    return Uri.https('play.google.com', _googlePlaySubscriptionsPath);
  }

  final productId = rawProductId.split(':').first;
  return Uri.https('play.google.com', _googlePlaySubscriptionsPath, {
    'sku': productId,
    'package': _productionPackageName,
  });
}

final webGrantHistoryProvider =
    FutureProvider.autoDispose<List<WebGrantHistory>>((ref) async {
  if (!ref.watch(paymentsOnWebProvider)) return [];
  final user = await ref.watch(currentUserProvider.future);
  final gateway = ref.watch(revenueCatGatewayProvider);
  if (user == null || gateway is! WebPaymentGateway) return [];
  return gateway.grantHistory();
});

class ProPage extends ConsumerStatefulWidget {
  const ProPage({
    this.subscriptionLauncher = launchGooglePlaySubscriptionManagement,
    this.checkoutReturnUri,
    this.targetExam,
    this.previousExamName,
    this.onSwitchOnFree,
    this.freeLabel,
    super.key,
  });
  final SubscriptionManagementLauncher subscriptionLauncher;
  final Uri? checkoutReturnUri;
  final ExamCatalogEntry? targetExam;
  final String? previousExamName;
  final Future<void> Function()? onSwitchOnFree;

  /// The label of the keep-Free button on an upgrade screen. Defaults to
  /// 'Switch on Free'.
  final String? freeLabel;
  @override
  ConsumerState<ProPage> createState() => _ProPageState();
}

class _ProPageState extends ConsumerState<ProPage> with WidgetsBindingObserver {
  bool _awaitingCheckout = false;
  bool _wasCurrent = true;
  String? _checkoutUid;
  String? _selected;
  String? _feedback;
  bool _busy = false;
  bool _restoring = false;
  bool _trialUnavailable = false;

  /// The declaration tick beside Pay on every web checkout (boards CB_*,
  /// S4*_T).
  /// What the tick was given for: account, wording kind and version, Terms
  /// version. A tick counts only while this still matches what is shown.
  String? _tickedFor;

  /// The declaration last shown. When it changes, the tick is forgotten, even
  /// if an earlier one comes back: each wording needs its own fresh tick.
  String? _shownFor;

  /// The wording the server asked for after it refused the one shown.
  DeclarationKind? _serverKind;

  /// Ruling C6: where the card and the bar are, so a tap on Pay while it is
  /// off can bring the card to rest just above the bar.
  final _cardKey = GlobalKey();
  final _barKey = GlobalKey();
  final _tickFocus = FocusNode(debugLabel: 'declaration-tick');
  final _tickPulse = RingPulseController();
  bool _showingTick = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(ref.read(telemetryProvider).log(TelemetryEvent.proView));
    unawaited(ref.read(reviewPromptControllerProvider).recordPaywallSeen());
    Future<void>.microtask(_checkoutReturn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    if (current && !_wasCurrent && _awaitingCheckout) {
      unawaited(_clearPendingExamSwitch());
      _busy = false;
      _awaitingCheckout = false;
    }
    _wasCurrent = current;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingCheckout && mounted) {
      unawaited(_clearPendingExamSwitch());
      setState(() {
        _busy = false;
        _awaitingCheckout = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickFocus.dispose();
    super.dispose();
  }

  /// Ruling C6. Pay was pressed while the box is unticked: say why. A card
  /// that is not fully visible scrolls to rest 16 px above the bar (400 ms on
  /// the move curve). Then focus goes to the tick and the ring pulses once,
  /// never during the scroll. Reduced motion jumps and does not pulse.
  Future<void> _showTick() async {
    if (_showingTick) return;
    _showingTick = true;
    try {
      final still = MediaQuery.disableAnimationsOf(context);
      final card = _cardKey.currentContext;
      final bar = _barKey.currentContext?.findRenderObject();
      final cardBox = card?.findRenderObject();
      final scrollable = card == null ? null : Scrollable.maybeOf(card);
      if (cardBox is RenderBox &&
          bar is RenderBox &&
          scrollable != null &&
          cardBox.attached &&
          bar.attached) {
        final position = scrollable.position;
        final viewport = scrollable.context.findRenderObject()! as RenderBox;
        final top = cardBox.localToGlobal(Offset.zero).dy;
        final bottom = top + cardBox.size.height;
        final floor = viewport.localToGlobal(Offset.zero).dy;
        final ceiling = math.min(
          floor + viewport.size.height,
          bar.localToGlobal(Offset.zero).dy,
        );
        if (top < floor || bottom > ceiling) {
          // Rest the card's bottom 16 px above the bar; a card taller than
          // the room keeps its top in view.
          final move = math.min(
            bottom - (bar.localToGlobal(Offset.zero).dy - PantasSpace.s16),
            top - floor,
          );
          final target = (position.pixels + move).clamp(
            position.minScrollExtent,
            position.maxScrollExtent,
          );
          if (still) {
            position.jumpTo(target);
          } else {
            await position.animateTo(
              target,
              // 400 ms, as ruling C6 sets it (this token's value).
              duration: PantasDurations.drawerClose,
              curve: PantasCurves.move,
            );
          }
        }
      }
      if (!mounted) return;
      _tickFocus.requestFocus();
      if (!still) _tickPulse.play();
    } finally {
      _showingTick = false;
    }
  }

  /// Drops this page's own pending switch. A page with no target exam never
  /// owns one, and a switch for another exam stays until its checkout
  /// confirms.
  Future<void> _clearPendingExamSwitch({String? uid}) async {
    final owner = uid ?? _checkoutUid;
    final target = widget.targetExam;
    if (owner == null || target == null) return;
    final telemetry = ref.read(telemetryProvider);
    try {
      final prefs = ref.read(appPreferencesRepositoryProvider);
      final key = 'checkout_exam_v1:$owner';
      final raw = await prefs.deviceValue(key);
      if (raw == null || raw.isEmpty) return;
      Object? decoded;
      try {
        decoded = jsonDecode(raw);
      } on FormatException {
        // Not an intent at all. Nothing to keep.
      }
      if (decoded is Map<String, dynamic> && decoded['examId'] != target.id) {
        return;
      }
      await prefs.setDeviceValue(key, '');
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
    }
  }

  Future<void> _switchOnFree() async {
    if (!ref.read(paymentsOnWebProvider)) {
      await widget.onSwitchOnFree?.call();
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user.isLoading) return;
    await _clearPendingExamSwitch(uid: user.valueOrNull?.uid);
    if (mounted) await widget.onSwitchOnFree?.call();
  }

  Future<void> _checkoutReturn() async {
    final telemetry = ref.read(telemetryProvider);
    if (!ref.read(paymentsOnWebProvider)) return;
    final gateway = ref.read(revenueCatGatewayProvider);
    if (gateway is! WebPaymentGateway) return;
    final user = await ref
        .read(currentUserProvider.future)
        .onError<Object>((error, stack) {
      unawaited(telemetry.recordError(error, stack));
      return null;
    });
    if (!mounted ||
        user == null ||
        !identical(gateway, ref.read(revenueCatGatewayProvider))) {
      return;
    }
    final uid = user.uid;
    final operation = await gateway
        .handleCheckoutReturn(widget.checkoutReturnUri ?? Uri.base);
    if (operation == null || !await _resolvedSameAccount(uid)) {
      return;
    }
    try {
      await _completeExamSwitch(uid, operation);
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      if (mounted) {
        setState(() => _feedback = 'Could not save. Please try again.');
      }
      return;
    }
    if (mounted) {
      setState(() {
        _busy = false;
        _feedback = _message(operation.status);
      });
    }
  }

  bool _sameAccount(String uid) =>
      mounted &&
      !ref.read(currentUserProvider).isLoading &&
      ref.read(currentUserProvider).valueOrNull?.uid == uid;

  Future<bool> _resolvedSameAccount(String uid) async {
    if (!mounted) return false;
    final telemetry = ref.read(telemetryProvider);
    try {
      await ref.read(currentUserProvider.future);
      return _sameAccount(uid);
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
      return false;
    }
  }

  Future<bool> _prepareExamSwitch(String uid) async {
    final target = widget.targetExam;
    if (target == null) return true;
    final count = await ref.read(carryableCountProvider(target.id).future);
    if (!_sameAccount(uid)) return false;
    bool? choice =
        (await ref.read(settingsRepositoryProvider).readUserSettings())
            .carryOverProgress;
    if (!mounted || !_sameAccount(uid)) return false;
    if (count > 0) {
      choice = await showCarryOverPrompt(
        context: context,
        examShortName: target.shortName,
        carryableCount: count,
        previousExam: widget.previousExamName,
      );
      if (choice == null || !_sameAccount(uid)) return false;
    }
    final prefs = ref.read(appPreferencesRepositoryProvider);
    final fromExamId = await prefs.selectedExamId();
    if (!_sameAccount(uid)) return false;
    final before = ref.read(revenueCatGatewayProvider).cachedEntitlement;
    final now = ref.read(paywallClockProvider)();
    await prefs.setDeviceValue(
      'checkout_exam_v1:$uid',
      jsonEncode({
        'uid': uid,
        'examId': target.id,
        'count': choice,
        'tier': PriceTier.fromCatalog(target.priceTier).name,
        'fromExamId': fromExamId,
        // What the account already had for this exam, so that coverage it
        // already held cannot confirm this checkout.
        'coveredAtStart': before?.coverage(at: now).coversExam(
                  target.id,
                  PriceTier.fromCatalog(target.priceTier),
                ) ??
            false,
        'endsAtBefore': before?.endsAt?.millisecondsSinceEpoch,
      }),
    );
    return _sameAccount(uid);
  }

  Future<void> _completeExamSwitch(
    String uid,
    PaymentOperationResult operation,
  ) async {
    final prefs = ref.read(appPreferencesRepositoryProvider);
    final key = 'checkout_exam_v1:$uid';
    if (!_sameAccount(uid)) return;
    final raw = await prefs.deviceValue(key);
    if (!_sameAccount(uid)) return;
    if (raw == null || raw.isEmpty || !_sameAccount(uid)) return;
    Map<String, dynamic> pending;
    PriceTier tier;
    var matched = false;
    Future<void> consume() => prefs.setDeviceValue(key, '');
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid checkout exam intent');
      }
      final reference =
          (widget.checkoutReturnUri ?? Uri.base).queryParameters['ref'];
      if (reference == null ||
          reference.isEmpty ||
          decoded['reference'] != reference) {
        return;
      }
      // Only this checkout may consume its pending switch, and only once the
      // checkout is confirmed or can no longer be (cancelled, invalid, old).
      matched = true;
      if (decoded['uid'] is! String ||
          decoded['examId'] is! String ||
          decoded['count'] is! bool ||
          decoded['tier'] is! String ||
          decoded['sessionId'] is! String ||
          (decoded['sessionId'] as String).isEmpty ||
          decoded['createdAt'] is! int ||
          (decoded['createdAt'] as int).abs() > 8640000000000000 ||
          (decoded['fromExamId'] != null && decoded['fromExamId'] is! String)) {
        throw const FormatException('Invalid checkout exam intent');
      }
      pending = decoded;
      tier = PriceTier.values.byName(pending['tier'] as String);
    } catch (error, stack) {
      unawaited(ref.read(telemetryProvider).recordError(error, stack));
      if (matched) await consume();
      return;
    }
    final target = widget.targetExam ??
        (await ref.read(examCatalogRepositoryProvider).watchAll().first)
            .where((entry) => entry.id == pending['examId'])
            .firstOrNull;
    if (!_sameAccount(uid)) return;
    final created =
        DateTime.fromMillisecondsSinceEpoch(pending['createdAt'] as int);
    final age = ref.read(paywallClockProvider)().difference(created);
    if (target == null ||
        pending['uid'] != uid ||
        pending['examId'] != target.id ||
        tier != PriceTier.fromCatalog(target.priceTier) ||
        age.isNegative ||
        age > const Duration(hours: 24)) {
      await consume();
      return;
    }
    if (operation.status == PaymentOperationStatus.userCancelled) {
      await consume();
      return;
    }
    final entitlement = operation.confirmedEntitlement;
    final examId = target.id;
    if (operation.status != PaymentOperationStatus.success ||
        entitlement == null ||
        !entitlement
            .coverage(at: ref.read(paywallClockProvider)())
            .coversExam(examId, tier)) {
      // Not confirmed for this exam yet (the webhook can lag, or other
      // coverage hides it). Keep the intent for the next return.
      return;
    }
    // Coverage the account already held for this exam proves nothing about
    // this checkout. It confirms only if the coverage now ends later.
    final endsBefore = pending['endsAtBefore'];
    if (pending['coveredAtStart'] == true &&
        (endsBefore is! int ||
            (entitlement.endsAt?.millisecondsSinceEpoch ?? 0) <= endsBefore)) {
      return;
    }
    final from = await prefs.selectedExamId();
    if (!_sameAccount(uid)) return;
    if (from != pending['fromExamId']) {
      await consume();
      return;
    }
    final publish =
        await ref.read(studySettingsCaptureProvider)(examId: examId);
    if (!_sameAccount(uid)) return;
    final db = ref.read(appDatabaseProvider);
    final settings = ref.read(settingsRepositoryProvider);
    await publish.apply(
      () => db.transaction(() async {
        await settings.updateCarryOverProgress(
          enabled: pending['count'] as bool,
        );
        await prefs.setSelectedExamId(examId);
        await prefs.setDeviceValue(key, '');
      }),
    );
    if (!_sameAccount(uid)) return;
    ref
      ..invalidate(activeExamFocusProvider)
      ..invalidate(userSettingsProvider);
  }

  String? _message(PaymentOperationStatus status, {bool restore = false}) =>
      switch (status) {
        PaymentOperationStatus.guardianConfirmationRequired =>
          'Read the box again, then tick it to pay.',
        PaymentOperationStatus.alreadyPaid =>
          'Your payment went through. Pro will appear shortly.',
        PaymentOperationStatus.success => restore ? 'Pro restored.' : null,
        PaymentOperationStatus.noActiveSubscription =>
          'No purchases found for this account.',
        PaymentOperationStatus.userCancelled ||
        PaymentOperationStatus.operationAlreadyInProgress =>
          null,
        PaymentOperationStatus.networkFailure =>
          'No internet connection. Please try again.',
        PaymentOperationStatus.entitlementNotActive =>
          "We found a purchase, but Pro couldn't be confirmed yet. "
              'Try again in a moment.',
        PaymentOperationStatus.storeFailure => ref.read(paymentsOnWebProvider)
            ? "We couldn't confirm your subscription. Try again."
            : "Google Play couldn't complete this purchase. Try again.",
        _ => "We couldn't confirm your subscription. Try again.",
      };

  /// Opens the Terms from the link in the declaration. The box is untouched.
  void _openTerms() {
    final router = GoRouter.maybeOf(context);
    if (router != null) unawaited(router.push<void>('/legal/terms'));
  }

  void _emailSupport() =>
      unawaited(launchUrl(Uri(scheme: 'mailto', path: sellerEmail)));

  Future<void> _restore() async {
    if (_busy) return;
    final uid = ref.read(currentUserProvider).unwrapPrevious().valueOrNull?.uid;
    setState(() {
      _busy = true;
      _restoring = true;
      _feedback = null;
    });
    final result = await ref.read(paywallControllerProvider).restore();
    if (!mounted) return;
    ref
      ..invalidate(webGrantHistoryProvider)
      ..invalidate(unfilteredPaywallOfferingProvider);
    setState(() {
      _busy = false;
      if (uid ==
          ref.read(currentUserProvider).unwrapPrevious().valueOrNull?.uid) {
        _feedback = _message(result.status, restore: true);
      }
    });
  }

  Future<void> _purchase(
    PaywallPackage? package,
    PaywallPassPackage? pass,
    ExamCatalogEntry exam, {
    required bool allowTrial,
    CheckoutDeclaration? declaration,
  }) async {
    if (_busy || (package == null && pass == null)) return;
    final telemetry = ref.read(telemetryProvider);
    final web = ref.read(paymentsOnWebProvider);
    if (web && (ref.read(isAnonymousProvider).valueOrNull ?? true)) return;
    final uid = ref.read(currentUserProvider).unwrapPrevious().valueOrNull?.uid;
    if (web && uid == null) return;
    setState(() {
      _busy = true;
      _restoring = false;
      _feedback = null;
    });
    if (web && uid != null) {
      _checkoutUid = uid;
      await _clearPendingExamSwitch(uid: uid);
      if (!_sameAccount(uid)) {
        if (mounted) setState(() => _busy = false);
        return;
      }
    }
    PaymentOperationStatus status;
    DeclarationKind? refusedKind;
    final gateway = ref.read(revenueCatGatewayProvider);
    if (web &&
        widget.targetExam == null &&
        allowTrial &&
        package != null &&
        package.sku == PaywallSku.monthly &&
        package.trialEligible &&
        !_trialUnavailable &&
        gateway is WebPaymentGateway) {
      await _clearPendingExamSwitch(uid: uid);
      final result = await gateway.startTrial();
      status = result.operation.status;
      if (result.status != WebTrialStatus.failed) {
        ref.invalidate(unfilteredPaywallOfferingProvider);
        if (mounted) setState(() => _trialUnavailable = true);
      }
      if (result.status == WebTrialStatus.notAvailable && mounted) {
        setState(() => _trialUnavailable = true);
        status = PaymentOperationStatus.userCancelled;
      }
    } else {
      if (web && widget.targetExam != null && uid != null) {
        try {
          if (!await _prepareExamSwitch(uid)) {
            if (mounted) {
              setState(() => _busy = false);
              await _clearPendingExamSwitch(uid: uid);
            }
            return;
          }
        } catch (error, stack) {
          unawaited(telemetry.recordError(error, stack));
          if (mounted) {
            setState(() {
              _busy = false;
              _feedback = 'Could not save. Please try again.';
            });
          }
          return;
        }
        if (!_sameAccount(uid)) {
          if (mounted) setState(() => _busy = false);
          await _clearPendingExamSwitch(uid: uid);
          return;
        }
      }
      final controller = ref.read(paywallControllerProvider);
      if (web && uid != null && gateway is WebPaymentGateway) {
        _checkoutUid = uid;
        Future<void> beforeRedirect(String sessionId, String reference) async {
          if (!_sameAccount(uid)) throw StateError('Checkout account changed');
          if (widget.targetExam == null) return;
          final prefs = ref.read(appPreferencesRepositoryProvider);
          final raw = await prefs.deviceValue('checkout_exam_v1:$uid');
          if (!_sameAccount(uid)) throw StateError('Checkout account changed');
          final pending = jsonDecode(raw!) as Map<String, dynamic>;
          pending['sessionId'] = sessionId;
          pending['reference'] = reference;
          pending['createdAt'] =
              ref.read(paywallClockProvider)().millisecondsSinceEpoch;
          await prefs.setDeviceValue(
            'checkout_exam_v1:$uid',
            jsonEncode(pending),
          );
          if (!_sameAccount(uid)) throw StateError('Checkout account changed');
        }

        final result = pass != null
            ? await gateway.purchasePass(
                pass,
                exam: exam,
                beforeRedirect: beforeRedirect,
                declaration: declaration,
              )
            : await gateway.purchase(
                package!,
                beforeRedirect: beforeRedirect,
                declaration: declaration,
              );
        status = result.status;
        refusedKind = result.declarationKind;
        if (status != PaymentOperationStatus.operationAlreadyInProgress) {
          await _clearPendingExamSwitch(uid: uid);
        }
      } else {
        final result = pass != null
            ? await controller.purchasePass(pass, exam: exam)
            : await controller.purchase(package!);
        status = result.status;
      }
    }
    if (status == PaymentOperationStatus.alreadyPaid && mounted) {
      // The buyer's payment exists: read the ledger now, as Restore does.
      await ref.read(paywallControllerProvider).restore();
      ref
        ..invalidate(webGrantHistoryProvider)
        ..invalidate(unfilteredPaywallOfferingProvider);
    }
    if (!mounted) return;
    final sameAccount = web
        ? uid != null && _sameAccount(uid)
        : uid ==
            ref.read(currentUserProvider).unwrapPrevious().valueOrNull?.uid;
    if (sameAccount &&
        widget.targetExam != null &&
        status == PaymentOperationStatus.success) {
      leavePage(
        context,
        fallback: '/settings',
        result: true,
        respectPopScope: false,
      );
      return;
    }
    setState(() {
      // C3 returns this status after opening PayMongo in this tab.
      _awaitingCheckout = sameAccount &&
          web &&
          status == PaymentOperationStatus.operationAlreadyInProgress;
      _busy = _awaitingCheckout;
      if (sameAccount) _feedback = _message(status);
      // The server named the wording this account needs. Show it, unticked.
      if (sameAccount && refusedKind != null) {
        _serverKind = refusedKind;
        _tickedFor = null;
      }
    });
  }

  Future<void> _manage(Entitlement entitlement) async {
    final telemetry = ref.read(telemetryProvider);
    if (_busy) return;
    setState(() => _busy = true);
    var opened = false;
    try {
      opened = await widget.subscriptionLauncher(
        googlePlaySubscriptionManagementUri(entitlement),
      );
    } catch (error, stack) {
      unawaited(telemetry.recordError(error, stack));
    }
    if (mounted) {
      setState(() {
        _busy = false;
        if (!opened) {
          _feedback = "We couldn't open Google Play. You can manage your "
              'subscription in the Google Play app.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (previous, next) {
      if (previous?.valueOrNull?.uid != next.valueOrNull?.uid) {
        setState(() {
          _trialUnavailable = false;
          _selected = null;
          _feedback = null;
          _busy = false;
        });
      }
    });
    final entitlement =
        ref.watch(entitlementProvider).valueOrNull ?? const Entitlement.free();
    final ownedPasses = entitlement.passes.isEmpty
        ? null
        : ref.watch(ownedPassCatalogEntriesProvider).unwrapPrevious();
    if (ownedPasses?.isLoading ?? false) {
      return const SettingsPanePage(
        section: 'Pantas Pro',
        title: 'Pantas Pro',
        children: [
          SkeletonRevealScope(
            immediate: true,
            child: SkeletonPulse(
              label: 'Loading your passes',
              child: SkeletonGroups(),
            ),
          ),
        ],
      );
    }
    if (ownedPasses?.hasError ?? false) {
      return SettingsPanePage(
        section: 'Pantas Pro',
        title: 'Pantas Pro',
        children: [
          const Text('Could not load your passes.'),
          PantasButton(
            label: 'Try Again',
            onPressed: () => ref.invalidate(examCatalogRepositoryProvider),
          ),
        ],
      );
    }
    final upgrade = widget.targetExam != null;
    final web = ref.watch(paymentsOnWebProvider);
    final anonymous =
        ref.watch(isAnonymousProvider).unwrapPrevious().valueOrNull ?? true;
    final customExam = upgrade
        ? null
        : ref.watch(
            activeExamFocusProvider.select((focus) {
              final active = focus.valueOrNull?.exam;
              return active != null && active.isCustom ? active : null;
            }),
          );
    final custom = customExam != null;
    final customTierAsync = custom
        ? ref.watch(activeCustomTrackTierProvider).unwrapPrevious()
        : null;
    final customTier = customTierAsync?.valueOrNull;
    // A custom exam's tier decides its paywall. Until it is known there is no
    // paywall at all, never a guessed one.
    final customTierUnknown = custom && customTier == null;
    final trackName = customExam?.name;
    final exam = widget.targetExam ??
        (customExam != null && customTier != null
            ? customCatalogEntry(
                examId: customExam.id,
                name: customExam.name,
                tier: customTier.tier,
              )
            : custom
                ? null
                : ref.watch(activeProCatalogEntryProvider).valueOrNull);
    final covered = upgrade
        ? false
        : custom
            ? (customTierUnknown
                ? null
                : (ref.watch(proForActiveExamProvider).valueOrNull ?? false) ||
                    entitlement.coversExam(
                      customExam.id,
                      examTier: customTier!.tier,
                    ))
            : ref.watch(proForActiveExamProvider).valueOrNull;
    final offering = (upgrade
            ? ref.watch(unfilteredPaywallOfferingProvider)
            : ref.watch(paywallOfferingProvider))
        .unwrapPrevious();
    firstScreenReady(
      context,
      ref,
      ready: !offering.isLoading && !(customTierAsync?.isLoading ?? false),
    );
    final paused = entitlement.state == EntitlementState.paused;
    final packages = (offering.valueOrNull?.recognizedPackages
            .where(
              (p) =>
                  (!upgrade || p.sku == PaywallSku.monthly) &&
                  exam != null &&
                  productForId(p.productId)?.tier ==
                      PriceTier.fromCatalog(exam.priceTier),
            )
            .toList() ??
        <PaywallPackage>[])
      ..sort((a, b) => a.sku.index.compareTo(b.sku.index));
    final passes = offering.valueOrNull?.passPackages
            .where((p) => productForId(p.productId)?.examId == exam?.id)
            .toList() ??
        <PaywallPassPackage>[];
    final selectedPackage = packages
            .where((p) => p.productId == _selected)
            .firstOrNull ??
        (_selected == null
            ? packages.where((p) => p.sku == PaywallSku.monthly).firstOrNull ??
                packages.firstOrNull
            : null);
    final selectedPassCandidate =
        passes.where((p) => p.productId == _selected).firstOrNull;
    final trial = !upgrade &&
        selectedPackage?.sku == PaywallSku.monthly &&
        selectedPackage!.trialEligible &&
        !_trialUnavailable &&
        !entitlement.proIsActive &&
        !(web && anonymous);
    final owned = covered ?? false;
    final planName = switch (entitlement.plan) {
      EntitlementPlan.weekly => 'Weekly',
      EntitlementPlan.monthly =>
        entitlement.isTrial ? 'Monthly trial' : 'Monthly',
      EntitlementPlan.yearly => 'Yearly',
      EntitlementPlan.free => 'Pro'
    };
    final passNames = entitlement.passes.isEmpty
        ? const <String, ExamCatalogEntry>{}
        : ownedPasses?.valueOrNull ?? const <String, ExamCatalogEntry>{};
    final fallbackPlanEnd =
        entitlement.passes.isEmpty ? entitlement.endsAt : null;
    // A reward ends per exam: show this exam's end, as a Manila date.
    // An ended reward, or a reward for another exam only, is no plan here.
    final rewardEnd = exam == null ? null : entitlement.betaPasses[exam.id];
    final rewardLive = rewardEnd != null &&
        rewardEnd.isAfter(ref.read(paywallClockProvider)().toUtc());
    final rewardShown = rewardLive &&
        entitlement.plan == EntitlementPlan.free &&
        entitlement.promotions.isEmpty;
    final rewardElsewhere = !rewardShown &&
        entitlement.plan == EntitlementPlan.free &&
        entitlement.passes.isEmpty &&
        entitlement.promotions.isEmpty &&
        entitlement.betaPasses.isNotEmpty;
    final rewardOnly = rewardShown || rewardElsewhere;
    final planDate = rewardOnly
        ? rewardEnd?.toUtc().add(const Duration(hours: 8))
        : entitlement.plan != EntitlementPlan.free
            ? (entitlement.isTrial
                    ? entitlement.chargesAt
                    : entitlement.willRenew
                        ? entitlement.renewsAt
                        : entitlement.expiresAt) ??
                entitlement.expiresAt ??
                fallbackPlanEnd
            : entitlement.promotions.isNotEmpty
                ? entitlement.promotions
                    .map((p) => p.endsAt)
                    .reduce((a, b) => a.isAfter(b) ? a : b)
                : entitlement.expiresAt ?? fallbackPlanEnd;
    final past = web
        ? ref
            .watch(webGrantHistoryProvider)
            .unwrapPrevious()
            .valueOrNull
            ?.where(
              (row) =>
                  row.endsAt.isBefore(ref.read(paywallClockProvider)()) &&
                  (row.isTrial ||
                      (productForId(row.productId)?.kind ==
                              ProductKind.subscription &&
                          exam != null &&
                          tierCovers(
                            productForId(row.productId)!.tier,
                            PriceTier.fromCatalog(exam.priceTier),
                          )) ||
                      productForId(row.productId)?.examId == exam?.id),
            )
            .firstOrNull
        : null;
    final passEnded =
        past != null && productForId(past.productId)?.kind == ProductKind.pass;
    final ended = web ? past?.endsAt : entitlement.endsAt;
    final gateway = web ? ref.watch(revenueCatGatewayProvider) : null;
    final playRenews = web &&
        gateway is WebPaymentGateway &&
        offering.unwrapPrevious().hasValue &&
        gateway.googlePlayPlanRenews;

    final lapsed = covered == false &&
        ended != null &&
        ended.isBefore(ref.read(paywallClockProvider)());
    final now =
        ref.read(paywallClockProvider)().toUtc().add(const Duration(hours: 8));
    final today = DateTime.utc(now.year, now.month, now.day);
    final sitting = exam?.publishedSittings
        .where((s) => !s.firstDay.isBefore(today) && s.sourceUrl.isNotEmpty)
        .firstOrNull;
    final daysUntilSitting = sitting?.lastDay.difference(today).inDays;
    final dayUnit = daysUntilSitting == 1 ? 'day' : 'days';
    final sittingEnd =
        sitting == null ? null : DateFormat.yMMMd().format(sitting.lastDay);
    final passDetail = sitting == null
        ? 'Once the next date is out'
        : daysUntilSitting == 0
            ? 'Ends today'
            : daysUntilSitting! > 0 && daysUntilSitting <= 7
                ? 'Ends in $daysUntilSitting $dayUnit'
                : 'Until $sittingEnd';
    final selectedPass = sitting == null ? null : selectedPassCandidate;
    final pending = web ? null : ref.watch(pendingPurchaseProvider).valueOrNull;
    final user = ref.watch(currentUserProvider).unwrapPrevious().valueOrNull;
    final waiting = pending != null && pending.uid == user?.uid;
    final pendingPackage =
        packages.where((p) => p.productId == pending?.productId).firstOrNull;
    final pendingPlan = pendingPackage == null
        ? ''
        : '${_periodName(pendingPackage.sku)}, '
            '${_money(pendingPackage.priceString)}. ';
    final showOffers = covered == false && !paused && !waiting;
    // Every web payment needs the declaration ticked. The server is the
    // control and tells which wording the account needs; the device only
    // guesses it first. The free trial takes no payment, so it has no box.
    final buyShown = showOffers &&
        !(web && anonymous) &&
        exam != null &&
        (selectedPackage != null || selectedPass != null);
    final declarationBox = web && buyShown && !(trial && !lapsed);
    // The guardian status is asked only on web, and only while the card shows.
    final declarationKind = _serverKind ??
        (declarationBox &&
                (ref.watch(guardianConfirmedProvider).valueOrNull ?? false)
            ? DeclarationKind.guardian
            : DeclarationKind.adult);
    final declaration =
        declarationBox ? CheckoutDeclaration(declarationKind) : null;
    final tickKey = declaration == null
        ? null
        : '${user?.uid}|${declaration.toJson().values.join('|')}';
    if (_shownFor != tickKey) {
      _shownFor = tickKey;
      _tickedFor = null;
    }
    final declarationTicked = tickKey != null && _tickedFor == tickKey;
    final buyLocked = _busy || (declarationBox && !declarationTicked);
    // Ruling C6: on the phone Pay shows off but stays tappable, to say why.
    final payOff = declarationBox && !declarationTicked && !_busy;
    final purchaseLabel = selectedPass != null
        ? 'Buy Season Pass'
        : selectedPackage == null
            ? 'Get Pro'
            : upgrade
                ? 'Upgrade for ${_money(selectedPackage.priceString)} a Month'
                : trial && !lapsed
                    ? 'Try 7 Days Free'
                    : lapsed
                        ? 'Get Pro Again'
                        : web
                            ? 'Buy 1 ${_period(selectedPackage.sku)} for '
                                '${_money(selectedPackage.priceString)}'
                            : 'Subscribe for '
                                '${_money(selectedPackage.priceString)} '
                                'a ${_period(selectedPackage.sku)}';
    final whyLine = customTier == null || trackName == null
        ? null
        : Text(
            _tierLine(trackName, customTier),
            style: context.wideWeb
                ? context.webTokens.sub
                : context.type.subhead
                    .copyWith(color: context.colors.textSecondary),
          );
    // Phone Restore (boards ST_ProFree, ST_ProPending, ST_ProPro,
    // ST_ProPassHave, ST_ProLapsed): a 24 high line in the bar while the page
    // sells Pro; a teal row in the last card once Pro is owned or has lapsed,
    // where the boards draw no bar for it.
    final restoreRow = !context.wideWeb && !upgrade && (owned || lapsed);
    final restoreLine = !context.wideWeb && !upgrade && !restoreRow;
    final manageRow = !web &&
        entitlement.proIsActive &&
        entitlement.plan != EntitlementPlan.free;
    final phoneOpen = waiting && !context.wideWeb;
    final phoneBar =
        showOffers || upgrade || restoreLine || playRenews || phoneOpen;
    return SettingsPanePage(
      section: 'Pantas Pro',
      title: context.wideWeb ? 'Pantas Pro' : '',
      bottom: context.wideWeb
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ST_Pro: the row pads 4 and the button 14, so the label
                    // sits 18 in.
                    Padding(
                      padding: const EdgeInsets.only(left: PantasSpace.s4),
                      child: WebButton(
                        label: upgrade
                            ? (widget.freeLabel ?? 'Switch on Free')
                            : _busy && _restoring
                                ? 'Restoring purchases'
                                : 'Restore Purchases',
                        variant: WebButtonVariant.tertiary,
                        busy: _busy,
                        onPressed: _busy
                            ? null
                            : upgrade
                                ? _switchOnFree
                                : _restore,
                      ),
                    ),
                    const SizedBox(width: PantasSpace.s16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (showOffers)
                            if (web && anonymous)
                              GoogleSignInButton(
                                onPressed: () =>
                                    context.push<void>('/settings/account'),
                              )
                            else if (exam != null &&
                                (selectedPackage != null ||
                                    selectedPass != null))
                              WebButton(
                                large: true,
                                label: _busy && !_restoring
                                    ? 'Confirming your payment'
                                    : purchaseLabel,
                                busy: _busy && !_restoring,
                                onPressed: buyLocked
                                    ? null
                                    : () => _purchase(
                                          selectedPackage,
                                          selectedPass,
                                          exam,
                                          allowTrial: trial && !lapsed,
                                          declaration: declaration,
                                        ),
                              ),
                          if (showOffers &&
                              selectedPass != null &&
                              sitting != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: PantasSpace.s8),
                              child: Text(
                                '${_money(selectedPass.priceString)} once. '
                                'Ends after the exam on $sittingEnd.',
                                textAlign: TextAlign.right,
                                style: context.webTokens.sm,
                              ),
                            )
                          else if (showOffers && trial && !lapsed)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: PantasSpace.s8),
                              child: Text(
                                web
                                    ? 'No payment needed.'
                                    : 'Free for 7 days, then '
                                        '${_money(
                                        selectedPackage.priceString,
                                      )} '
                                        'a month. '
                                        'Cancel any time.',
                                textAlign: TextAlign.right,
                                style: context.webTokens.sm,
                              ),
                            ),
                          if (declarationBox)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: PantasSpace.s8),
                              child: SellerLine(
                                facts: sellerFacts,
                                style: context.webTokens.sm,
                                textAlign: TextAlign.right,
                                maxWidth: 480,
                                onEmail: _emailSupport,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (playRenews)
                  Text(
                    'Your Google Play plan keeps renewing. '
                    'Cancel it in Google Play if you no longer need it.',
                    style: context.webTokens.sm,
                  ),
                if (_feedback != null)
                  Padding(
                    padding: const EdgeInsets.only(top: PantasSpace.s8),
                    child: Text(_feedback!, style: context.webTokens.sm),
                  ),
              ],
            )
          : _FadedBar(
              visible: phoneBar,
              child: SafeArea(
                key: _barKey,
                top: false,
                // The boards pad the bar 14 16 30, home indicator included.
                minimum: const EdgeInsets.only(
                  bottom: PantasSpace.s28 + PantasSpace.s2,
                ),
                child: Padding(
                  key: const ValueKey('pro-bar'),
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    PantasSpace.s14,
                    PantasSpace.s16,
                    PantasSpace.s0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showOffers) ...[
                        if (web && anonymous)
                          GoogleSignInButton(
                            expand: true,
                            onPressed: () =>
                                context.push<void>('/settings/account'),
                          )
                        else if (exam != null &&
                            (selectedPackage != null || selectedPass != null))
                          PantasButton(
                            label: purchaseLabel,
                            busy: _busy,
                            inactive: payOff,
                            hint: _tickHint,
                            onPressed: payOff
                                ? () => unawaited(_showTick())
                                : buyLocked
                                    ? null
                                    : () => _purchase(
                                          selectedPackage,
                                          selectedPass,
                                          exam,
                                          allowTrial: trial && !lapsed,
                                          declaration: declaration,
                                        ),
                          ),
                        if (selectedPass != null && sitting != null) ...[
                          const SizedBox(height: PantasSpace.s8),
                          Text(
                            '${_money(selectedPass.priceString)} once. '
                            'Ends after the exam on $sittingEnd.',
                            textAlign: TextAlign.center,
                            style: context.type.footnote,
                          ),
                        ] else if (trial && !lapsed) ...[
                          const SizedBox(height: PantasSpace.s8),
                          Text(
                            web
                                ? 'No payment needed.'
                                : 'Then '
                                    '${_money(selectedPackage.priceString)} '
                                    'a month. '
                                    'Cancel any time in Google Play.',
                            textAlign: TextAlign.center,
                            style: context.type.footnote,
                          ),
                        ],
                        if (declarationBox) ...[
                          const SizedBox(height: PantasSpace.s8),
                          SellerLine(
                            facts: sellerFacts,
                            style: context.type.footnote,
                            textAlign: TextAlign.center,
                            onEmail: _emailSupport,
                          ),
                        ],
                      ],
                      if (playRenews)
                        Text(
                          'Your Google Play plan keeps renewing. '
                          'Cancel it in Google Play if you no longer need it.',
                          textAlign: TextAlign.center,
                          style: context.type.footnote,
                        ),
                      // ST_ProPending: Open Google Play is the filled button.
                      if (phoneOpen)
                        PantasButton(
                          label: 'Open Google Play',
                          onPressed: _busy ? null : () => _manage(entitlement),
                        ),
                      // ST_SwitchUpgrade draws it as the 52 full-width ghost
                      // button under the CTA.
                      if (upgrade)
                        PantasButton(
                          label: widget.freeLabel ?? 'Switch on Free',
                          variant: PantasButtonVariant.tertiary,
                          size: PantasButtonSize.phone,
                          onPressed: _busy ? null : _switchOnFree,
                        ),
                      // The boards put 8 between the CTA, the fine print and
                      // the Restore line.
                      if (restoreLine) ...[
                        if (showOffers || playRenews || phoneOpen)
                          const SizedBox(height: PantasSpace.s8),
                        PantasButton(
                          label: 'Restore Purchases',
                          variant: PantasButtonVariant.tertiary,
                          size: PantasButtonSize.textPhoneSm,
                          busy: _busy,
                          onPressed: _busy ? null : _restore,
                        ),
                      ],
                      // Ruling C6: with the card on the page the line always
                      // holds its height, so the bar never changes size.
                      if (declarationBox)
                        _StatusLine(
                          message: _feedback,
                          hint: _tickHint,
                          showHint: payOff,
                        )
                      else if (_feedback != null)
                        Text(
                          _feedback!,
                          textAlign: TextAlign.center,
                          style: context.type.footnote,
                        ),
                    ],
                  ),
                ),
              ),
            ),
      backLabel: upgrade ? 'Exam' : 'Settings',
      onBack: () => leavePage(
        context,
        fallback: upgrade ? '/settings/exam' : '/settings',
      ),
      children: [
        if (widget.checkoutReturnUri?.queryParameters['benefit'] == 'diagnosis')
          Padding(
            padding: const EdgeInsets.only(bottom: PantasSpace.s24),
            child: Semantics(
              header: true,
              child: Text(
                'See which lesson your misses trace to',
                style: context.type.sectionHero,
              ),
            ),
          ),
        if (context.wideWeb && !upgrade) ...[
          WebProHero(
            heading: owned
                ? "You're on Pro."
                : lapsed
                    ? passEnded
                        ? 'Your Season Pass ended'
                        : 'Your Pro plan ended'
                    : "See exactly what's losing you points.",
            detail: owned
                ? "Thanks for backing Pantas. Here's everything "
                    "that's yours."
                : lapsed
                    ? 'It ended '
                        '${passEnded ? "after your exam " : ""}on '
                        '${DateFormat.yMMMd().format(ended)}. Nothing was lost.'
                    : null,
          ),
          const SizedBox(height: PantasSpace.s24),
        ] else if (!upgrade) ...[
          // The eyebrow stays on the page: small text on the hero's light
          // top misses 4.5:1 (Card README: body text in the lower 60%).
          Text('PANTAS PRO', style: context.type.sectionHeader),
          const SizedBox(height: PantasSpace.s12),
          // The teal hero (phone, `.card--hero`, D126).
          PhoneProHero(
            heading: owned
                ? "You're on Pro."
                : lapsed
                    ? passEnded
                        ? 'Your Season Pass ended'
                        : 'Your Pro plan ended'
                    : "See exactly what's losing you points.",
            detail: owned
                ? "Thanks for backing Pantas. Here's everything that's yours."
                : lapsed
                    ? passEnded
                        ? 'It ended after your exam on '
                            '${DateFormat.yMMMd().format(ended)}.'
                        : 'It ended on ${DateFormat.yMMMd().format(ended)}.'
                    : null,
          ),
          const SizedBox(height: PantasSpace.s24),
        ] else ...[
          const SizedBox(height: PantasSpace.s12),
          if (upgrade)
            Container(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s18,
                PantasSpace.s18,
                PantasSpace.s18,
                PantasSpace.s20,
              ),
              decoration: BoxDecoration(
                color: context.colors.surfaceCard,
                borderRadius: BorderRadius.circular(PantasRadius.lg),
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PantasRadius.lg),
                border: Border.all(color: context.colors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gold marks only Pro (D54), so the mark is the Pro mark.
                  const ProMark(),
                  const SizedBox(height: PantasSpace.s12),
                  Text(
                    '${exam!.shortName} has its own price tier',
                    style: context.type.pageTitle,
                  ),
                  const SizedBox(height: PantasSpace.s6),
                  Text(
                    'Your Pro covers '
                    "${widget.previousExamName ?? 'student exams'} "
                    'and other student exams only. '
                    'Pro for ${exam.shortName} covers those too '
                    'if you upgrade.',
                    style: PantasType.phoneCallout
                        .copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
          if (owned) ...[
            const SizedBox(height: PantasSpace.s8),
            Text(
              "Thanks for backing Pantas. Here's everything that's yours.",
              style: context.type.body,
            ),
          ],
          if (lapsed)
            Text(
              passEnded
                  ? 'It ended after your exam on '
                      '${DateFormat.yMMMd().format(ended)}.'
                  : 'It ended on ${DateFormat.yMMMd().format(ended)}.',
              style: context.type.body,
            ),
          const SizedBox(height: PantasSpace.s24),
          const SizedBox(height: PantasSpace.s24),
        ],
        if (!showOffers && whyLine != null) ...[
          whyLine,
          const SizedBox(height: PantasSpace.s20),
        ],
        if (paused) const ProPausedLine(),
        if (!upgrade &&
            !rewardElsewhere &&
            (entitlement.proIsActive || paused) &&
            (entitlement.passes.isEmpty ||
                rewardShown ||
                entitlement.plan != EntitlementPlan.free ||
                entitlement.isUnknownPlan ||
                entitlement.promotions.isNotEmpty)) ...[
          SettingsSection(
            header: 'Your plan',
            footer: web && entitlement.isTrial && planDate != null
                ? 'Your free trial ends on '
                    '${DateFormat.yMMMd().format(planDate)}. '
                    "You won't be charged."
                : null,
            children: [
              SettingsRow(
                title: 'Plan',
                value: planName,
                variant: ListRowVariant.value,
                divider: true,
              ),
              if (planDate != null)
                SettingsRow(
                  title: web ||
                          entitlement.plan == EntitlementPlan.free ||
                          !entitlement.willRenew
                      ? 'Ends'
                      : entitlement.isTrial
                          ? 'Charges'
                          : 'Renews',
                  value: DateFormat.yMMMd().format(planDate),
                  variant: ListRowVariant.value,
                ),
              if (entitlement.state == EntitlementState.billingIssue)
                Text(
                  'There is a problem with your payment.',
                  style: context.type.footnote
                      .copyWith(color: context.colors.destructive),
                ),
            ],
          ),
          // The phone boards put 22 between cards (ST_ProPro).
          if (!context.wideWeb)
            const SizedBox(height: PantasSpace.s20 + PantasSpace.s2),
        ],
        for (final pass in entitlement.passes.entries) ...[
          SettingsSection(
            header: 'Your plan',
            footer:
                'A one-time purchase. It ends after the exam and never renews.',
            children: [
              const SettingsRow(
                title: 'Plan',
                value: 'Season Pass',
                variant: ListRowVariant.value,
                divider: true,
              ),
              if (passNames[pass.key]?.shortName != null ||
                  pass.key == exam?.id)
                SettingsRow(
                  title: 'Exam',
                  value: passNames[pass.key]?.shortName ?? exam?.shortName,
                  variant: ListRowVariant.value,
                  divider: true,
                ),
              SettingsRow(
                title: 'Ends',
                value: DateFormat.yMMMd().format(pass.value),
                variant: ListRowVariant.value,
              ),
            ],
          ),
          SizedBox(
            height: context.wideWeb
                ? PantasSpace.s20
                : PantasSpace.s20 + PantasSpace.s2,
          ),
        ],
        if (waiting)
          SettingsSection(
            children: [
              Padding(
                padding: const EdgeInsets.all(PantasSpace.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waiting for your payment',
                      style: context.type.emphasized,
                    ),
                    const SizedBox(height: PantasSpace.s8),
                    Text(
                      '${pendingPlan}Pay in GCash or at the counter to finish. '
                      'Pro turns on as soon as Google Play confirms it.',
                      style: context.type.body,
                    ),
                    if (context.wideWeb)
                      PantasButton(
                        label: 'Open Google Play',
                        variant: PantasButtonVariant.tertiary,
                        onPressed: _busy ? null : () => _manage(entitlement),
                      ),
                  ],
                ),
              ),
            ],
          ),
        if (showOffers) ...[
          if (exam != null)
            Padding(
              padding: EdgeInsets.only(
                left: context.wideWeb ? PantasSpace.s4 : PantasSpace.s0,
                bottom: context.wideWeb ? PantasSpace.s10 : PantasSpace.s0,
              ),
              child: Text(
                'PLANS FOR ${exam.shortName.toUpperCase()}',
                style: context.wideWeb
                    ? context.webTokens.eb.copyWith(height: 1.3)
                    : context.type.sectionHeader,
              ),
            ),
          if (whyLine != null) ...[
            Padding(
              padding: EdgeInsets.only(
                left: context.wideWeb ? PantasSpace.s4 : PantasSpace.s0,
                top: PantasSpace.s4,
              ),
              child: whyLine,
            ),
          ],
          SizedBox(
            height: context.wideWeb ? PantasSpace.s6 : PantasSpace.s12,
          ),
          if (offering.isLoading) const Text('Loading subscriptions...'),
          if (packages.isNotEmpty)
            _plansGrid(
              context,
              tiles: [
                for (final package in packages)
                  _plan(
                    context,
                    package,
                    selectedPackage?.productId == package.productId,
                    () => setState(() => _selected = package.productId),
                    monthly: packages
                        .where((p) => p.sku == PaywallSku.monthly)
                        .firstOrNull,
                    showTrial: !upgrade &&
                        !lapsed &&
                        !entitlement.proIsActive &&
                        !(web && anonymous),
                  ),
              ],
              wide: [
                if (upgrade || context.wideWeb)
                  for (final pass in passes)
                    ProPlanTile(
                      name: 'Season Pass',
                      amount: _money(pass.priceString),
                      period: 'one time',
                      sub: passDetail,
                      selected: selectedPass == pass,
                      unavailable: sitting == null,
                      onTap: sitting == null || _busy
                          ? null
                          : () => setState(() => _selected = pass.productId),
                    ),
              ],
            ),
          for (final pass in upgrade || context.wideWeb
              ? const <PaywallPassPackage>[]
              : passes) ...[
            const SizedBox(height: PantasSpace.s10),
            ProPlanTile(
              name: 'Season Pass',
              amount: _money(pass.priceString),
              period: 'one time',
              sub: passDetail,
              selected: selectedPass == pass,
              unavailable: sitting == null,
              onTap: sitting == null || _busy
                  ? null
                  : () => setState(() => _selected = pass.productId),
            ),
          ],
          if (!custom &&
              passes.isEmpty &&
              sitting == null &&
              exam?.priceTier == 'Civil Service') ...[
            const SizedBox(height: PantasSpace.s20),
            const SettingsSection(
              children: [
                SettingsRow(
                  title: 'Season Pass',
                  subtitle: 'Once the next date is out',
                  variant: ListRowVariant.value,
                ),
              ],
            ),
          ],
          if (declarationBox) ...[
            SizedBox(
              height: context.wideWeb ? PantasSpace.s28 : PantasSpace.s24,
            ),
            DeclarationCard(
              key: _cardKey,
              tickFocus: _tickFocus,
              tickPulse: _tickPulse,
              kind: declarationKind,
              ticked: declarationTicked,
              onToggle: _busy
                  ? null
                  : () => setState(
                        () => _tickedFor = declarationTicked ? null : tickKey,
                      ),
              onOpenTerms: _openTerms,
            ),
          ],
          // The wide page adds its own 24 px before the Restore row.
          SizedBox(
            height: context.wideWeb ? PantasSpace.s0 : PantasSpace.s24,
          ),
          // A pass-only exam has something to buy: no retry.
          if (!offering.isLoading && packages.isEmpty && passes.isEmpty)
            PantasButton(
              label: 'Try Again',
              variant: PantasButtonVariant.secondary,
              onPressed: () =>
                  ref.invalidate(unfilteredPaywallOfferingProvider),
            ),
        ],
        if (customTierUnknown) ...[
          if (customTierAsync?.isLoading ?? false)
            const Text('Loading subscriptions...')
          else
            PantasButton(
              label: 'Try Again',
              variant: PantasButtonVariant.secondary,
              onPressed: () => ref.invalidate(activeCustomTrackTierProvider),
            ),
        ],
        if (!context.wideWeb && (manageRow || restoreRow))
          SettingsSection(
            // With a bar on the page the bar already says how Restore went.
            footer: phoneBar ? null : _feedback,
            children: [
              if (manageRow)
                SettingsRow(
                  title: 'Manage in Google Play',
                  divider: restoreRow,
                  onTap: _busy ? null : () => _manage(entitlement),
                ),
              if (restoreRow)
                SettingsRow(
                  title: 'Restore purchases',
                  titleColor: context.colors.accent,
                  hideChevron: true,
                  onTap: _busy ? null : _restore,
                ),
            ],
          )
        else if (manageRow)
          SettingsRow(
            title: 'Manage in Google Play',
            onTap: _busy ? null : () => _manage(entitlement),
          ),
      ],
    );
  }

  /// Drops ".00" so a whole amount shows no centavos, on phone and web (boards
  /// ST_ProFree and ST_ProCSE). The amount itself still comes from the price
  /// source; real centavos stay.
  String _money(String priceString) => wholePesos(priceString);

  ProPlanTile _plan(
    BuildContext context,
    PaywallPackage package,
    bool selected,
    VoidCallback choose, {
    required bool showTrial,
    PaywallPackage? monthly,
  }) {
    final label = switch (package.sku) {
      PaywallSku.weekly => 'Weekly',
      PaywallSku.monthly => 'Monthly',
      PaywallSku.yearly => 'Yearly'
    };
    final savings = monthly == null || monthly.priceAmount <= 0
        ? null
        : ((1 - package.priceAmount / (monthly.priceAmount * 12)) * 100)
            .floor();
    final monthlyEquivalent = package.priceString.replaceFirst(
      RegExp('[0-9][0-9,.]*'),
      NumberFormat.decimalPattern('en_PH')
          .format((package.priceAmount / 12).ceil()),
    );
    final badge = showTrial &&
            package.sku == PaywallSku.monthly &&
            package.trialEligible &&
            !_trialUnavailable
        ? '7 DAYS FREE'
        : package.sku == PaywallSku.yearly && savings != null && savings > 0
            ? 'SAVE $savings%'
            : null;
    return ProPlanTile(
      name: label,
      amount: _money(package.priceString),
      period: 'a ${_period(package.sku).toLowerCase()}',
      sub: package.sku == PaywallSku.yearly
          ? '$monthlyEquivalent a month'
          : null,
      tag: badge,
      selected: selected,
      onTap: _busy ? null : choose,
    );
  }

  /// The plan tiles: three across on a wide page and one per row on the phone
  /// (SelectableTile, plan grid). The Season Pass tile in [wide] spans the row
  /// below them. A tagged tile makes its untagged siblings keep the same
  /// header slot, and the grid adds half the tag above itself (D190).
  Widget _plansGrid(
    BuildContext context, {
    required List<ProPlanTile> tiles,
    List<ProPlanTile> wide = const [],
  }) {
    final anyTag = tiles.any((tile) => tile.tag != null);
    final row = context.wideWeb && tiles.length > 1;
    // Only tiles that share a row keep an empty tag slot, so their tops line
    // up; a tile alone on its row needs none.
    final shown = [
      for (final tile in tiles)
        if (row && anyTag && tile.tag == null)
          ProPlanTile(
            name: tile.name,
            amount: tile.amount,
            period: tile.period,
            sub: tile.sub,
            selected: tile.selected,
            onTap: tile.onTap,
            reserveTagSlot: true,
          )
        else
          tile,
    ];
    return Padding(
      padding: EdgeInsets.only(
        top: anyTag
            ? SelectableTile.tagHeight(context) / PantasSpace.s2
            : PantasSpace.s0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (row)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, tile) in shown.indexed) ...[
                    if (index > 0) const SizedBox(width: PantasSpace.s10),
                    Expanded(child: tile),
                  ],
                ],
              ),
            )
          else
            for (final (index, tile) in shown.indexed) ...[
              // A tagged tile wears its tag half above its top edge, so the
              // gap above it grows by that half and the tag stays on its own
              // tile instead of covering the one before it (D190).
              if (index > 0)
                SizedBox(
                  height: PantasSpace.s10 +
                      (tile.tag == null
                          ? PantasSpace.s0
                          : SelectableTile.tagHeight(context) / PantasSpace.s2),
                ),
              tile,
            ],
          for (final tile in wide) ...[
            const SizedBox(height: PantasSpace.s10),
            tile,
          ],
        ],
      ),
    );
  }
}

/// The one line that says why a custom exam sits in its tier.
String _tierLine(String name, CustomTrackTier tier) {
  final level = CustomSubjectTiers.levelLabel(tier.tier);
  final because = tier.becauseOf;
  if (tier.tier == PriceTier.student || because == null) {
    return '$name is a $level exam.';
  }
  return '$name is a $level exam because it includes $because.';
}

String _period(PaywallSku sku) => switch (sku) {
      PaywallSku.weekly => 'Week',
      PaywallSku.monthly => 'Month',
      PaywallSku.yearly => 'Year',
    };

String _periodName(PaywallSku sku) => switch (sku) {
      PaywallSku.weekly => 'Weekly',
      PaywallSku.monthly => 'Monthly',
      PaywallSku.yearly => 'Yearly'
    };

/// The phone's bottom action bar (PhoneFrame `.phone-bottom`): on the page
/// color, with a fade from transparent so the scrolling plans do not end in a
/// hard cut under it.
/// What the status line and Pay's screen reader hint say while the box is
/// unticked (ruling C6).
const _tickHint = 'Tick the box to pay.';

/// The phone bar's status line. It always takes one line of room, so the bar
/// keeps its height. A message shows as it is; the hint fades out over 150 ms
/// once the box is ticked.
class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.message,
    required this.hint,
    required this.showHint,
  });
  final String? message;
  final String hint;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final shown = message != null || showHint;
    return ExcludeSemantics(
      // Pay carries the hint for a screen reader; only a message is read here.
      excluding: message == null,
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : PantasDurations.short2,
        curve: PantasCurves.fade,
        child: Text(
          message ?? hint,
          textAlign: TextAlign.center,
          style: context.type.footnote,
        ),
      ),
    );
  }
}

class _FadedBar extends StatelessWidget {
  const _FadedBar({required this.child, this.visible = true});
  final Widget child;

  /// False when the bar would hold nothing (Pro owned: Restore is a card row).
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final page = context.colors.background;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: -PantasSpace.s24,
          height: PantasSpace.s24,
          child: IgnorePointer(
            child: DecoratedBox(
              key: const ValueKey('pro-bar-fade'),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [page.withValues(alpha: 0), page],
                ),
              ),
            ),
          ),
        ),
        ColoredBox(color: page, child: child),
      ],
    );
  }
}
