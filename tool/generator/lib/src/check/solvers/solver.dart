import '../../model.dart';
import '../math_solver.dart';
import 'figure_series/series_solver.dart';

/// Independent of generation. Read the rule's documented params contract.
// Range validation is a per-rule contract shared by math and figure solvers.
// ignore: one_member_abstracts
abstract class Solver {
  Map<String, Object?> ruleParams(ProblemType type, Variant variant);
  List<String> validateCosmetics(ProblemType type, Variant variant);
  List<String> validateRanges(ProblemType type, Variant variant);
}

abstract class FigureSolver implements Solver {
  String get kind;

  /// True only when the shown figures obey this rule
  /// and candidate completes it. Figure choices pass their figure map.
  /// Text choices pass rendered `text` and optional `value`, without key or
  /// mistake metadata. Mistake solvers return the same candidate shape.
  /// [query] is the variant's slots: what the stem asks (for example the
  /// queried face or operation) lives there, never in the figure data, so
  /// merged questions keep their exact figure maps.
  bool fits(
    Map<String, Object?> shown,
    Map<String, Object?> candidate,
    Map<String, Object?> query,
  );
}

typedef MistakeSolver = Object Function(ProblemType type, Variant variant);

final mathSolvers = <String, MathSolver>{};
final figureSolvers = <String, FigureSolver>{
  for (final pattern in seriesMistakes.keys)
    'series-$pattern': SeriesSolver(pattern),
};
final mistakeSolvers = <(String, String), MistakeSolver>{
  for (final entry in seriesMistakes.entries)
    for (final id in entry.value)
      ('series-${entry.key}', id): (type, variant) =>
          SeriesSolver(entry.key).mistake(variant, id),
};
