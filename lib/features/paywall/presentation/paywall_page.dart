import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/entitlement.dart';
import 'package:pantas/features/paywall/domain/payment_operation.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/paywall_recommendation.dart';
import 'package:pantas/features/paywall/presentation/plans_page.dart';
import 'package:pantas/features/paywall/presentation/trial_timeline_page.dart';
import 'package:pantas/features/paywall/presentation/what_pro_adds_page.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

enum _PaywallStep { whatProAdds, plans, trialTimeline }

enum _PendingPaymentOperation { purchase, restore }

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({
    this.returnTo,
    this.packages = const [],
    this.recommendedSku = PaywallSku.monthly,
    this.onRestore,
    this.onPurchase,
    super.key,
  });

  final String? returnTo;
  final List<PaywallPackage> packages;
  final PaywallSku recommendedSku;
  final Future<PaywallCommandResult> Function()? onRestore;
  final Future<PaywallCommandResult> Function(PaywallPackage package)?
      onPurchase;

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  _PaywallStep _step = _PaywallStep.whatProAdds;
  PaywallPackage? _selectedPackage;
  _PendingPaymentOperation? _pendingOperation;
  PaymentOperationStatus? _purchaseStatus;
  String? _restoreMessage;

  bool get _isBusy => _pendingOperation != null;

  @override
  void initState() {
    super.initState();
    ref
        .read(paywallControllerProvider)
        .logPaywallShown(trigger: widget.returnTo ?? 'manual');
    unawaited(ref.read(reviewPromptControllerProvider).recordPaywallSeen());
  }

  void _closePaywall() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go('/home');
  }

  String? _validReturnTo() {
    final raw = widget.returnTo;
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = Uri.decodeComponent(raw);
      if (!decoded.startsWith('/') || decoded.startsWith('//')) return null;
      final uri = Uri.tryParse(decoded);
      if (uri == null || uri.hasScheme || uri.path == '/paywall') return null;
      return decoded;
    } on FormatException {
      return null;
    }
  }

  void _leaveAfterSuccess() {
    final destination = _validReturnTo();
    if (destination != null) {
      context.go(destination);
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go('/home');
  }

  Future<void> _handlePurchase(PaywallPackage package) async {
    if (_isBusy) return;
    setState(() {
      _pendingOperation = _PendingPaymentOperation.purchase;
      _purchaseStatus = null;
      _restoreMessage = null;
    });

    final controller = ref.read(paywallControllerProvider);
    final purchaseFn = widget.onPurchase ?? controller.purchase;
    PaywallCommandResult result;
    try {
      result = await purchaseFn(package);
    } catch (_) {
      result = const PaywallCommandResult(
        status: PaymentOperationStatus.unknownFailure,
        entitlement: Entitlement.free(),
      );
    }
    if (!mounted) return;

    if (result.status == PaymentOperationStatus.success &&
        result.entitlement.proIsActive) {
      _pendingOperation = null;
      _leaveAfterSuccess();
      return;
    }

    setState(() {
      _pendingOperation = null;
      _purchaseStatus = switch (result.status) {
        PaymentOperationStatus.userCancelled ||
        PaymentOperationStatus.operationAlreadyInProgress =>
          null,
        PaymentOperationStatus.success =>
          PaymentOperationStatus.entitlementNotActive,
        _ => result.status,
      };
    });
  }

  Future<void> _handleRestore() async {
    if (_isBusy) return;
    setState(() {
      _pendingOperation = _PendingPaymentOperation.restore;
      _restoreMessage = null;
      _purchaseStatus = null;
    });

    final controller = ref.read(paywallControllerProvider);
    final restoreFn = widget.onRestore ?? controller.restore;
    PaywallCommandResult result;
    try {
      result = await restoreFn();
    } catch (_) {
      result = const PaywallCommandResult(
        status: PaymentOperationStatus.unknownFailure,
        entitlement: Entitlement.free(),
      );
    }
    if (!mounted) return;

    if (result.status == PaymentOperationStatus.success &&
        result.entitlement.proIsActive) {
      _pendingOperation = null;
      _leaveAfterSuccess();
      return;
    }

    setState(() {
      _pendingOperation = null;
      _restoreMessage = _restoreMessageFor(result);
    });
  }

  String? _restoreMessageFor(PaywallCommandResult result) {
    return switch (result.status) {
      PaymentOperationStatus.success ||
      PaymentOperationStatus.entitlementNotActive =>
        "We found a purchase, but Pro couldn't be confirmed yet. "
            'Try again in a moment.',
      PaymentOperationStatus.noActiveSubscription =>
        "We couldn't find an active Pro subscription on this Google Play "
            'account.',
      PaymentOperationStatus.userCancelled ||
      PaymentOperationStatus.operationAlreadyInProgress =>
        null,
      PaymentOperationStatus.networkFailure =>
        'You need a connection to restore purchases. Try again when '
            "you're back online.",
      PaymentOperationStatus.storeFailure =>
        "Google Play couldn't check your purchases right now. Try again.",
      PaymentOperationStatus.revenueCatFailure ||
      PaymentOperationStatus.configurationFailure ||
      PaymentOperationStatus.developerFailure ||
      PaymentOperationStatus.unknownFailure =>
        "Restore purchases isn't available right now. Try again later.",
    };
  }

  void _clearPurchaseStatus() {
    if (_purchaseStatus == null) return;
    setState(() => _purchaseStatus = null);
  }

  @override
  Widget build(BuildContext context) {
    final offering = _resolvedOffering();
    final body = offering == null
        ? const _OfferingMessage(
            message: 'Loading subscriptions...',
            loading: true,
          )
        : _bodyForOffering(offering);

    final restoring = _pendingOperation == _PendingPaymentOperation.restore;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Close',
          icon: const Icon(Icons.close),
          onPressed: _closePaywall,
        ),
        title: const Text('Try Pro'),
        actions: [
          TextButton(
            onPressed: _isBusy ? null : _handleRestore,
            child: Semantics(
              liveRegion: restoring,
              label: restoring ? 'Restore in progress' : 'Restore purchases',
              child: Text(restoring ? 'Restoring...' : 'Restore'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_restoreMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                _restoreMessage!,
                style: context.textStyles.bodySmall.copyWith(
                  color: context.colors.inkMuted,
                ),
              ),
            ),
          Expanded(child: body),
        ],
      ),
    );
  }

  PaywallOfferingResult? _resolvedOffering() {
    if (widget.packages.isNotEmpty) {
      return PaywallOfferingResult(
        status: PaywallOfferingStatus.available,
        recognizedPackages: widget.packages,
      );
    }

    final asyncOffering = ref.watch(paywallOfferingProvider);
    if (asyncOffering.isLoading && !asyncOffering.hasValue) return null;
    if (asyncOffering.hasError) {
      return const PaywallOfferingResult(
        status: PaywallOfferingStatus.unknownFailure,
      );
    }
    return asyncOffering.valueOrNull ?? const PaywallOfferingResult.loading();
  }

  Widget _bodyForOffering(PaywallOfferingResult offering) {
    if (offering.status == PaywallOfferingStatus.loading) {
      return const _OfferingMessage(
        message: 'Loading subscriptions...',
        loading: true,
      );
    }

    final canShowPackages =
        offering.status == PaywallOfferingStatus.available ||
            offering.status == PaywallOfferingStatus.mixedProducts;
    final orderedPackages = paywallDisplayOrder(offering.recognizedPackages);
    if (!canShowPackages || orderedPackages.isEmpty) {
      final state = _offeringCopy(offering.status);
      return _OfferingMessage(
        message: state.$1,
        onRetry:
            state.$2 ? () => ref.invalidate(paywallOfferingProvider) : null,
      );
    }

    final selectedPkg = _selectedPackage ??
        orderedPackages.firstWhere(
          (p) => p.sku == widget.recommendedSku,
          orElse: () => orderedPackages.first,
        );
    final userSettings = ref.watch(userSettingsProvider).valueOrNull;
    final examDate = userSettings?.examDate;
    final today = DateTime.now();

    return switch (_step) {
      _PaywallStep.whatProAdds => WhatProAddsPage(
          onSeePlans: () => setState(() => _step = _PaywallStep.plans),
        ),
      _PaywallStep.plans => PlansPage(
          packages: orderedPackages,
          examDate: examDate,
          today: today,
          selectedPackage: selectedPkg,
          isBusy: _isBusy,
          operationStatus: _purchaseStatus,
          onRetry: _clearPurchaseStatus,
          onSelect: (pkg) {
            setState(() {
              _selectedPackage = pkg;
              _purchaseStatus = null;
            });
          },
          onContinue: () {
            if (selectedPkg.sku == PaywallSku.yearly) {
              setState(() {
                _step = _PaywallStep.trialTimeline;
                _purchaseStatus = null;
              });
            } else {
              _handlePurchase(selectedPkg);
            }
          },
        ),
      _PaywallStep.trialTimeline => TrialTimelinePage(
          today: today,
          yearlyPrice: selectedPkg.priceString,
          isBusy: _isBusy,
          operationStatus: _purchaseStatus,
          onRetry: _clearPurchaseStatus,
          onStart: () => _handlePurchase(selectedPkg),
        ),
    };
  }

  (String, bool) _offeringCopy(PaywallOfferingStatus status) {
    return switch (status) {
      PaywallOfferingStatus.networkFailure => (
          'You need a connection to load subscriptions. Try again when '
              "you're back online.",
          true,
        ),
      PaywallOfferingStatus.storeFailure => (
          "Google Play couldn't load subscriptions right now.",
          true,
        ),
      PaywallOfferingStatus.allProductsUnrecognized => (
          'Subscriptions are not available in this version of Pantas '
              'right now.',
          false,
        ),
      PaywallOfferingStatus.noCurrentOffering ||
      PaywallOfferingStatus.emptyCurrentOffering ||
      PaywallOfferingStatus.revenueCatFailure ||
      PaywallOfferingStatus.configurationFailure ||
      PaywallOfferingStatus.developerFailure ||
      PaywallOfferingStatus.unknownFailure ||
      PaywallOfferingStatus.available ||
      PaywallOfferingStatus.mixedProducts ||
      PaywallOfferingStatus.loading =>
        (
          "Subscriptions aren't available right now.",
          true,
        ),
    };
  }
}

class _OfferingMessage extends StatelessWidget {
  const _OfferingMessage({
    required this.message,
    this.loading = false,
    this.onRetry,
  });

  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium.copyWith(
                color: context.colors.inkMuted,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ],
        ),
      ),
    );
  }
}
