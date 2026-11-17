import '../../model.dart';
import '../math_solver.dart';

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
  bool fits(Map<String, Object?> shown, Map<String, Object?> candidate);
}

typedef MistakeSolver = Object Function(ProblemType type, Variant variant);

final mathSolvers = <String, MathSolver>{};
final figureSolvers = <String, FigureSolver>{};
final mistakeSolvers = <(String, String), MistakeSolver>{};
