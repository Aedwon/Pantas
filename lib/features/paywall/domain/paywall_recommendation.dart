import 'package:pantas/features/paywall/domain/paywall_package.dart';

PaywallSku recommendedSkuForExamDate({
  required DateTime today,
  DateTime? examDate,
}) {
  // No date, or a date already gone: most students prep for three to six
  // months, and at an 8 month crossover Yearly is still not the honest guess.
  if (examDate == null || !examDate.isAfter(today)) {
    return PaywallSku.monthly;
  }
  // Past 3 weekly renewals (₱87) the next one exceeds Monthly's ₱99,
  // so recommending Weekly beyond 21 days would break coach honesty.
  if (examDate.difference(today).inDays <= 21) return PaywallSku.weekly;
  // ₱799 ÷ ₱99 = 8.07, so Monthly is cheaper than Yearly under eight months.
  // This moved with the price on 11 August: at ₱999 the crossover was 10.09 and
  // the boundary sat at ten. A boundary left behind a price cut is the coach
  // recommending Monthly to a student Yearly would have saved money.
  final months = _wholeMonthsBetween(today, examDate);
  if (months <= 8) return PaywallSku.monthly;
  return PaywallSku.yearly;
}

String recommendationBadgeCopy({
  required PaywallSku recommended,
  required bool hasExamDate,
}) {
  if (!hasExamDate) return 'Best for most';
  return 'Best for your exam date';
}

String ctaCopyFor(PaywallPackage package) {
  return switch (package.sku) {
    PaywallSku.weekly => 'Get Pro. ${package.priceString} a week.',
    PaywallSku.monthly => 'Get Pro. ${package.priceString} a month.',
    // Yearly is the only SKU with a trial, so its CTA opens screen 3
    // rather than naming a price the student has not agreed to yet.
    PaywallSku.yearly => 'Start my free trial',
  };
}

List<PaywallPackage> paywallDisplayOrder(List<PaywallPackage> packages) {
  final sorted = [...packages]
    ..sort((a, b) => _skuRank(a.sku).compareTo(_skuRank(b.sku)));
  return sorted;
}

int _wholeMonthsBetween(DateTime start, DateTime end) {
  var months = (end.year - start.year) * 12 + end.month - start.month;
  if (end.day < start.day) months -= 1;
  return months;
}

int _skuRank(PaywallSku sku) {
  return switch (sku) {
    PaywallSku.weekly => 0,
    PaywallSku.monthly => 1,
    PaywallSku.yearly => 2,
  };
}
