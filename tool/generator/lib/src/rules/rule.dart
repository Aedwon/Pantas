import 'dart:math';

import '../model.dart';

abstract class Rule {
  String get name;
  int get version;
  RuleResult generate(ProblemType t, Random r, int index);
}

/// Real rules register here as their separately assigned tasks land.
final ruleRegistry = <String, Rule>{};

/// Generation keeps rule parameters separate from cosmetic attributes.
class RuleResult {
  RuleResult({
    required this.variant,
    required this.ruleParams,
    required this.cosmetics,
  });
  final Variant variant;
  final Map<String, Object?> ruleParams;
  final Map<String, Object?> cosmetics;
}
