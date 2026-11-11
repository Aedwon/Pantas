import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/app/telemetry_providers.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/platform/first_screen_ready.dart';
import 'package:pantas/core/storage/age_gate.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/storage/storage.dart';
import 'package:pantas/core/telemetry/telemetry.dart';
import 'package:pantas/core/ui/components/google_sign_in_button.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/components/selectable_tile.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/leave_page.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';
import 'package:pantas/features/home/application/study_delivery.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
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
import 'package:pantas/features/settings/presentation/widgets/pro_perks.dart';
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

const _guardianBoxLabel = 'I am the parent or guardian and accept the Terms.';

class _ProPageState extends ConsumerState<ProPage> with WidgetsBindingObserver {
  bool _awaitingCheckout = false;
  bool _wasCurrent = true;
  String? _checkoutUid;
  String? _selected;
  String? _feedback;
  bool _busy = false;
  bool _restoring = false;
  bool _trialUnavailable = false;

  /// The parent or guardian box on a minor's checkout (boards CB_*).
  bool _guardianTicked = false;
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
    if (raw == null || raw.isEmpty || !_sameAccount(uid)) return;
    Map<String, dynamic> pending;
    PriceTier tier;
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
      // Only this checkout may consume its pending switch.
      await prefs.setDeviceValue(key, '');
      if (!_sameAccount(uid)) return;
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
      return;
    }
    final target = widget.targetExam ??
        (await ref.read(examCatalogRepositoryProvider).watchAll().first)
            .where((entry) => entry.id == pending['examId'])
            .firstOrNull;
    if (!_sameAccount(uid)) return;
    final created =
        DateTime.fromMillisecondsSinceEpoch(pending['createdAt'] as int);
    final age = DateTime.now().difference(created);
    if (target == null ||
        pending['uid'] != uid ||
        pending['examId'] != target.id ||
        tier != PriceTier.fromCatalog(target.priceTier) ||
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
          "We found a purchase, but Pro couldn't be confirmed yet. "
              'Try again in a moment.',
        PaymentOperationStatus.storeFailure => ref.read(paymentsOnWebProvider)
            ? "We couldn't confirm your subscription. Try again."
            : "Google Play couldn't complete this purchase. Try again.",
        _ => "We couldn't confirm your subscription. Try again.",
      };

  /// Boards CB_Wide, CB_Ph: the box in its own card under the plans. Terms
  /// opens the Terms and does not tick the box.
  Widget _guardianBoxCard(BuildContext context) {
    final wide = context.wideWeb;
    final style = PantasType.webRowTitleSettings
        .copyWith(color: context.colors.textPrimary);
    final row = CheckboxRow(
      title: _guardianBoxLabel,
      selected: _guardianTicked,
      gap: PantasSpace.s14,
      standardDensity: true,
      squareEdges: wide,
      interactiveContent: true,
      onTap: _busy
          ? null
          : () => setState(() => _guardianTicked = !_guardianTicked),
      content: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ExcludeSemantics(
            child: Text(
              'I am the parent or guardian and accept the ',
              style: style,
            ),
          ),
          WebTextLink(
            label: 'Terms',
            arrow: false,
            style: style,
            onPressed: () {
              final router = GoRouter.maybeOf(context);
              if (router != null) unawaited(router.push<void>('/legal/terms'));
            },
          ),
          ExcludeSemantics(child: Text('.', style: style)),
        ],
      ),
    );
    return wide ? WebCard(child: row) : GroupedSection(children: [row]);
  }

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
    bool guardianAttested = false,
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
                guardianAttested: guardianAttested,
              )
            : await gateway.purchase(
                package!,
                beforeRedirect: beforeRedirect,
                guardianAttested: guardianAttested,
              );
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
    firstScreenReady(context, ref, ready: !offering.isLoading);
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
        : '${_periodName(pendingPackage.sku)}, '
            '${_money(pendingPackage.priceString)}. ';
    final showOffers = covered == false && !paused && !waiting;
    // A minor's payment needs the box ticked. The server is the control; the
    // device age group only decides whether the box shows. The free trial
    // takes no payment, so it has no box.
    final buyShown = showOffers &&
        !(web && anonymous) &&
        exam != null &&
        (selectedPackage != null || selectedPass != null);
    final guardianBox = buyShown &&
        ref.watch(ageGroupProvider).valueOrNull == 'minor' &&
        !(trial && !lapsed);
    final buyLocked = _busy || (guardianBox && !_guardianTicked);
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
                    Transform.translate(
                      offset: const Offset(-PantasSpace.s14, 0),
                      child: WebButton(
                        label: upgrade
                            ? 'Switch on Free'
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
                                          guardianAttested: guardianBox,
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
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PantasSpace.s16,
                    PantasSpace.s14,
                    PantasSpace.s16,
                    PantasSpace.s16,
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
                            onPressed: buyLocked
                                ? null
                                : () => _purchase(
                                      selectedPackage,
                                      selectedPass,
                                      exam,
                                      allowTrial: trial && !lapsed,
                                      guardianAttested: guardianBox,
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
                          label: 'Restore Purchases',
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
        ] else ...[
          if (!upgrade) Text('PANTAS PRO', style: context.type.sectionHeader),
          const SizedBox(height: PantasSpace.s12),
          if (!upgrade)
            Text(
              owned
                  ? "You're on Pro."
                  : lapsed
                      ? passEnded
                          ? 'Your Season Pass ended'
                          : 'Your Pro plan ended'
                      : "See exactly what's losing you points.",
              style: context.type.pageTitle,
            ),
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
          if (!upgrade)
            for (final feature in proPerks)
              Padding(
                padding: const EdgeInsets.only(bottom: PantasSpace.s12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      feature.$1,
                      color: context.colors.accent,
                      size: PantasSize.icon,
                    ),
                    const SizedBox(width: PantasSpace.s12),
                    Expanded(
                      child: Text(feature.$2, style: context.type.subhead),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: PantasSpace.s24),
        ],
        if (paused) const ProPausedLine(),
        if (!upgrade &&
            (entitlement.proIsActive || paused) &&
            (entitlement.passes.isEmpty ||
                entitlement.plan != EntitlementPlan.free ||
                entitlement.isUnknownPlan ||
                entitlement.promotions.isNotEmpty))
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
          const SizedBox(height: PantasSpace.s20),
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
          if (passes.isEmpty &&
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
          if (guardianBox) ...[
            SizedBox(
              height: context.wideWeb ? PantasSpace.s28 : PantasSpace.s24,
            ),
            _guardianBoxCard(context),
          ],
          // The wide page adds its own 24 px before the Restore row.
          SizedBox(
            height: context.wideWeb ? PantasSpace.s0 : PantasSpace.s24,
          ),
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
class _FadedBar extends StatelessWidget {
  const _FadedBar({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
