import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pantas/core/auth/providers.dart';
import 'package:pantas/core/ui/components/grouped_section.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/components/pro_paused_line.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/web_payment_gateway.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';
import 'package:pantas/features/paywall/domain/products.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_providers.dart';
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

class ProPage extends ConsumerStatefulWidget {
  const ProPage({
    this.subscriptionLauncher = launchGooglePlaySubscriptionManagement,
    this.checkoutReturnUri,
    super.key,
  });
  final SubscriptionManagementLauncher subscriptionLauncher;
  final Uri? checkoutReturnUri;
  @override
  ConsumerState<ProPage> createState() => _ProPageState();
}

class _ProPageState extends ConsumerState<ProPage> {
  String? _selected;
  String? _feedback;
  bool _busy = false;
  bool _trialUnavailable = false;
  @override
  void initState() {
    super.initState();
    unawaited(ref.read(reviewPromptControllerProvider).recordPaywallSeen());
    Future<void>.microtask(_checkoutReturn);
  }

  Future<void> _checkoutReturn() async {
    if (!ref.read(paymentsOnWebProvider)) return;
    final gateway = ref.read(revenueCatGatewayProvider);
    if (gateway is! WebPaymentGateway) return;
    final user =
        await ref.read(currentUserProvider.future).onError((_, __) => null);
    if (!mounted ||
        user == null ||
        !identical(gateway, ref.read(revenueCatGatewayProvider))) {
      return;
    }
    final uid = user.uid;
    final operation = await gateway
        .handleCheckoutReturn(widget.checkoutReturnUri ?? Uri.base);
    if (!mounted ||
        uid != ref.read(currentUserProvider).valueOrNull?.uid ||
        operation == null) {
      return;
    }
    setState(() => _feedback = _message(operation.status));
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
  Future<void> _restore() async {
    if (_busy) return;
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    setState(() {
      _busy = true;
      _feedback = null;
    });
    final result = await ref.read(paywallControllerProvider).restore();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (uid == ref.read(currentUserProvider).valueOrNull?.uid) {
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
    final web = ref.read(paymentsOnWebProvider);
    if (web && (ref.read(isAnonymousProvider).valueOrNull ?? true)) return;
    final uid = ref.read(currentUserProvider).valueOrNull?.uid;
    setState(() {
      _busy = true;
      _feedback = null;
    });
    PaymentOperationStatus status;
    final gateway = ref.read(revenueCatGatewayProvider);
    if (web &&
        allowTrial &&
        package != null &&
        package.sku == PaywallSku.monthly &&
        package.trialEligible &&
        !_trialUnavailable &&
        gateway is WebPaymentGateway) {
      final result = await gateway.startTrial();
      status = result.operation.status;
      if (result.status == WebTrialStatus.notAvailable && mounted) {
        setState(() => _trialUnavailable = true);
        status = PaymentOperationStatus.userCancelled;
      }
    } else {
      final controller = ref.read(paywallControllerProvider);
      final result = pass != null
          ? await controller.purchasePass(pass, exam: exam)
          : await controller.purchase(package!);
      status = result.status;
    }
    if (!mounted) return;
    final sameAccount = uid == ref.read(currentUserProvider).valueOrNull?.uid;
    setState(() {
      // C3 returns this status after opening PayMongo in this tab.
      _busy = sameAccount &&
          web &&
          status == PaymentOperationStatus.operationAlreadyInProgress;
      if (sameAccount) _feedback = _message(status);
    });
  }

  Future<void> _manage(Entitlement entitlement) async {
    if (_busy) return;
    setState(() => _busy = true);
    var opened = false;
    try {
      opened = await widget.subscriptionLauncher(
        googlePlaySubscriptionManagementUri(entitlement),
      );
    } catch (_) {/* Show the approved failure line. */}
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
    final entitlement =
        ref.watch(entitlementProvider).valueOrNull ?? const Entitlement.free();
    final covered = ref.watch(proForActiveExamProvider).valueOrNull;
    final web = ref.watch(paymentsOnWebProvider);
    final anonymous = ref.watch(isAnonymousProvider).valueOrNull ?? true;
    final exam = ref.watch(activeProCatalogEntryProvider).valueOrNull;
    final offering = ref.watch(paywallOfferingProvider);
    final paused = entitlement.state == EntitlementState.paused;
    final packages = (offering.valueOrNull?.recognizedPackages
            .where(
              (p) =>
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
    final trial = selectedPackage?.sku == PaywallSku.monthly &&
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
    final ended = entitlement.endsAt;
    final lapsed = !entitlement.proIsActive &&
        ended != null &&
        ended.isBefore(DateTime.now());
    final now = DateTime.now().toUtc().add(const Duration(hours: 8));
    final today = DateTime.utc(now.year, now.month, now.day);
    final sitting = exam?.publishedSittings
        .where((s) => !s.firstDay.isBefore(today) && s.sourceUrl.isNotEmpty)
        .firstOrNull;
    final sittingEnd =
        sitting == null ? null : DateFormat.yMMMd().format(sitting.lastDay);
    final selectedPass = sitting == null ? null : selectedPassCandidate;
    final pending = web ? null : ref.watch(pendingPurchaseProvider).valueOrNull;
    final user = ref.watch(currentUserProvider).valueOrNull;
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
                        ? "You won't be charged"
                        : 'Then ${selectedPackage.priceString} a month. '
                            'Cancel any time in Google Play.',
                    textAlign: TextAlign.center,
                    style: context.type.footnote,
                  ),
                ],
              ],
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
      backLabel: 'Settings',
      onBack: () => Navigator.of(context).maybePop(),
      children: [
        Text('PANTAS PRO', style: context.type.sectionHeader),
        const SizedBox(height: 12),
        Text(
          owned
              ? "You're on Pro."
              : lapsed
                  ? 'Your Pro plan ended'
                  : "See exactly what's losing you points.",
          style: context.type.pageTitle,
        ),
        if (owned) ...[
          const SizedBox(height: 8),
          Text(
            "Thanks for backing Pantas. Here's everything that's yours.",
            style: context.type.body,
          ),
        ],
        if (lapsed)
          Text(
            'It ended on ${DateFormat.yMMMd().format(ended)}.',
            style: context.type.body,
          ),
        const SizedBox(height: 24),
        for (final feature in [
          (PantasIcons.unlimitedMocks, 'Unlimited mock exams'),
          (PantasIcons.answerNotes, 'Notes on why your answer was wrong'),
          (PantasIcons.studyHabits, 'The figures behind your study habits'),
          (PantasIcons.proBackup, "Progress that's always backed up"),
          (PantasIcons.topicResults, 'Results by topic and lesson'),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(feature.$1, color: context.colors.accent, size: 21),
                const SizedBox(width: 12),
                Expanded(child: Text(feature.$2, style: context.type.subhead)),
              ],
            ),
          ),
        const SizedBox(height: 24),
        if (paused) const ProPausedLine(),
        if ((entitlement.proIsActive || paused) &&
            (entitlement.passes.isEmpty ||
                entitlement.plan != EntitlementPlan.free ||
                entitlement.isUnknownPlan ||
                entitlement.promotions.isNotEmpty))
          GroupedSection(
            header: 'Your plan',
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
                const Text('There is a problem with your payment.'),
            ],
          ),
        for (final pass in entitlement.passes.entries) ...[
          GroupedSection(
            header: 'Your plan',
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
                        showTrial: !lapsed &&
                            !entitlement.proIsActive &&
                            !(web && anonymous),
                      ),
                    ),
                  ),
              ],
            ),
          for (final pass in passes) ...[
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
                              sitting == null
                                  ? 'Once the next date is out'
                                  : 'Until $sittingEnd',
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
              onPressed: () => ref.invalidate(paywallOfferingProvider),
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
                10,
                MediaQuery.textScalerOf(context).scale(11) > 16.5 &&
                        badge != null
                    ? 48
                    : 18,
                10,
                14,
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
                    package.priceString,
                    style: context.type.emphasized
                        .copyWith(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'a ${_period(package.sku).toLowerCase()}',
                    style: context.type.caption,
                  ),
                  if (package.sku == PaywallSku.yearly) ...[
                    const SizedBox(height: 4),
                    Text(
                      '$monthlyEquivalent a month',
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
                      color: package.sku == PaywallSku.monthly
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
                        color: package.sku == PaywallSku.monthly
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
