import 'package:pantas/features/paywall/application/paywall_providers.dart';
import 'package:pantas/features/paywall/data/revenuecat_config.dart';
import 'package:pantas/features/paywall/data/revenuecat_gateway.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RevenueCatBootstrapper {
  RevenueCatBootstrapper(this._gateway);

  final RevenueCatGateway _gateway;
  String? _lastUid;

  Future<void> configure(RevenueCatConfig config) async {
    final apiKey = config.androidApiKey;
    if (apiKey == null) return;
    await _gateway.configure(androidApiKey: apiKey);
  }

  Future<void> associateUid(String? uid) async {
    if (uid == null || uid == _lastUid) return;
    _lastUid = uid;
    await _gateway.logIn(uid);
  }
}

final revenueCatBootstrapperProvider = Provider<RevenueCatBootstrapper>((ref) {
  return RevenueCatBootstrapper(ref.watch(revenueCatGatewayProvider));
});

Future<void> bootstrapRevenueCat(ProviderContainer container) async {
  final bootstrapper = container.read(revenueCatBootstrapperProvider);
  await bootstrapper.configure(RevenueCatConfig.fromEnvironment());
}
