import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/ui/components/error_banner.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/paywall/application/paywall_controller.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/domain/paywall_recommendation.dart';
import 'package:pantas/features/paywall/presentation/plans_page.dart';
import 'package:pantas/features/paywall/presentation/trial_timeline_page.dart';
import 'package:pantas/features/paywall/presentation/what_pro_adds_page.dart';
import 'package:pantas/features/review_prompt/application/review_prompt_providers.dart';
import 'package:pantas/features/settings/application/settings_providers.dart';

enum _PaywallStep {
  whatProAdds,
  plans,
  trialTimeline,
}

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({
    this.returnTo,
    this.packages = const [],
    this.recommendedSku = PaywallSku.yearly,
    this.onRestore,
    this.onPurchase,
    super.key,
  });

  final String? returnTo;
  final List<PaywallPackage> packages;
  final PaywallSku recommendedSku;
  final Future<void> Function()? onRestore;
  final Future<PaywallCommandResult> Function(PaywallPackage package)?
      onPurchase;

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  _PaywallStep _step = _PaywallStep.whatProAdds;
  PaywallPackage? _selectedPackage;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    ref.read(paywallControllerProvider).logPaywallShown(
          trigger: widget.returnTo ?? 'manual',
        );
    // Money is the sharpest friction in the app, so seeing this screen
    // buys a quiet period from the review popup.
    unawaited(ref.read(reviewPromptControllerProvider).recordPaywallSeen());
  }

  /// Off the paywall, whichever way the student arrived.
  ///
  /// `maybePop` alone did nothing on the two ways in that do not stack: Home's
  /// "Unlock with Pro" uses `go`, and a Pro-gated route redirects. Both leave
  /// no stack, and `/paywall` sits outside the tab shell, so the close control
  /// was dead and there was no tab bar to escape by.
  ///
  /// `returnTo` carries the route the student was reaching for when they were
  /// stopped. It was being recorded for telemetry and never used to send them
  /// anywhere, so subscribing did not take them to the thing they subscribed
  /// for.
  void _leave() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    final destination = widget.returnTo;
    if (destination != null && destination.isNotEmpty) {
      context.go(Uri.decodeComponent(destination));
      return;
    }
    context.go('/home');
  }

  Future<void> _handlePurchase(PaywallPackage package) async {
    final controller = ref.read(paywallControllerProvider);
    final purchaseFn = widget.onPurchase ?? controller.purchase;
    try {
      final result = await purchaseFn(package);
      if (!mounted) return;
      if (result.errorMessage != null) {
        setState(() => _errorMessage = result.errorMessage);
        return;
      }
      // A student who has just paid must not be left looking at the offer.
      // Nothing navigated here before: the entitlement updated, the router
      // re-evaluated, and `/paywall` is not a Pro route so no redirect moved
      // them. They stayed on the screen that had already taken their money.
      if (result.entitlement.proIsActive) _leave();
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _errorMessage =
            'You need a connection to subscribe. Try again when '
                "you're back online.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    final availablePackages = widget.packages.isNotEmpty
        ? widget.packages
        : (ref.watch(paywallPackagesProvider).valueOrNull ?? const []);

    final orderedPackages = paywallDisplayOrder(availablePackages);

    if (orderedPackages.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Try Pro')),
        body: Center(
          child: Text(
            "You need a connection to subscribe. Try again when you're back "
            'online.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
        ),
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

    final pageBody = switch (_step) {
      _PaywallStep.whatProAdds => WhatProAddsPage(
          onSeePlans: () => setState(() => _step = _PaywallStep.plans),
        ),
      _PaywallStep.plans => PlansPage(
          packages: orderedPackages,
          examDate: examDate,
          today: today,
          selectedPackage: selectedPkg,
          onSelect: (pkg) => setState(() => _selectedPackage = pkg),
          onContinue: () {
            if (selectedPkg.sku == PaywallSku.yearly) {
              setState(() => _step = _PaywallStep.trialTimeline);
            } else {
              _handlePurchase(selectedPkg);
            }
          },
        ),
      _PaywallStep.trialTimeline => TrialTimelinePage(
          today: today,
          yearlyPrice: selectedPkg.priceString,
          onStart: () => _handlePurchase(selectedPkg),
        ),
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _leave,
        ),
        title: const Text('Try Pro'),
        actions: [
          TextButton(
            onPressed: () async {
              final restore = widget.onRestore;
              if (restore == null) return;
              try {
                await restore();
              } catch (_) {
                if (!mounted) return;
                setState(
                  () => _errorMessage =
                      'You need a connection to subscribe. Try again when '
                          "you're back online.",
                );
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
      body: Column(
        children: [
          // The kit already owns this surface, built from hairline rules.
          // A tinted panel is banned: it reads as generated UI rather than
          // as print.
          if (_errorMessage != null)
            ErrorBanner(
              variant: ErrorBannerVariant.offline,
              message: _errorMessage!,
            ),
          Expanded(child: pageBody),
        ],
      ),
    );
  }
}
