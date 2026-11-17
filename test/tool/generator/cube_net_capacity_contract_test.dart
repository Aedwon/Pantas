// ignore_for_file: avoid_relative_lib_imports
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generator/lib/src/capacity.dart';
import '../../../tool/generator/lib/src/model.dart';
import '../../../tool/generator/lib/src/rules/rule.dart';
import 'cube_net_signature_test.dart' show netVariant;
import 'support.dart' show mathTypeData;

void main() {
  test('capacity counts rule-parameter sets only for kept signatures', () {
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
      1,
      reason: 'Nov 17 ruling 5 counts only the first kept signature. '
          'A discarded duplicate contributes no rule-parameter set.',
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
