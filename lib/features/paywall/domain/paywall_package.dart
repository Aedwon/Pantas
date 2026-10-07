enum PaywallSku { weekly, monthly, yearly }

class PaywallPassPackage {
  const PaywallPassPackage({
    required this.productId,
    required this.priceString,
    required this.priceAmount,
  });

  final String productId;
  final String priceString;
  final double priceAmount;
}

class PaywallPackage {
  const PaywallPackage({
    required this.sku,
    required this.productId,
    required this.priceString,
    required this.priceAmount,
  });

  final PaywallSku sku;
  final String productId;

  /// The store's own formatted price, currency symbol included. Print this
  /// for a single period; never build it by hand from priceAmount.
  final String priceString;

  /// The same price as a number, for the multi-period arithmetic on the
  /// plans screen. A string cannot be multiplied by a renewal count.
  final double priceAmount;
}
