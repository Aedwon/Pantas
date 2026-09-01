import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/revenuecat_config.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';

class RevenueCatBootstrapper {
  RevenueCatBootstrapper(this._gateway);

  final RevenueCatGateway _gateway;
  String? _lastUid;

  Future<void> configure(RevenueCatConfig config) async {
    try {
      // Hydration is independent from SDK configuration. A build with a
      // missing RevenueCat key must still recover the last confirmed local
      // entitlement instead of silently failing closed to Free.
      await _gateway.initialize();

      final apiKey = config.androidApiKey;
      if (apiKey == null) return;
      await _gateway.configure(androidApiKey: apiKey);
    } catch (_) {
      // Payment startup is optional infrastructure. A persistence,
      // configuration, or initial refresh failure must not prevent the rest
      // of the app from starting.
    }
  }

  Future<void> associateUid(String? uid) async {
    if (uid == null || uid == _lastUid) return;
    try {
      await _gateway.logIn(uid);
      _lastUid = uid;
    } catch (_) {
      // Keep the session usable and allow a later auth update to retry.
    }
  }
}

final revenueCatBootstrapperProvider = Provider<RevenueCatBootstrapper>((ref) {
  return RevenueCatBootstrapper(ref.watch(revenueCatGatewayProvider));
});

Future<void> bootstrapRevenueCat(ProviderContainer container) async {
  final bootstrapper = container.read(revenueCatBootstrapperProvider);
  await bootstrapper.configure(container.read(revenueCatConfigProvider));
}
