import '../../../model.dart';
import '../../signature.dart';
import '../solver.dart';

const matrixMistakes = <String, List<String>>{
  'ray-turn': ['hold-ray', 'copy-first-row-ray', 'copy-first-row-form'],
  'size-columns': ['copy-above', 'restart-top', 'change-form'],
  'size-fill': ['mislocate-blank', 'copy-middle-size', 'copy-top-size'],
  'ray-union': ['first-only', 'second-only', 'copy-example-rays'],
  'fill-union': ['erase-fill', 'first-half-only', 'second-half-only'],
  'corner-step': ['hold-dot', 'double-step', 'reverse-step'],
  'size-dots': ['freeze-dots', 'copy-middle-size', 'copy-top-size'],
  'ray-intersection': [
    'union-not-intersection',
    'second-ray-only',
    'second-exclusive',
  ],
  'corner-reflection': [
    'copy-example-location',
    'hold-dot',
    'copy-example-form',
  ],
  'binary-fill-row': ['repeat-middle', 'average-fill', 'change-form'],
  'arrow-column': ['restart-cycle', 'take-half-turn', 'repeat-above'],
  'form-ray': ['copy-middle-form', 'freeze-ray', 'copy-top-form'],
  'sized-ray-union': ['copy-middle-size', 'second-ray-only', 'first-ray-only'],
  'outline-latin': [
    'repeat-neighbor',
    'repeat-row-start',
    'introduce-fourth-form',
  ],
  'dot-sum': ['add-sequence-step', 'copy-second', 'subtract-inputs'],
  'size-latin': ['repeat-row-start', 'repeat-adjacent', 'change-form'],
  'growing-turn': [
    'use-smallest-step',
    'freeze-ray',
    'copy-first-row-diagonal',
  ],
  'corner-grid': ['copy-row-start', 'repeat-neighbor', 'repeat-above'],
  'size-transfer': ['freeze-edge-count', 'copy-middle-size', 'freeze-dots'],
};
const _sizes = ['small', 'medium', 'large'];
const _corners = ['top-left', 'top-right', 'bottom-right', 'bottom-left'];
const _arrows = ['up', 'right', 'down', 'left'];
const _forms = ['square', 'circle', 'triangle', 'pentagon', 'star'];
List<num> _rays(Map<String, Object?> a) => [
      if (a['line'] is num) a['line']! as num,
      if (a['lines'] is List) ...(a['lines']! as List).cast<num>(),
    ]..sort();
Map<String, Object?> _withRays(
  Map<String, Object?> a,
  Iterable<num> rays, {
  bool sort = true,
}) {
  final b = Map<String, Object?>.of(a)
    ..remove('line')
    ..remove('lines');
  final values = rays.toSet().toList();
  if (sort) values.sort();
  if (values.length == 1) {
    b['line'] = values.single;
  } else {
    b['lines'] = values;
  }
  return b;
}

Map<String, Object?> _normal(Map<String, Object?> a) => {
      ...a,
      if (a.containsKey('line') || a.containsKey('lines')) 'rays': _rays(a),
    }
      ..remove('line')
      ..remove('lines');
bool _same(Map<String, Object?> a, Map<String, Object?> b) =>
    dataKey(_normal(a)) == dataKey(_normal(b));

/// Independent matrix checker derived from the matrix contract, not rule code.
/// Reconstructs the missing cell from visible rows and columns, then checks
/// every supplied cell. Candidate feature keys must match exactly.
class MatrixSolver implements FigureSolver {
  MatrixSolver(
    this.pattern, {
    this.reflectRays = false,
    this.reflectRaysUpDown = false,
    this.continueCounts = false,
    this.highestRay = false,
    this.extremeRay,
  });
  final bool reflectRays;
  final bool reflectRaysUpDown;
  final bool continueCounts;
  final bool highestRay;
  final String? extremeRay;

  num _highestRay(Iterable<num> rays) {
    // Compass-grid heights, scaled without floating-point tie errors.
    final heights = switch (extremeRay) {
      'lowest' => [-2, -1, 0, 1, 2, 1, 0, -1],
      'leftmost' => [0, -1, -2, -1, 0, 1, 2, 1],
      'rightmost' => [0, 1, 2, 1, 0, -1, -2, -1],
      _ => [2, 1, 0, -1, -2, -1, 0, 1],
    };
    final values = rays.toSet();
    int height(num ray) {
      if (ray < 0 || ray >= 360 || ray % 45 != 0) {
        throw const FormatException('unsupported ray');
      }
      return heights[ray ~/ 45];
    }

    final highest = values.where(
      (ray) => values.every((other) => height(ray) >= height(other)),
    );
    if (highest.length != 1) {
      throw const FormatException('highest ray is not unique');
    }
    return highest.single;
  }

  final String pattern;
  @override
  String get kind => 'figure-matrix';

  Map<String, Object?> answer(Map<String, Object?> shown) {
    final cells = (shown['cells']! as List).cast<Object?>();
    final cols = shown['cols']! as int;
    final rows = shown['rows']! as int;
    final blank = cells.indexOf('blank');
    final y = blank ~/ cols;
    final x = blank % cols;
    Map<String, Object?> at(int row, int col) =>
        Map<String, Object?>.from(cells[row * cols + col]! as Map);
    Map<String, Object?> row(int row) => at(
          row,
          List.generate(cols, (i) => i)
              .firstWhere((i) => cells[row * cols + i] != 'blank'),
        );
    Map<String, Object?> column(int col) => at(
          List.generate(rows, (i) => i)
              .firstWhere((i) => cells[i * cols + col] != 'blank'),
          col,
        );
    final a = Map<String, Object?>.of(row(y));
    switch (pattern) {
      case 'ray-turn':
        a['line'] = reflectRays || reflectRaysUpDown
            ? ((reflectRaysUpDown ? 180 : 360) - (at(1, 0)['line']! as num)) %
                360
            : ((at(1, 0)['line']! as num) +
                    (at(0, 1)['line']! as num) -
                    (at(0, 0)['line']! as num)) %
                360;
      case 'corner-step':
        a['dot'] =
            _corners[(_corners.indexOf(at(1, 0)['dot']! as String) + 1) % 4];
      case 'corner-reflection':
        a['dot'] = _corners[_corners.indexOf(at(1, 0)['dot']! as String) ^ 1];
      case 'ray-union' || 'sized-ray-union':
        return _withRays(
          a,
          [..._rays(at(y, 0)), ..._rays(at(y, 1))],
          sort: false,
        );
      case 'ray-intersection':
        return _withRays(
          a,
          highestRay || extremeRay != null
              ? [
                  _highestRay([..._rays(at(y, 0)), ..._rays(at(y, 1))]),
                ]
              : _rays(at(y, 0)).where(_rays(at(y, 1)).contains),
        );
      case 'fill-union':
        a['fill'] = 'black';
        a.remove('rotation');
      case 'size-columns':
        break;
      case 'size-fill' || 'binary-fill-row':
        a['fill'] = column(x)['fill'];
      case 'size-dots':
        a['dots'] = column(x)['dots'];
      case 'size-transfer':
        a['dots'] = column(x)['dots'];
        a['edgeLines'] = column(x)['edgeLines'];
      case 'arrow-column':
        a['arrow'] = row(y)['arrow'];
      case 'form-ray':
        a['line'] = column(x)['line'];
      case 'outline-latin' || 'size-latin':
        final key = pattern == 'outline-latin' ? 'form' : 'size';
        final values = List.generate(rows, (i) => i)
            .where((i) => i != y)
            .expand((i) => List.generate(cols, (j) => at(i, j)[key]))
            .toSet();
        final present = List.generate(cols, (j) => j)
            .where((j) => j != x)
            .map((j) => at(y, j)[key])
            .toSet();
        a[key] = values.difference(present).single;
      case 'dot-sum':
        a['dots'] = continueCounts
            ? 2 * (at(y, 1)['dots']! as int) - (at(y, 0)['dots']! as int)
            : (at(y, 0)['dots']! as int) + (at(y, 1)['dots']! as int);
      case 'growing-turn':
        a['line'] = ((at(y, 0)['line']! as num) +
                2 * ((at(y, 1)['line']! as num) - (at(y, 0)['line']! as num))) %
            360;
      case 'corner-grid':
        final i = cells.indexWhere((v) => v is Map);
        final first = Map<String, Object?>.from(cells[i]! as Map);
        a['dot'] = _corners[(_corners.indexOf(first['dot']! as String) +
                x -
                i % cols -
                y +
                i ~/ cols) %
            4];
      default:
        throw FormatException('unknown matrix $pattern');
    }
    return a;
  }

  @override
  bool fits(
    Map<String, Object?> shown,
    Map<String, Object?> candidate,
    Map<String, Object?> query,
  ) {
    if (shown['kind'] != kind || shown['cells'] is! List) return false;
    try {
      if (!_same(answer(shown), candidate)) return false;
      final a = (shown['cells']! as List)
          .map(
            (v) =>
                v == 'blank' ? candidate : Map<String, Object?>.from(v as Map),
          )
          .toList();
      final rows = shown['rows']! as int;
      final cols = shown['cols']! as int;
      final expected = switch (pattern) {
        'ray-turn' || 'corner-step' || 'corner-reflection' => (2, 2),
        'size-columns' || 'arrow-column' => (3, 2),
        'ray-union' ||
        'ray-intersection' ||
        'fill-union' ||
        'binary-fill-row' =>
          (2, 3),
        _ => (3, 3),
      };
      if ((rows, cols) != expected || a.length != rows * cols) return false;
      Map<String, Object?> at(int y, int x) => a[y * cols + x];
      bool feature(String key, Object? Function(int, int) expected) {
        for (var y = 0; y < rows; y++) {
          for (var x = 0; x < cols; x++) {
            if (at(y, x)[key] != expected(y, x)) return false;
          }
        }
        return true;
      }

      final keys = switch (pattern) {
        'ray-turn' || 'form-ray' || 'growing-turn' => {'form', 'line'},
        'corner-step' || 'corner-reflection' || 'corner-grid' => {
            'form',
            'dot',
          },
        'size-columns' || 'size-latin' => {'form', 'size'},
        'size-fill' => {'form', 'size', 'fill'},
        'size-dots' => {'form', 'size', 'dots'},
        'size-transfer' => {'form', 'size', 'dots', 'edgeLines'},
        'binary-fill-row' => {'form', 'fill'},
        'arrow-column' => {'form', 'arrow'},
        'dot-sum' => {'form', 'dots'},
        'outline-latin' => {'form'},
        _ => <String>{},
      };
      if (keys.isNotEmpty &&
          a.any(
            (v) =>
                v.keys.toSet().difference(keys).isNotEmpty ||
                !v.keys.toSet().containsAll(keys),
          )) {
        return false;
      }
      if (pattern == 'outline-latin') {
        final forms = a.map((v) => v['form']).toSet();
        return forms.length == 3 &&
            List.generate(3, (i) => i).every(
              (i) =>
                  List.generate(3, (j) => at(i, j)['form']).toSet().length ==
                      3 &&
                  List.generate(3, (j) => at(j, i)['form']).toSet().length == 3,
            );
      }
      final rowForms = [
        'ray-turn',
        'corner-step',
        'corner-reflection',
        'ray-union',
        'ray-intersection',
        'form-ray',
      ].contains(pattern);
      if (!feature('form', (y, x) => at(rowForms ? y : 0, 0)['form'])) {
        return false;
      }
      if ([
            'ray-turn',
            'corner-reflection',
            'ray-union',
            'ray-intersection',
          ].contains(pattern) &&
          at(0, 0)['form'] == at(1, 0)['form']) {
        return false;
      }
      if (pattern == 'form-ray' &&
          List.generate(3, (i) => at(i, 0)['form']).toSet().length != 3) {
        return false;
      }
      if ([
        'size-columns',
        'size-fill',
        'size-dots',
        'size-transfer',
        'sized-ray-union',
      ].contains(pattern)) {
        if (!feature('size', (y, x) => at(y, 0)['size'])) return false;
        final sizes = List.generate(rows, (i) => at(i, 0)['size']);
        if (sizes.toSet().length != rows) return false;
        if (rows == 3 && sizes[1] != 'medium') return false;
      }
      switch (pattern) {
        case 'ray-turn':
          if (reflectRays || reflectRaysUpDown) {
            return feature(
              'line',
              (y, x) => x == 0
                  ? at(y, 0)['line']
                  : ((reflectRaysUpDown ? 180 : 360) -
                          (at(y, 0)['line']! as num)) %
                      360,
            );
          }
          final step =
              ((at(0, 1)['line']! as num) - (at(0, 0)['line']! as num)) % 360;
          return [45, 90, 135].contains(step) &&
              feature(
                'line',
                (y, x) => ((at(y, 0)['line']! as num) + x * step) % 360,
              );
        case 'corner-step':
          if (a.any((cell) => cell['form'] != 'square')) return false;
          return feature(
            'dot',
            (y, x) => _corners[
                (_corners.indexOf(at(y, 0)['dot']! as String) + x) % 4],
          );
        case 'corner-reflection':
          return feature(
            'dot',
            (y, x) => x == 0
                ? at(y, 0)['dot']
                : _corners[(_corners.indexOf(at(y, 0)['dot']! as String) ^ 1)],
          );
        case 'size-fill' || 'binary-fill-row':
          return ['black', 'white'].contains(at(0, 0)['fill']) &&
              feature(
                'fill',
                (y, x) => x.isEven
                    ? at(0, 0)['fill']
                    : at(0, 0)['fill'] == 'black'
                        ? 'white'
                        : 'black',
              );
        case 'size-dots' || 'size-transfer':
          return feature('dots', (y, x) => (at(0, 0)['dots']! as int) + x) &&
              (pattern != 'size-transfer' ||
                  feature(
                    'edgeLines',
                    (y, x) => (at(0, 0)['edgeLines']! as int) - x,
                  ));
        case 'arrow-column':
          return feature(
            'arrow',
            (y, x) => _arrows[
                (_arrows.indexOf(at(0, 0)['arrow']! as String) + y) % 4],
          );
        case 'form-ray':
          final step =
              ((at(0, 1)['line']! as num) - (at(0, 0)['line']! as num)) % 360;
          return [45, 90, 135].contains(step) &&
              feature(
                'line',
                (y, x) => ((at(0, 0)['line']! as num) + x * step) % 360,
              );
        case 'size-latin':
          final phase = _sizes.indexOf(at(0, 0)['size']! as String);
          final shift =
              (_sizes.indexOf(at(1, 0)['size']! as String) - phase) % 3;
          return [1, 2].contains(shift) &&
              feature('size', (y, x) => _sizes[(phase + x + shift * y) % 3]);
        case 'corner-grid':
          return feature(
            'dot',
            (y, x) => _corners[
                (_corners.indexOf(at(0, 0)['dot']! as String) + x - y) % 4],
          );
        case 'growing-turn':
          final step =
              ((at(0, 1)['line']! as num) - (at(0, 0)['line']! as num)) % 360;
          return [45, 90].contains(step) &&
              feature(
                'line',
                (y, x) =>
                    ((at(0, 0)['line']! as num) + (y + 1) * step * x) % 360,
              );
        case 'dot-sum':
          return List.generate(rows, (y) => y).every(
            (y) =>
                at(y, 2)['dots'] ==
                (continueCounts
                    ? 2 * (at(y, 1)['dots']! as int) -
                        (at(y, 0)['dots']! as int)
                    : (at(y, 0)['dots']! as int) + (at(y, 1)['dots']! as int)),
          );
        case 'ray-union' || 'ray-intersection' || 'sized-ray-union':
          for (var y = 0; y < rows; y++) {
            final left = _rays(at(y, 0)).toSet();
            final right = _rays(at(y, 1)).toSet();
            if (pattern == 'sized-ray-union' &&
                (dataKey(_rays(at(y, 0))) != dataKey(_rays(at(0, 0))) ||
                    dataKey(_rays(at(y, 1))) != dataKey(_rays(at(0, 1))))) {
              return false;
            }
            if (pattern == 'ray-intersection'
                ? left.length != 2 ||
                    right.length != 2 ||
                    left.intersection(right).length != 1
                : left.length != 1 ||
                    right.length != 1 ||
                    left.intersection(right).isNotEmpty) {
              return false;
            }
            final rays = pattern == 'ray-intersection'
                ? highestRay || extremeRay != null
                    ? {
                        _highestRay([...left, ...right]),
                      }
                    : left.intersection(right)
                : left.union(right);
            if (dataKey(_rays(at(y, 2))) != dataKey(rays.toList()..sort())) {
              return false;
            }
            for (var x = 0; x < 3; x++) {
              if (at(y, x)
                  .keys
                  .any((k) => !{'form', 'size', 'line', 'lines'}.contains(k))) {
                return false;
              }
            }
          }
          return true;
        case 'fill-union':
          if (at(0, 0)['size'] == at(1, 0)['size']) return false;
          if (!feature('size', (y, x) => at(y, 0)['size'])) return false;
          for (final item in a) {
            if (item.keys.any(
              (key) => !{'form', 'size', 'fill', 'rotation'}.contains(key),
            )) {
              return false;
            }
          }
          if (![0, 90].contains(at(0, 0)['rotation'] ?? 0) ||
              at(1, 0)['rotation'] != at(0, 0)['rotation']) {
            return false;
          }
          for (var y = 0; y < 2; y++) {
            if (at(y, 0)['fill'] != .5 ||
                at(y, 1)['fill'] != .5 ||
                at(y, 2)['fill'] != 'black') {
              return false;
            }
            final angle = (at(y, 0)['rotation'] as num?) ?? 0;
            if (((at(y, 1)['rotation'] as num?) ?? 0) != (angle + 180) % 360) {
              return false;
            }
            if (at(y, 2).containsKey('rotation')) return false;
            if (at(y, 0).keys.any(
                  (k) => !{'form', 'size', 'fill', 'rotation'}.contains(k),
                )) {
              return false;
            }
          }
          return true;
        default:
          return pattern == 'size-columns';
      }
    } on Object {
      return false;
    }
  }

  Map<String, Object?> mistake(Variant v, String id) {
    final shown = v.figureSpec!;
    final cells = (shown['cells']! as List).cast<Object?>();
    final cols = shown['cols']! as int;
    final b = cells.indexOf('blank');
    final y = b ~/ cols;
    final x = b % cols;
    Map<String, Object?> at(int row, int col) =>
        Map<String, Object?>.from(cells[row * cols + col]! as Map);
    final result = answer(shown);
    void copy(String key, int row, int col) {
      result[key] = at(row, col)[key];
    }

    switch (id) {
      case 'hold-ray' || 'freeze-ray':
        copy('line', y, x == 0 ? 1 : x - 1);
      case 'copy-first-row-ray':
        copy('line', 0, 1);
      case 'copy-first-row-form' || 'copy-example-form' || 'copy-top-form':
        copy('form', 0, 0);
      case 'copy-above' || 'copy-middle-size':
        copy('size', 1, 0);
      case 'restart-top' || 'copy-top-size':
        copy('size', 0, 0);
      case 'change-form' || 'introduce-fourth-form':
        result['form'] = v.slots['extraForm'];
      case 'mislocate-blank':
        result['fill'] = result['fill'] == 'black' ? 'white' : 'black';
      case 'first-only' || 'first-ray-only':
        return _withRays(result, _rays(at(y, 0)));
      case 'second-only' || 'second-ray-only':
        return _withRays(result, _rays(at(y, 1)));
      case 'copy-example-rays':
        return _withRays(result, _rays(at(0, 2)));
      case 'erase-fill':
        result['fill'] = 'white';
      case 'first-half-only' || 'second-half-only':
        final input = at(y, id == 'first-half-only' ? 0 : 1);
        result['fill'] = .5;
        if (input['rotation'] != null) result['rotation'] = input['rotation'];
      case 'hold-dot':
        copy('dot', 1, 0);
      case 'double-step' || 'reverse-step':
        result['dot'] = _corners[(_corners.indexOf(at(1, 0)['dot']! as String) +
                (id == 'double-step' ? 2 : 3)) %
            4];
      case 'freeze-dots':
        copy('dots', y, x == 0 ? 1 : x - 1);
      case 'union-not-intersection':
        return _withRays(result, [..._rays(at(y, 0)), ..._rays(at(y, 1))]);
      case 'first-exclusive':
        return _withRays(
          result,
          _rays(at(y, 0)).where((v) => !_rays(at(y, 1)).contains(v)),
        );
      case 'second-exclusive':
        return _withRays(
          result,
          _rays(at(y, 1)).where((v) => !_rays(at(y, 0)).contains(v)),
        );
      case 'copy-example-location':
        copy('dot', 0, 1);
      case 'repeat-middle':
        result['fill'] = result['fill'] == 'black' ? 'white' : 'black';
      case 'average-fill':
        result['fill'] = .5;
      case 'restart-cycle':
        copy('arrow', 0, 0);
      case 'take-half-turn':
        result['arrow'] =
            _arrows[(_arrows.indexOf(at(1, 0)['arrow']! as String) + 2) % 4];
      case 'repeat-above':
        copy(pattern == 'arrow-column' ? 'arrow' : 'dot', y - 1, x);
      case 'copy-middle-form':
        copy('form', 1, 0);
      case 'repeat-neighbor' || 'repeat-adjacent':
        final key = pattern == 'outline-latin'
            ? 'form'
            : pattern == 'size-latin'
                ? 'size'
                : 'dot';
        copy(key, y, x == 0 ? 1 : x - 1);
      case 'repeat-row-start' || 'copy-row-start':
        copy(
          pattern == 'outline-latin'
              ? 'form'
              : pattern == 'size-latin'
                  ? 'size'
                  : 'dot',
          y,
          0,
        );
      case 'add-sequence-step':
        result['dots'] =
            2 * (at(y, 1)['dots']! as int) - (at(y, 0)['dots']! as int);
      case 'copy-second':
        copy('dots', y, 1);
      case 'subtract-inputs':
        result['dots'] =
            ((at(y, 1)['dots']! as int) - (at(y, 0)['dots']! as int)).abs();
      case 'use-smallest-step':
        result['line'] = ((at(y, 1)['line']! as num) +
                (at(0, 1)['line']! as num) -
                (at(0, 0)['line']! as num)) %
            360;
      case 'copy-first-row-diagonal':
        copy('line', 0, 1);
      case 'freeze-edge-count':
        copy('edgeLines', y, x == 0 ? 1 : x - 1);
      default:
        throw FormatException('unknown mistake $id');
    }
    return result;
  }

  @override
  Map<String, Object?> ruleParams(ProblemType type, Variant v) => {
        'pattern': pattern,
        'shown': {
          ...v.figureSpec!,
          'cells': [
            for (final cell in v.figureSpec!['cells']! as List)
              if (cell is Map)
                {
                  for (final entry in cell.entries)
                    if (!_cosmetic || entry.key != 'form')
                      entry.key as String: entry.value,
                }
              else
                cell,
          ],
        },
      };
  bool get _cosmetic => [
        'size-fill',
        'fill-union',
        'size-dots',
        'arrow-column',
        'sized-ray-union',
        'dot-sum',
        'growing-turn',
        'corner-grid',
        'size-transfer',
      ].contains(pattern);
  @override
  List<String> validateCosmetics(ProblemType type, Variant v) {
    if (!_cosmetic) return v.cosmetics.isEmpty ? [] : ['unexpected cosmetics'];
    final items =
        (v.figureSpec!['cells']! as List).whereType<Map<String, Object?>>();
    final form = items.first['form'];
    return [
      if (dataKey(v.cosmetics) != dataKey({'form': form}))
        'cosmetic form mismatch',
      if ([...items, ...v.choices.map((c) => c.figure!)]
          .any((a) => a['form'] != form))
        'cosmetic form varies within version',
    ];
  }

  @override
  List<String> validateRanges(ProblemType type, Variant v) {
    final errors = <String>[];
    final cells = (v.figureSpec!['cells']! as List)
        .whereType<Map<String, Object?>>()
        .map(Map<String, Object?>.from);
    for (final a in [...cells, ...v.choices.map((c) => c.figure!)]) {
      if (!_forms.contains(a['form']) ||
          !(type.params['forms']! as List).contains(a['form'])) {
        errors.add('unsupported form');
      }
      if (a['size'] != null &&
          (!_sizes.contains(a['size']) ||
              !(type.params['sizes']! as List).contains(a['size']))) {
        errors.add('unsupported size');
      }
      for (final key in ['dots', 'edgeLines']) {
        if (a[key] != null &&
            (a[key] is! int ||
                (a[key]! as int) < 0 ||
                (a[key]! as int) > 5 ||
                !(type.params[key]! as List).contains(a[key]))) {
          errors.add('$key out of range');
        }
      }
      if (_rays(a).any(
        (v) =>
            v < 0 ||
            v >= 360 ||
            v % 45 != 0 ||
            !(type.params['rays']! as List).contains(v),
      )) {
        errors.add('unsupported ray');
      }
    }
    final shown = v.figureSpec!;
    final cols = shown['cols']! as int;
    final completeCells = (shown['cells']! as List)
        .map(
          (a) => a == 'blank'
              ? answer(shown)
              : Map<String, Object?>.from(a as Map),
        )
        .toList();
    Map<String, Object?> at(int y, int x) => completeCells[y * cols + x];
    if (['ray-turn', 'form-ray'].contains(pattern)) {
      final step =
          ((at(0, 1)['line']! as num) - (at(0, 0)['line']! as num)) % 360;
      if (!(type.params['steps']! as List).contains(step)) {
        errors.add('step outside params');
      }
    }
    if (pattern == 'growing-turn') {
      final step =
          ((at(0, 1)['line']! as num) - (at(0, 0)['line']! as num)) % 360;
      if (!(type.params['growingSteps']! as List).contains(step)) {
        errors.add('growing step outside params');
      }
    }
    if (['size-dots', 'size-transfer'].contains(pattern) &&
        !(type.params['initialDots']! as List).contains(at(0, 0)['dots'])) {
      errors.add('initial dots outside params');
    }
    if (pattern == 'size-transfer' &&
        !(type.params['initialEdges']! as List)
            .contains(at(0, 0)['edgeLines'])) {
      errors.add('initial edges outside params');
    }
    if (pattern == 'dot-sum') {
      for (var y = 0; y < 3; y++) {
        for (var x = 0; x < 2; x++) {
          if (!(type.params['sumInputs']! as List).contains(at(y, x)['dots'])) {
            errors.add('sum input outside params');
          }
        }
      }
    }
    return errors;
  }
}
