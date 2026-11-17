import '../model.dart';
import 'solvers/solver.dart';

/// Evaluates a rule's documented formula from slots using exact arithmetic.
abstract class MathSolver implements Solver {
  Rational solve(ProblemType type, Variant variant);
}
