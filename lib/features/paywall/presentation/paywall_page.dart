import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_controller.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_providers.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_recommendation.dart';
import 'package:cse_cet_reviewer/features/paywall/presentation/plans_page.dart';
import 'package:cse_cet_reviewer/features/paywall/presentation/trial_timeline_page.dart';
import 'package:cse_cet_reviewer/features/paywall/presentation/what_pro_adds_page.dart';
import 'package:cse_cet_reviewer/features/settings/application/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  }

  Future<void> _handlePurchase(PaywallPackage package) async {
    final controller = ref.read(paywallControllerProvider);
    final purchaseFn = widget.onPurchase ?? controller.purchase;
    try {
      final result = await purchaseFn(package);
      if (!mounted) return;
      if (result.errorMessage != null) {
        setState(() => _errorMessage = result.errorMessage);
      }
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

    final Widget pageBody = switch (_step) {
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
          onPressed: () => Navigator.of(context).maybePop(),
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
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              color: colors.rust.withAlpha(25),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                _errorMessage!,
                style: styles.bodyMedium.copyWith(color: colors.rust),
              ),
            ),
          Expanded(child: pageBody),
        ],
      ),
    );
  }
}
