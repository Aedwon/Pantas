import 'package:flutter/foundation.dart';
import 'package:pantas/features/paywall/domain/price_tier.dart';

/// A pending subject change that would lift a custom exam to [tier]. It rides
/// the upgrade route's extra so the upgrade screen prices the exam at its new
/// tier. It carries no subjects: the page that asked keeps the change and
/// saves it only when the screen returns true.
@immutable
class CustomTierRaise {
  const CustomTierRaise({required this.examName, required this.tier});

  final String examName;
  final PriceTier tier;
}
