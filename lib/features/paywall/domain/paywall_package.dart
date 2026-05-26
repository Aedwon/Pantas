enum PaywallSku { monthly, yearly, lifetime }

class PaywallPackage {
  const PaywallPackage({
    required this.sku,
    required this.productId,
    required this.priceString,
  });

  final PaywallSku sku;
  final String productId;
  final String priceString;
}
