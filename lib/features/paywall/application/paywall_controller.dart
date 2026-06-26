import 'dart:async';

import 'package:cse_cet_reviewer/core/telemetry/telemetry.dart';
import 'package:cse_cet_reviewer/features/paywall/data/revenuecat_gateway.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/entitlement.dart';
import 'package:cse_cet_reviewer/features/paywall/domain/paywall_package.dart';

class PaywallController {
  PaywallController(
    this._gateway, {
    Telemetry telemetry = const DisabledTelemetry(),
  }) : _telemetry = telemetry;

  final RevenueCatGateway _gateway;
  final Telemetry _telemetry;

  void logPaywallShown({String? trigger}) {
    unawaited(
      _telemetry.log(
        TelemetryEvent.paywallShown,
        properties: {'trigger': trigger ?? 'manual'},
      ),
    );
  }

  Future<PaywallCommandResult> purchase(PaywallPackage package) async {
    unawaited(
      _telemetry.log(
        TelemetryEvent.purchaseStarted,
        properties: {'sku': package.sku.name},
      ),
    );
    try {
      final entitlement = await _gateway.purchase(package);
      if (entitlement.proIsActive) {
        unawaited(_telemetry.log(TelemetryEvent.purchaseCompleted));
      } else {
        unawaited(
          _telemetry.log(
            TelemetryEvent.purchaseFailed,
            properties: {'reason': 'store_error'},
          ),
        );
      }
      return PaywallCommandResult(entitlement: entitlement);
    } catch (_) {
      unawaited(
        _telemetry.log(
          TelemetryEvent.purchaseFailed,
          properties: {'reason': 'network_error'},
        ),
      );
      return const PaywallCommandResult(
        entitlement: Entitlement.free(),
        errorMessage:
            "You need a connection to subscribe. Try again when you're back "
            'online.',
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
            "You need a connection to subscribe. Try again when you're back "
            'online.',
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
