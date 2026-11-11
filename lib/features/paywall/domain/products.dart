import 'package:pantas/features/paywall/domain/paywall_package.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

enum ProductKind { subscription, pass, promotional }

class ProductDefinition {
  const ProductDefinition({
    required this.tier,
    required this.kind,
    this.period,
    this.examId,
  });

  final PriceTier tier;
  final ProductKind kind;
  final PaywallSku? period;
  final String? examId;
}

/// Permanent store products and tier-named grants. Prices come from the store.
/// The server's checked export is functions/src/products.json.
const products = <String, ProductDefinition>{
  'pantas_pro_weekly': ProductDefinition(
    tier: PriceTier.student,
    kind: ProductKind.subscription,
    period: PaywallSku.weekly,
  ),
  'pantas_pro_monthly': ProductDefinition(
    tier: PriceTier.student,
    kind: ProductKind.subscription,
    period: PaywallSku.monthly,
  ),
  'pantas_pro_yearly': ProductDefinition(
    tier: PriceTier.student,
    kind: ProductKind.subscription,
    period: PaywallSku.yearly,
  ),
  'pantas_cs_weekly': ProductDefinition(
    tier: PriceTier.civilService,
    kind: ProductKind.subscription,
    period: PaywallSku.weekly,
  ),
  'pantas_cs_monthly': ProductDefinition(
    tier: PriceTier.civilService,
    kind: ProductKind.subscription,
    period: PaywallSku.monthly,
  ),
  'pantas_cs_yearly': ProductDefinition(
    tier: PriceTier.civilService,
    kind: ProductKind.subscription,
    period: PaywallSku.yearly,
  ),
  'pantas_pass_cse_pro': ProductDefinition(
    tier: PriceTier.civilService,
    kind: ProductKind.pass,
    examId: 'exam_cse_pro',
  ),
  'pantas_pass_cse_sub': ProductDefinition(
    tier: PriceTier.civilService,
    kind: ProductKind.pass,
    examId: 'exam_cse_sub',
  ),
  'promo_student': ProductDefinition(
    tier: PriceTier.student,
    kind: ProductKind.promotional,
  ),
  'promo_civil_service': ProductDefinition(
    tier: PriceTier.civilService,
    kind: ProductKind.promotional,
  ),
};

ProductDefinition? productForId(String id) {
  final product = products[id.split(':').first];
  if (product?.kind == ProductKind.promotional && id.contains(':')) return null;
  return product;
}
