import 'paywall_package.dart';

PaywallSku recommendedSkuForExamDate({
  required DateTime today,
  DateTime? examDate,
}) {
  if (examDate == null || !examDate.isAfter(today)) {
    return PaywallSku.yearly;
  }
  final months =
      (examDate.year - today.year) * 12 + examDate.month - today.month;
  if (months < 5) return PaywallSku.monthly;
  return PaywallSku.yearly;
}

String ctaCopyFor(PaywallPackage package) {
  return switch (package.sku) {
    PaywallSku.monthly => 'Get Pro - ${package.priceString}/month',
    PaywallSku.yearly => 'Start 7-day free trial',
    PaywallSku.lifetime => 'Get Pro - ${package.priceString} one-time',
  };
}
