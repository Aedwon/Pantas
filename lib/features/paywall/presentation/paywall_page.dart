import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_controller.dart';
import 'package:cse_cet_reviewer/features/paywall/application/paywall_providers.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_recommendation.dart';
import 'package:cse_cet_reviewer/features/paywall/presentation/paywall_package_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late PaywallSku _selectedSku = widget.recommendedSku;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    ref.read(paywallControllerProvider).logPaywallShown(
          trigger: widget.returnTo ?? 'manual',
        );
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    final packages = paywallDisplayOrder(widget.packages);
    if (packages.isEmpty) {
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
    final selected = packages.firstWhere(
      (package) => package.sku == _selectedSku,
      orElse: () => packages.first,
    );

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text(
            'Practice with sharper coaching and deeper mock review.',
            style: styles.bodyMedium.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 12),
          for (final package in packages)
            PaywallPackageCard(
              package: package,
              isSelected: package.sku == _selectedSku,
              isRecommended: package.sku == widget.recommendedSku,
              badgeCopy: recommendationBadgeCopy(
                recommended: widget.recommendedSku,
                hasExamDate: widget.recommendedSku != PaywallSku.yearly,
              ),
              onTap: () => setState(() => _selectedSku = package.sku),
            ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Text(
              _errorMessage!,
              style: styles.bodyMedium.copyWith(color: colors.rust),
            )
          else
            BoardButton(
              label: ctaCopyFor(selected),
              onPressed: () async {
                final purchase = widget.onPurchase;
                if (purchase == null) return;
                final result = await purchase(selected);
                if (!mounted) return;
                setState(() => _errorMessage = result.errorMessage);
              },
            ),
          const SizedBox(height: 8),
          Text(
            'Paid through Google Play.',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
