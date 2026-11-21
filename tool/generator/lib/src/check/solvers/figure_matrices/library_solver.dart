import '../../../model.dart';
import '../../signature.dart';
import '../solver.dart';

/// Independent competitors. Only the changing feature follows the operation;
/// other features must stay constant along rows or, for column rules, columns.
class MatrixLibrarySolver implements FigureSolver {
  MatrixLibrarySolver(this.operation, {this.columns = false, this.diagonal});
  final String operation;
  final bool columns;
  final int? diagonal;

  @override
  String get kind => 'figure-matrix';

  num? _combine(num a, num b) => switch (operation) {
        'product' => a * b,
        'difference' => (a - b).abs(),
        'maximum' => a > b ? a : b,
        'minimum' => a < b ? a : b,
        'quotient' => b == 0 ? null : a / b,
        _ => null,
      };

  @override
  bool fits(
    Map<String, Object?> shown,
    Map<String, Object?> candidate,
    Map<String, Object?> query,
  ) {
    if (shown['kind'] != kind) return false;
    try {
      final rows = shown['rows']! as int;
      final cols = shown['cols']! as int;
      final raw = shown['cells']! as List;
      if (raw.length != rows * cols ||
          raw.where((c) => c == 'blank').length != 1) {
        return false;
      }
      final feature = diagonal == null ? 'dots' : 'line';
      final cells = [
        for (final c in raw)
          c == 'blank' ? candidate : Map<String, Object?>.from(c as Map),
      ];
      Map<String, Object?> at(int y, int x) => cells[y * cols + x];
      Map<String, Object?> rest(Map<String, Object?> cell) =>
          Map<String, Object?>.of(cell)..remove(feature);
      if (diagonal != null) {
        if (cols < 2 || rows < 2) return false;
        for (var y = 0; y < rows; y++) {
          for (var x = 1; x < cols; x++) {
            if (dataKey(rest(at(y, x))) != dataKey(rest(at(y, 0))) ||
                at(y, x)['line'] !=
                    (diagonal! - (at(y, x - 1)['line']! as num)) % 360) {
              return false;
            }
          }
        }
      } else {
        // Count arithmetic alone cannot explain another changing feature.
        // Outlines/sizes may stay constant along rows or along columns.
        bool constantStructure({required bool downColumns}) {
          final lines = downColumns ? cols : rows;
          final length = downColumns ? rows : cols;
          for (var i = 0; i < lines; i++) {
            final first = downColumns ? at(0, i) : at(i, 0);
            for (var j = 1; j < length; j++) {
              final cell = downColumns ? at(j, i) : at(i, j);
              if (dataKey(rest(cell)) != dataKey(rest(first))) return false;
            }
          }
          return true;
        }

        if (!constantStructure(downColumns: false) &&
            !(columns && constantStructure(downColumns: true))) {
          return false;
        }
        if ((columns ? rows : cols) != 3) return false;
        for (var i = 0; i < (columns ? cols : rows); i++) {
          num count(int j) => (columns ? at(j, i) : at(i, j))['dots']! as num;
          if (_combine(count(0), count(1)) != count(2)) return false;
        }
      }
      return true;
    } on Object {
      return false;
    }
  }

  // Library-only solvers never validate the originating type's metadata.
  @override
  Map<String, Object?> ruleParams(ProblemType type, Variant variant) => {};
  @override
  List<String> validateCosmetics(ProblemType type, Variant variant) => [];
  @override
  List<String> validateRanges(ProblemType type, Variant variant) => [];
}
