import 'package:pantas/core/content/data/exam_catalog_repository.dart';

enum PriceTier {
  student,
  civilService,
  licensure,
  nce;

  factory PriceTier.fromCatalog(String value) => switch (value) {
        'Student' => student,
        'Civil Service' => civilService,
        'Licensure' => licensure,
        'PSHS-NCE' => nce,
        _ => throw ArgumentError.value(value, 'value', 'Unknown price tier'),
      };
}

Future<PriceTier> tierForExam(
  ExamCatalogRepository catalog,
  String examId,
) async =>
    PriceTier.fromCatalog((await catalog.entry(examId)).priceTier);
