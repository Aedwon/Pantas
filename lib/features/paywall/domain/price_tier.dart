import 'package:pantas/core/content/data/exam_catalog_repository.dart';
import 'package:pantas/core/content/domain/price_tier.dart';

export 'package:pantas/core/content/domain/price_tier.dart';

Future<PriceTier> tierForExam(
  ExamCatalogRepository catalog,
  String examId,
) async =>
    PriceTier.fromCatalog((await catalog.entry(examId)).priceTier);
