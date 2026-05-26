import 'package:flutter/material.dart';

import '../application/paywall_controller.dart';
import '../domain/entitlement.dart';
import '../domain/paywall_package.dart';
import '../domain/paywall_recommendation.dart';
import 'paywall_package_card.dart';

class PaywallPage extends StatefulWidget {
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
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  late PaywallSku _selectedSku = widget.recommendedSku;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final packages = paywallDisplayOrder(widget.packages);
    if (packages.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Try Pro')),
        body: const Center(
          child: Text('Pro plans are unavailable. Check your connection.'),
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
            onPressed: widget.onRestore,
            child: const Text('Restore'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Practice with sharper coaching and deeper mock review.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          for (final package in packages) ...[
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
            const SizedBox(height: 10),
          ],
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 10),
          ],
          FilledButton(
            onPressed: () async {
              final purchase = widget.onPurchase;
              if (purchase == null) return;
              final result = await purchase(selected);
              if (!mounted) return;
              setState(() => _errorMessage = result.errorMessage);
            },
            child: Text(ctaCopyFor(selected)),
          ),
          const SizedBox(height: 8),
          const Text('Paid through Google Play.'),
        ],
      ),
    );
  }
}
