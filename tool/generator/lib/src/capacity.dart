import 'dart:math';

import 'check/signature.dart';
import 'model.dart';
import 'rule_key.dart';
import 'rules/rule.dart';

class CapacityReport {
  CapacityReport(this.ruleKeys, this.signatures, this.draws);
  final int ruleKeys;
  final int signatures;
  final int draws;
  bool get reachable => signatures >= 100;

  @override
  String toString() => 'distinct ruleKeys: $ruleKeys\n'
      'distinct signatures: $signatures\n'
      '100 reachable: ${reachable ? 'yes' : 'no'}';
}

/// Counts sampled draws, never estimates unobserved capacity or retries a draw.
CapacityReport measureCapacity(
  ProblemType type, {
  int ceiling = 2000,
  int seed = 20261117,
  Map<String, Rule>? rules,
}) {
  if (ceiling < 0 || seed < 0) {
    throw ArgumentError('Ceiling and seed must be nonnegative');
  }
  final rule = (rules ?? ruleRegistry)[type.rule];
  if (rule == null ||
      rule.name != type.rule ||
      rule.version != type.ruleVersion) {
    throw ArgumentError('Unknown rule or version: ${type.rule}');
  }
  final random = Random(seed);
  final signatures = <String>{};
  final keys = <String>{};
  for (var draw = 0; draw < ceiling; draw++) {
    final result = rule.generate(type, random, draw);
    signatures.add(canonicalSignature(result.variant));
    keys.add(taskRuleKey(type.rule, result.ruleParams));
  }
  return CapacityReport(keys.length, signatures.length, ceiling);
}
