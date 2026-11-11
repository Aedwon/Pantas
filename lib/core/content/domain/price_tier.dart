/// The price tier a catalog entry sits in. Lives in core so the content layer
/// can name tiers; the paywall maps exams to tiers on top of it.
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
