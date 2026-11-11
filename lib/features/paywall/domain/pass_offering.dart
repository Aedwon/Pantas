import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/features/paywall/domain/paywall_offering.dart';
import 'package:pantas/features/paywall/domain/products.dart';

bool passAllowedForExam(
  String productId,
  ExamCatalogEntry exam, {
  required DateTime at,
}) {
  final product = productForId(productId);
  final philippineTime = at.toUtc().add(const Duration(hours: 8));
  final day = DateTime.utc(
    philippineTime.year,
    philippineTime.month,
    philippineTime.day,
  );
  return product?.kind == ProductKind.pass &&
      product?.examId == exam.id &&
      !exam.comingSoon &&
      exam.publishedSittings.any(
        (sitting) =>
            !sitting.firstDay.isBefore(day) && sitting.sourceUrl.isNotEmpty,
      );
}

PaywallPassPackage? passForExam(
  PaywallOfferingResult offering,
  ExamCatalogEntry exam, {
  required DateTime at,
}) {
  for (final package in offering.passPackages) {
    if (passAllowedForExam(package.productId, exam, at: at)) return package;
  }
  return null;
}
