// ignore_for_file: avoid_relative_lib_imports
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generator/lib/src/capacity.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'cube_net_signature_test.dart' show netVariant;
import 'support.dart' show mathTypeData;

void main() {
  test('capacity reports rule-parameter sets independently of signatures', () {
    final type = parseProblemType({
      ...mathTypeData(),
      'rule': 'capacity-contract-probe',
    });
    final report = measureCapacity(
      type,
      ceiling: 2,
      rules: {'capacity-contract-probe': _TwoParameterSets()},
    );
    expect(report.signatures, 1);
    expect(
      report.ruleKeys,
      2,
      reason: 'Part 3b requires two independently enumerated counts. '
          'Distinct parameter sets can have the same spatial signature.',
    );
  });
}

class _TwoParameterSets implements Rule {
  @override
  String get name => 'capacity-contract-probe';
  @override
  int get version => 1;
  @override
  RuleResult generate(ProblemType type, Random random, int index) => RuleResult(
        variant: netVariant(),
        ruleParams: {'profile': index},
        cosmetics: {},
      );
}
