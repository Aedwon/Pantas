import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/coverage.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_providers.dart';
import 'package:pantas/features/settings/application/carry_over_providers.dart';
import 'package:pantas/features/settings/presentation/carry_over_prompt.dart';
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
    super.key,
  });
  final SubscriptionManagementLauncher subscriptionLauncher;
  final Uri? checkoutReturnUri;
  final ExamCatalogEntry? targetExam;
  final String? previousExamName;
  final Future<void> Function()? onSwitchOnFree;
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
  bool _trialUnavailable = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    super.dispose();
  }

  Future<void> _clearPendingExamSwitch({String? uid}) async {
    final owner = uid ?? _checkoutUid;
    if (owner == null) return;
    final telemetry = ref.read(telemetryProvider);
    try {
      await ref
          .read(appPreferencesRepositoryProvider)
          .setDeviceValue('checkout_exam_v1:$owner', '');
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
    await prefs.setDeviceValue(
      'checkout_exam_v1:$uid',
      jsonEncode({
        'uid': uid,
        'examId': target.id,
        'count': choice,
        'tier': PriceTier.fromCatalog(target.priceTier).name,
        'fromExamId': fromExamId,
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
    // Consume the intent even when the return has no confirmed grant.
    await prefs.setDeviceValue(key, '');
    if (raw == null || raw.isEmpty || !_sameAccount(uid)) return;
    Map<String, dynamic> pending;
    PriceTier tier;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> ||
          decoded['uid'] is! String ||
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
      return;
    }
    final target = widget.targetExam;
    final uri = widget.checkoutReturnUri ?? Uri.base;
    final created =
        DateTime.fromMillisecondsSinceEpoch(pending['createdAt'] as int);
    final age = DateTime.now().difference(created);
    if (target == null ||
        pending['uid'] != uid ||
        pending['examId'] != target.id ||
        tier != PriceTier.fromCatalog(target.priceTier) ||
        pending['sessionId'] != uri.queryParameters['session_id'] ||
        age.isNegative ||
        age > const Duration(hours: 24)) {
      return;
    }
    final entitlement = operation.confirmedEntitlement;
    final examId = target.id;
    if (operation.status != PaymentOperationStatus.success ||
        entitlement == null ||
        !entitlement.coverage(at: DateTime.now()).coversExam(examId, tier)) {
      return;
    }
    final from = await prefs.selectedExamId();
    if (!_sameAccount(uid) || from != pending['fromExamId']) return;
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
        PaymentOperationStatus.success => restore ? 'Pro restored.' : null,
        PaymentOperationStatus.noActiveSubscription =>
          'No purchases found for this account.',
        PaymentOperationStatus.userCancelled ||
        PaymentOperationStatus.operationAlreadyInProgress =>
          null,
        PaymentOperationStatus.networkFailure =>
          'No internet connection. Please try again.',
        PaymentOperationStatus.entitlementNotActive =>
          'We found a purchase, but Pro couldn’t be confirmed yet. '
              'Try again in a moment.',
        PaymentOperationStatus.storeFailure => ref.read(paymentsOnWebProvider)
            ? 'We couldn’t confirm your subscription. Try again.'
            : 'Google Play couldn’t complete this purchase. Try again.',
        _ => 'We couldn’t confirm your subscription. Try again.',
      };
  Future<void> _restore() async {
    if (_busy) return;
    final uid = ref.read(currentUserProvider).unwrapPrevious().valueOrNull?.uid;
    setState(() {
      _busy = true;
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
  }) async {
    if (_busy || (package == null && pass == null)) return;
    final telemetry = ref.read(telemetryProvider);
    final web = ref.read(paymentsOnWebProvider);
    if (web && (ref.read(isAnonymousProvider).valueOrNull ?? true)) return;
    final uid = ref.read(currentUserProvider).unwrapPrevious().valueOrNull?.uid;
    if (web && uid == null) return;
    setState(() {
      _busy = true;
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
    PaymentOperationStatus status;
    final gateway = ref.read(revenueCatGatewayProvider);
    if (web &&
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
      final controller = ref.read(paywallControllerProvider);
      if (web && uid != null && gateway is WebPaymentGateway) {
        _checkoutUid = uid;
        Future<void> beforeRedirect(String sessionId) async {
          if (!_sameAccount(uid)) throw StateError('Checkout account changed');
          if (widget.targetExam == null) return;
          final prefs = ref.read(appPreferencesRepositoryProvider);
          final raw = await prefs.deviceValue('checkout_exam_v1:$uid');
          if (!_sameAccount(uid)) throw StateError('Checkout account changed');
          final pending = jsonDecode(raw!) as Map<String, dynamic>;
          pending['sessionId'] = sessionId;
          pending['createdAt'] = DateTime.now().millisecondsSinceEpoch;
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
              )
            : await gateway.purchase(package!, beforeRedirect: beforeRedirect);
        status = result.status;
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
    if (!mounted) return;
    final sameAccount = web
        ? uid != null && _sameAccount(uid)
        : uid ==
            ref.read(currentUserProvider).unwrapPrevious().valueOrNull?.uid;
    if (sameAccount &&
        widget.targetExam != null &&
        status == PaymentOperationStatus.success) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      // C3 returns this status after opening PayMongo in this tab.
      _awaitingCheckout = sameAccount &&
          web &&
          status == PaymentOperationStatus.operationAlreadyInProgress;
      _busy = _awaitingCheckout;
      if (sameAccount) _feedback = _message(status);
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
          _feedback = 'We couldn’t open Google Play. You can manage your '
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
    final upgrade = widget.targetExam != null;
    final covered =
        upgrade ? false : ref.watch(proForActiveExamProvider).valueOrNull;
    final web = ref.watch(paymentsOnWebProvider);
    final anonymous =
        ref.watch(isAnonymousProvider).unwrapPrevious().valueOrNull ?? true;
    final exam = widget.targetExam ??
        ref.watch(activeProCatalogEntryProvider).valueOrNull;
    final offering = (upgrade
            ? ref.watch(unfilteredPaywallOfferingProvider)
            : ref.watch(paywallOfferingProvider))
        .unwrapPrevious();
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
        : ref.watch(ownedPassCatalogEntriesProvider).valueOrNull ??
            const <String, ExamCatalogEntry>{};
    final fallbackPlanEnd =
        entitlement.passes.isEmpty ? entitlement.endsAt : null;
    final planDate = entitlement.plan != EntitlementPlan.free
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
                  row.endsAt.isBefore(DateTime.now()) &&
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

    final lapsed =
        covered == false && ended != null && ended.isBefore(DateTime.now());
    final now = DateTime.now().toUtc().add(const Duration(hours: 8));
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
        : '${_periodName(pendingPackage.sku)}, ${pendingPackage.priceString}. ';
    final showOffers = covered == false && !paused && !waiting;
    return PantasPage(
      title: '',
      bottom: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showOffers) ...[
                if (web && anonymous)
                  PantasButton(
                    label: 'Continue with Google',
                    onPressed: () => context.push<void>('/settings/account'),
                  )
                else if (exam != null &&
                    (selectedPackage != null || selectedPass != null))
                  PantasButton(
                    label: selectedPass != null
                        ? 'Buy Season Pass'
                        : upgrade
                            ? 'Upgrade for '
                                '${selectedPackage!.priceString} a Month'
                            : trial && !lapsed
                                ? 'Try 7 Days Free'
                                : lapsed
                                    ? 'Get Pro Again'
                                    : 'Subscribe for '
                                        '${selectedPackage!.priceString} '
                                        'a ${_period(selectedPackage.sku)}',
                    busy: _busy,
                    onPressed: _busy
                        ? null
                        : () => _purchase(
                              selectedPackage,
                              selectedPass,
                              exam,
                              allowTrial: trial && !lapsed,
                            ),
                  ),
                if (selectedPass != null && sitting != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${selectedPass.priceString} once. '
                    'Ends after the exam on $sittingEnd.',
                    textAlign: TextAlign.center,
                    style: context.type.footnote,
                  ),
                ] else if (trial && !lapsed) ...[
                  const SizedBox(height: 8),
                  Text(
                    web
                        ? 'No payment needed.'
                        : 'Then ${selectedPackage.priceString} a month. '
                            'Cancel any time in Google Play.',
                    textAlign: TextAlign.center,
                    style: context.type.footnote,
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
              if (upgrade)
                PantasButton(
                  label: 'Switch on Free',
                  variant: PantasButtonVariant.tertiary,
                  onPressed: _busy ? null : _switchOnFree,
                ),
              if (!upgrade)
                PantasButton(
                  label: 'Restore purchases',
                  variant: PantasButtonVariant.tertiary,
                  busy: _busy,
                  onPressed: _busy ? null : _restore,
                ),
              if (_feedback != null)
                Text(
                  _feedback!,
                  textAlign: TextAlign.center,
                  style: context.type.footnote,
                ),
            ],
          ),
        ),
      ),
      backLabel: upgrade ? 'Exam' : 'Settings',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        if (!upgrade) Text('PANTAS PRO', style: context.type.sectionHeader),
        const SizedBox(height: 12),
        if (!upgrade)
          Text(
            owned
                ? 'You’re on Pro.'
                : lapsed
                    ? passEnded
                        ? 'Your Season Pass ended'
                        : 'Your Pro plan ended'
                    : 'See exactly what’s losing you points.',
            style: context.type.pageTitle,
          ),
        if (upgrade)
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  PantasIcons.pro,
                  size: 36,
                  color: context.colors.warningText,
                ),
                const SizedBox(height: 12),
                Text(
                  '${exam!.shortName} has its own price tier',
                  style: context.type.pageTitle
                      .copyWith(fontSize: 28, height: 1.2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Your Pro covers '
                  "${widget.previousExamName ?? 'student exams'} "
                  'and other student exams only. '
                  'Pro for ${exam.shortName} covers those too if you upgrade.',
                  style: context.type.body.copyWith(
                    fontSize: 16,
                    color: context.colors.secondaryLabel,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        if (owned) ...[
          const SizedBox(height: 8),
          Text(
            'Thanks for backing Pantas. Here’s everything that’s yours.',
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
        const SizedBox(height: 24),
        if (!upgrade)
          for (final feature in [
            (PantasIcons.unlimitedMocks, 'Unlimited mock exams'),
            (PantasIcons.answerNotes, 'Notes on why your answer was wrong'),
            (PantasIcons.studyHabits, 'The figures behind your study habits'),
            (PantasIcons.proBackup, 'Progress that’s always backed up'),
            (PantasIcons.topicResults, 'Results by topic and lesson'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(feature.$1, color: context.colors.accent, size: 21),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(feature.$2, style: context.type.subhead),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 24),
        if (paused) const ProPausedLine(),
        if (!upgrade &&
            (entitlement.proIsActive || paused) &&
            (entitlement.passes.isEmpty ||
                entitlement.plan != EntitlementPlan.free ||
                entitlement.isUnknownPlan ||
                entitlement.promotions.isNotEmpty))
          GroupedSection(
            header: 'Your plan',
            footer: web && entitlement.isTrial && planDate != null
                ? 'Your free trial ends on '
                    '${DateFormat.yMMMd().format(planDate)}. '
                    'You won’t be charged.'
                : null,
            children: [
              ListRow(
                title: 'Plan',
                value: planName,
                variant: ListRowVariant.value,
                divider: true,
              ),
              if (planDate != null)
                ListRow(
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
        for (final pass in entitlement.passes.entries) ...[
          GroupedSection(
            header: 'Your plan',
            footer:
                'A one-time purchase. It ends after the exam and never renews.',
            children: [
              const ListRow(
                title: 'Plan',
                value: 'Season Pass',
                variant: ListRowVariant.value,
                divider: true,
              ),
              if (passNames[pass.key]?.shortName != null ||
                  pass.key == exam?.id)
                ListRow(
                  title: 'Exam',
                  value: passNames[pass.key]?.shortName ?? exam?.shortName,
                  variant: ListRowVariant.value,
                  divider: true,
                ),
              ListRow(
                title: 'Ends',
                value: DateFormat.yMMMd().format(pass.value),
                variant: ListRowVariant.value,
              ),
            ],
          ),
          const SizedBox(height: 22),
        ],
        if (waiting)
          GroupedSection(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waiting for your payment',
                      style: context.type.emphasized,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${pendingPlan}Pay in GCash or at the counter to finish. '
                      'Pro turns on as soon as Google Play confirms it.',
                      style: context.type.body,
                    ),
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
            Text(
              'PLANS FOR ${exam.shortName.toUpperCase()}',
              style: context.type.sectionHeader,
            ),
          const SizedBox(height: 12),
          if (offering.isLoading) const Text('Loading subscriptions...'),
          if (packages.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final package in packages)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _plan(
                        context,
                        package,
                        selectedPackage?.productId == package.productId,
                        () => setState(
                          () => _selected = package.productId,
                        ),
                        monthly: packages
                            .where((p) => p.sku == PaywallSku.monthly)
                            .firstOrNull,
                        showTrial: !upgrade &&
                            !lapsed &&
                            !entitlement.proIsActive &&
                            !(web && anonymous),
                      ),
                    ),
                  ),
                if (upgrade)
                  for (final pass in passes)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _choiceCard(
                          context,
                          label: 'Season Pass',
                          price: pass.priceString,
                          periodText: 'one time',
                          detail: passDetail,
                          selected: selectedPass == pass,
                          choose: sitting == null
                              ? null
                              : () =>
                                  setState(() => _selected = pass.productId),
                        ),
                      ),
                    ),
              ],
            ),
          for (final pass
              in upgrade ? const <PaywallPassPackage>[] : passes) ...[
            const SizedBox(height: 22),
            Semantics(
              button: true,
              selected: selectedPass == pass,
              enabled: sitting != null && !_busy,
              child: InkWell(
                onTap: sitting == null || _busy
                    ? null
                    : () => setState(() => _selected = pass.productId),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: selectedPass == pass
                        ? context.colors.accentTint
                        : context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedPass == pass
                          ? context.colors.accent
                          : context.colors.separator,
                      width: selectedPass == pass ? 2 : .5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Season Pass',
                              style: context.type.emphasized,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              passDetail,
                              style: context.type.footnote,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              pass.priceString,
                              style: context.type.emphasized
                                  .copyWith(fontSize: 22),
                            ),
                            Text('one time', style: context.type.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (passes.isEmpty &&
              sitting == null &&
              exam?.priceTier == 'Civil Service') ...[
            const SizedBox(height: 22),
            const GroupedSection(
              children: [
                ListRow(
                  title: 'Season Pass',
                  subtitle: 'Once the next date is out',
                  variant: ListRowVariant.value,
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          if (!offering.isLoading && packages.isEmpty)
            PantasButton(
              label: 'Try Again',
              variant: PantasButtonVariant.secondary,
              onPressed: () =>
                  ref.invalidate(unfilteredPaywallOfferingProvider),
            ),
        ],
        if (!web &&
            entitlement.proIsActive &&
            entitlement.plan != EntitlementPlan.free)
          ListRow(
            title: 'Manage in Google Play',
            onTap: _busy ? null : () => _manage(entitlement),
          ),
      ],
    );
  }

  Widget _plan(
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
    return _choiceCard(
      context,
      label: label,
      price: package.priceString,
      periodText: 'a ${_period(package.sku).toLowerCase()}',
      detail: package.sku == PaywallSku.yearly
          ? '$monthlyEquivalent a month'
          : null,
      badge: badge,
      trialBadge: package.sku == PaywallSku.monthly,
      selected: selected,
      choose: choose,
    );
  }

  Widget _choiceCard(
    BuildContext context, {
    required String label,
    required String price,
    required String periodText,
    required bool selected,
    required VoidCallback? choose,
    String? detail,
    String? badge,
    bool trialBadge = false,
  }) {
    final borderInset = selected ? 2.0 : .5;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: _busy ? null : choose,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                10 - borderInset,
                (MediaQuery.textScalerOf(context).scale(11) > 16.5 &&
                            badge != null
                        ? 48
                        : 18) -
                    borderInset,
                10 - borderInset,
                14 - borderInset,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? context.colors.accentTint
                    : context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? context.colors.accent
                      : context.colors.separator,
                  width: selected ? 2 : .5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    label,
                    style: context.type.subhead.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? context.colors.accent
                          : context.colors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: context.type.emphasized
                        .copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    periodText,
                    style: context.type.caption,
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: context.type.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colors.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: -10,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: trialBadge
                          ? context.colors.accentFill
                          : context.colors.label,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      badge,
                      textAlign: TextAlign.center,
                      style: context.type.caption.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: trialBadge
                            ? context.colors.onAccent
                            : context.colors.background,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
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
