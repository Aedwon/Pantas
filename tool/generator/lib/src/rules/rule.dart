import 'dart:math';

import '../model.dart';
import 'figure_grouping/grouping.dart';
import 'figure_matrices/matrices.dart';
import 'figure_series/series.dart';
import 'mental_rotation/nets.dart';

abstract class Rule {
  String get name;
  int get version;
  RuleResult generate(ProblemType t, Random r, int index);
}

/// Real rules register here as their separately assigned tasks land.
final ruleRegistry = <String, Rule>{
  for (final pattern in matrixPatterns) 'matrix-$pattern': MatrixRule(pattern),
  for (final pattern in netPatterns) 'net-$pattern': NetRule(pattern),
  for (final pattern in groupingPatterns)
    'group-$pattern': GroupingRule(pattern),
  for (final pattern in seriesPatterns) 'series-$pattern': SeriesRule(pattern),
};

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
