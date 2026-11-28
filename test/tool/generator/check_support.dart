// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generator/lib/src/check/math_solver.dart';
import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/check/solvers/solver.dart';
import '../../../tool/generator/lib/src/model.dart';

class TestMathSolver implements MathSolver {
  @override
  Map<String, Object?> ruleParams(ProblemType type, Variant variant) => {
        'a': variant.slots['a'],
        'b': variant.slots['b'],
      };
  @override
  List<String> validateCosmetics(ProblemType type, Variant variant) =>
      variant.cosmetics.isEmpty ? [] : ['math has no cosmetics'];
  @override
  Rational solve(ProblemType type, Variant variant) =>
      Rational.parse('${variant.slots['a']}') +
      Rational.parse('${variant.slots['b']}');
  @override
  List<String> validateRanges(ProblemType type, Variant variant) => [
        for (final key in ['a', 'b'])
          if ((variant.slots[key]! as int) < 1 ||
              (variant.slots[key]! as int) > (type.params['max']! as int))
            '$key out of range',
      ];
}

class TestFigureSolver implements FigureSolver {
  TestFigureSolver(this.answer);
  final int answer;
  @override
  Map<String, Object?> ruleParams(ProblemType type, Variant variant) => {};
  @override
  List<String> validateCosmetics(ProblemType type, Variant variant) {
    final errors = <String>[];
    void visit(Object? value) {
      if (value is List) {
        value.forEach(visit);
      }
      if (value is! Map) return;
      if (value.containsKey('x') && value.containsKey('y')) {
        for (final entry in variant.cosmetics.entries) {
          if (!value.containsKey(entry.key) ||
              dataKey(value[entry.key]) != dataKey(entry.value)) {
            errors.add('inconsistent cosmetic ${entry.key}');
          }
        }
      }
      value.values.forEach(visit);
    }

    visit(variant.figureSpec);
    for (final choice in variant.choices) {
      visit(choice.figure);
    }
    return errors;
  }

  @override
  String get kind => 'generic-test';
  @override
  bool fits(
    Map<String, Object?> shown,
    Map<String, Object?> candidate,
    Map<String, Object?> query,
  ) =>
      candidate['x'] == answer && candidate['y'] == 0;
  @override
  List<String> validateRanges(ProblemType type, Variant variant) => [];
}

/// Runs each test of the calling file against only the test solvers, then
/// puts the real solver library back. CI bundles several test files into one
/// isolate, so clearing the shared registries without restoring them emptied
/// the library for every later file in the bundle (PR #168, Nov 28).
void useTestSolverRegistry() {
  late Map<String, MathSolver> math;
  late Map<String, FigureSolver> figure;
  late Map<(String, String), MistakeSolver> mistake;
  setUp(() {
    math = Map.of(mathSolvers);
    figure = Map.of(figureSolvers);
    mistake = Map.of(mistakeSolvers);
    mathSolvers.clear();
    figureSolvers.clear();
    mistakeSolvers.clear();
    registerTestSolvers();
  });
  tearDown(() {
    mathSolvers
      ..clear()
      ..addAll(math);
    figureSolvers
      ..clear()
      ..addAll(figure);
    mistakeSolvers
      ..clear()
      ..addAll(mistake);
  });
}

void registerTestSolvers() {
  mathSolvers['testAdd'] = TestMathSolver();
  for (final id in ['subtract', 'extra-one', 'missing-one']) {
    mistakeSolvers[('testAdd', id)] = (type, variant) {
      final a = Rational.parse('${variant.slots['a']}');
      final b = Rational.parse('${variant.slots['b']}');
      return switch (id) {
        'subtract' => a - b,
        'extra-one' => a + b + Rational.parse('1'),
        _ => a + b - Rational.parse('1'),
      };
    };
  }
  figureSolvers['testFigure'] = TestFigureSolver(3);
  mistakeSolvers[('testFigure', 'short')] =
      (type, variant) => <String, Object?>{'x': 2, 'y': 0};
}
