import 'package:cse_cet_reviewer/features/paywall/data/revenuecat_gateway.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';

class PaywallController {
  PaywallController(this._gateway);

  final RevenueCatGateway _gateway;

  Future<PaywallCommandResult> purchase(PaywallPackage package) async {
    try {
      final entitlement = await _gateway.purchase(package);
      return PaywallCommandResult(entitlement: entitlement);
    } catch (_) {
      return const PaywallCommandResult(
        entitlement: Entitlement.free(),
        errorMessage:
            "Couldn't reach Google Play. Check your connection and try again.",
      );
    }
  }

  Future<PaywallCommandResult> restore() async {
    try {
      final entitlement = await _gateway.restorePurchases();
      return PaywallCommandResult(entitlement: entitlement);
    } catch (_) {
      return const PaywallCommandResult(
        entitlement: Entitlement.free(),
        errorMessage:
            "Couldn't reach Google Play. Check your connection and try again.",
      );
    }
  }
}

class PaywallCommandResult {
  const PaywallCommandResult({
    required this.entitlement,
    this.errorMessage,
  });

  final Entitlement entitlement;
  final String? errorMessage;
}
