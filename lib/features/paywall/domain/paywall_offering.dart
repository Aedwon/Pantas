import 'package:pantas/features/paywall/domain/paywall_package.dart';

export 'package:pantas/features/paywall/domain/paywall_package.dart';

enum PaywallOfferingStatus {
  loading,
  available,
  noCurrentOffering,
  emptyCurrentOffering,
  mixedProducts,
  allProductsUnrecognized,
  networkFailure,
  storeFailure,
  revenueCatFailure,
  configurationFailure,
  developerFailure,
  unknownFailure,
}

class PaywallOfferingResult {
  const PaywallOfferingResult({
    required this.status,
    this.recognizedPackages = const [],
    this.passPackages = const [],
    this.unrecognizedProductIds = const [],
  });

  const PaywallOfferingResult.loading()
      : status = PaywallOfferingStatus.loading,
        recognizedPackages = const [],
        passPackages = const [],
        unrecognizedProductIds = const [];

  const PaywallOfferingResult.noCurrentOffering()
      : status = PaywallOfferingStatus.noCurrentOffering,
        recognizedPackages = const [],
        passPackages = const [],
        unrecognizedProductIds = const [];

  const PaywallOfferingResult.emptyCurrentOffering()
      : status = PaywallOfferingStatus.emptyCurrentOffering,
        recognizedPackages = const [],
        passPackages = const [],
        unrecognizedProductIds = const [];

  final PaywallOfferingStatus status;
  final List<PaywallPackage> recognizedPackages;
  final List<PaywallPassPackage> passPackages;
  final List<String> unrecognizedProductIds;
}
