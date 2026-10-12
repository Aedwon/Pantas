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
  // Legacy display buckets remain until this flow is removed by W4f.
  if (examDate.difference(today).inDays <= 21) return PaywallSku.weekly;
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
    PaywallSku.monthly => package.trialEligible
        ? 'Start my free trial'
        : 'Get Pro. ${package.priceString} a month.',
    PaywallSku.yearly => 'Get Pro. ${package.priceString} a year.',
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
