/// Matrix contracts, all indexes row-major. Params: forms are the five drawn
/// outlines; sizes are small/medium/large; ray starts lie on the 45-degree grid.
/// Source index 0 retains literal figure data and choice text. Draws reject
/// colliding answers and unsupported counts. Blank positions may vary where
/// the source mistakes still have visible reference cells.
///
/// ray-turn: 2x2, distinct row forms, equal clockwise 45/90/135 row turns.
/// hold-ray keeps row start; copy-first-row-ray copies the example output;
/// copy-first-row-form retains the target ray on the example outline.
/// size-columns: 3x2, identical columns, sizes increase or decrease.
/// copy-above uses middle size; restart-top uses top size; change-form changes
/// only outline.
/// size-fill: 3x3, size changes by row, black/white alternate by column.
/// mislocate-blank inverts fill; copy-middle-size and copy-top-size keep fill.
/// ray-union: 2x3, two disjoint single rays combine, distinct row forms.
/// first-only/second-only omit one ray; copy-example-rays copies top output.
/// fill-union: 2x3, square/circle only, two distinct row sizes.
/// Complementary half fills, split
/// horizontal or vertical. erase-fill outputs white; first-half-only and
/// second-half-only keep only the respective input fill.
/// corner-step: 2x2, square rows only, clockwise corner move.
/// The historical circle source is preserved only for held-source review.
/// hold-dot stays; double-step moves twice; reverse-step moves backward.
/// size-dots: 3x3, size by row, dots increase across, start 0..3.
/// freeze-dots repeats preceding count; copy-middle-size/copy-top-size keep dots.
/// ray-intersection: 2x3, two rays per input, one shared, distinct row forms.
/// union-not-intersection keeps all; first-exclusive/second-exclusive keep
/// only that input's unshared ray.
/// corner-reflection: 2x2, reflect corner left/right, distinct row forms.
/// copy-example-location copies top output dot; hold-dot stays;
/// copy-example-form changes only outline to top row.
/// binary-fill-row: 2x3, black/white alternate, rows identical.
/// repeat-middle inverts answer fill; average-fill halves it; change-form.
/// arrow-column: 3x2, columns identical, clockwise cardinal quarter turns.
/// restart-cycle takes top arrow; take-half-turn opposes middle arrow;
/// repeat-above takes the preceding row arrow.
/// form-ray: 3x3, distinct row forms, shared row turn 45/90/135.
/// copy-middle-form/copy-top-form change outline; freeze-ray repeats previous.
/// sized-ray-union: 3x3, size by row, same disjoint pair of rays in each row.
/// copy-middle-size changes size; second-ray-only/first-ray-only omit a ray.
/// outline-latin: 3x3, three distinct forms, cyclic shifts either direction.
/// repeat-neighbor copies adjacent form; repeat-row-start copies first;
/// introduce-fourth-form selects a form absent from the grid.
/// dot-sum: 3x3, first two counts 1..4, third their sum <=5.
/// add-sequence-step continues the input difference; copy-second repeats it;
/// subtract-inputs takes absolute difference, all answers 0..5.
/// size-latin: 3x3, three-size cycle shifted one place either way per row.
/// repeat-row-start/repeat-adjacent copy those sizes; change-form.
/// growing-turn: 3x3, shared start, row steps increment by 45 or 90.
/// use-smallest-step adds first row's step to last visible ray;
/// freeze-ray holds; copy-first-row-diagonal copies top middle.
/// corner-grid: 3x3, clockwise across, counterclockwise down.
/// copy-row-start/repeat-neighbor copy those dots; repeat-above copies above.
/// Source note remains held for correction under the lead ruling.
/// size-transfer: 3x3, row size, dots start 0..3 and rise, edges start 2..5
/// and fall by one across. freeze-edge-count/freeze-dots hold previous track;
/// copy-middle-size retains both counts.
/// Constant outline is cosmetic only when no row outline or outline mistake
/// changes it. Every cosmetic is recorded and constant in shown and choices.
library;

import 'dart:convert';
import 'dart:math';

import '../../check/series_signature.dart';
import '../../check/signature.dart';
import '../../model.dart';
import '../rule.dart';
import 'sources.dart';

// The intersection contract has only one single-ray distractor, the
// second input's exclusive ray. Other matrix patterns require different
// features or input ray counts.
bool _hasDirectionalDistractor(
  List<String> forms,
  List<int> shared,
  List<int> firstExclusive,
  List<int> secondExclusive,
) {
  const directions = [0, 45, 90, 135, 180, 225, 270, 315];
  for (final useTip in [false, true]) {
    for (final direction in directions) {
      double score(int row, int ray) =>
          cos((ray - direction) * pi / 180) *
          (useTip ? _normalizedReach(forms[row], ray) : 1);
      bool wins(int row, int ray, int otherA, int otherB) =>
          score(row, ray) - max(score(row, otherA), score(row, otherB)) > 1e-9;
      if (wins(0, shared[0], firstExclusive[0], secondExclusive[0]) &&
          wins(1, secondExclusive[1], shared[1], firstExclusive[1])) {
        return true;
      }
    }
  }
  return false;
}

// Use the two vertices bracketing the ray and the sine rule to find how
// much of the nominal radius the outline allows.
double _normalizedReach(String form, int ray) {
  if (form == 'circle' || form == 'square') return 1;
  final sides = switch (form) {
    'triangle' => 3,
    'pentagon' => 5,
    'star' => 10,
    _ => throw StateError('Unsupported ray outline: $form'),
  };
  final wedge = ray * sides / 360;
  final leftIndex = wedge.floor();
  final sector = 2 * pi / sides;
  final leftAngle = (wedge - leftIndex) * sector;
  final leftRadius = form == 'star' && leftIndex.isOdd ? 0.42 : 1.0;
  final rightRadius = form == 'star' && leftIndex.isEven ? 0.42 : 1.0;
  return min(
    1,
    sin(sector) /
        (sin(sector - leftAngle) / leftRadius + sin(leftAngle) / rightRadius),
  );
}

const matrixPatterns = [
  'ray-turn',
  'size-columns',
  'size-fill',
  'ray-union',
  'fill-union',
  'corner-step',
  'size-dots',
  'ray-intersection',
  'corner-reflection',
  'binary-fill-row',
  'arrow-column',
  'form-ray',
  'sized-ray-union',
  'outline-latin',
  'dot-sum',
  'size-latin',
  'growing-turn',
  'corner-grid',
  'size-transfer',
];
const _sizes = ['small', 'medium', 'large'];
const _corners = ['top-left', 'top-right', 'bottom-right', 'bottom-left'];
const _arrows = ['up', 'right', 'down', 'left'];

class MatrixRule implements Rule {
  MatrixRule(this.pattern);
  final String pattern;
  @override
  String get name => 'matrix-$pattern';
  @override
  int get version => 1;

  @override
  RuleResult generate(ProblemType t, Random r, int index) {
    final source = (jsonDecode(matrixSources) as Map<String, dynamic>)[pattern]
        as Map<String, dynamic>;
    final fixed = index == 0;
    for (var attempt = 0; attempt < 1000; attempt++) {
      final forms = (t.params['forms']! as List).cast<String>().toList()
        ..shuffle(r);
      final sizes = (t.params['sizes']! as List).cast<String>().toList();
      if (r.nextBool()) sizes.setAll(0, sizes.reversed.toList());
      final rowForms = [
        'ray-turn',
        'ray-union',
        'corner-step',
        'ray-intersection',
        'corner-reflection',
        'form-ray',
      ].contains(pattern);
      final rows = [
        'ray-turn',
        'ray-union',
        'fill-union',
        'corner-step',
        'ray-intersection',
        'corner-reflection',
        'binary-fill-row',
      ].contains(pattern)
          ? 2
          : 3;
      final cols = [
        'ray-turn',
        'size-columns',
        'corner-step',
        'corner-reflection',
        'arrow-column',
      ].contains(pattern)
          ? 2
          : 3;
      T pick<T>(String key) {
        final values = (t.params[key]! as List).cast<T>();
        return values[r.nextInt(values.length)];
      }

      final start = pick<int>('rays');
      final step = pick<int>('steps');
      final starts = [start, pick<int>('rays'), pick<int>('rays')];
      final corners = [r.nextInt(4), r.nextInt(4)];
      final arrow = r.nextInt(4);
      final phase = r.nextInt(3);
      final shift = r.nextBool() ? 1 : 2;
      final fill = r.nextBool();
      final dotStart = pick<int>('initialDots');
      final edgeStart = pick<int>('initialEdges');
      final growing = pick<int>('growingSteps');
      final split = r.nextBool() ? 0 : 90;
      final pairA = List.generate(rows, (_) => pick<int>('rays'));
      final pairB = List.generate(rows, (_) => pick<int>('rays'));
      final shared = List.generate(rows, (_) => pick<int>('rays'));
      if (List.generate(rows, (i) => i).any(
        (i) =>
            pairA[i] == pairB[i] ||
            (pattern == 'ray-intersection' &&
                [pairA[i], pairB[i]].contains(shared[i])),
      )) {
        continue;
      }
      if (!fixed &&
          pattern == 'ray-intersection' &&
          _hasDirectionalDistractor(
            forms,
            shared,
            pairA,
            pairB,
          )) {
        continue;
      }
      final inputs = List.generate(
        3,
        (_) => [pick<int>('sumInputs'), pick<int>('sumInputs')],
      );
      if (pattern == 'dot-sum' &&
          (inputs.any((p) => p[0] + p[1] > 5) ||
              inputs.take(2).any((p) => p[0] + p[1] == 2 * p[1] - p[0]))) {
        continue;
      }
      if (!fixed && pattern == 'dot-sum') {
        final grid = [
          for (final p in inputs) [p[0], p[1], p[0] + p[1]],
        ];
        final target = inputs[2];
        final wrong = {
          2 * target[1] - target[0],
          target[1],
          (target[1] - target[0]).abs(),
        };
        num? combine(int a, int b, int op) => switch (op) {
              0 => a * b,
              1 => (a - b).abs(),
              2 => max(a, b),
              3 => min(a, b),
              _ => b == 0 ? null : a / b,
            };
        var ambiguous = false;
        for (var op = 0; op < 5; op++) {
          if ([0, 1].every(
                (y) => combine(grid[y][0], grid[y][1], op) == grid[y][2],
              ) &&
              wrong.contains(combine(target[0], target[1], op))) {
            ambiguous = true;
          }
          if ([0, 1].every(
                (x) => combine(grid[0][x], grid[1][x], op) == grid[2][x],
              ) &&
              wrong.contains(combine(grid[0][2], grid[1][2], op))) {
            ambiguous = true;
          }
        }
        if (ambiguous) continue;
      }
      final fillSizes =
          pattern == 'fill-union' ? ([..._sizes]..shuffle(r)) : sizes;
      Map<String, Object?> cell(int y, int x) {
        final a = <String, Object?>{
          'form': pattern == 'corner-step'
              ? 'square'
              : rowForms
                  ? forms[y]
                  : forms[0],
        };
        switch (pattern) {
          case 'ray-turn':
            a['line'] = (starts[y] + x * step) % 360;
          case 'size-columns':
            a['size'] = sizes[y];
          case 'size-fill':
            a['size'] = sizes[y];
            a['fill'] = x.isEven == fill ? 'black' : 'white';
          case 'ray-union':
            if (x < 2) {
              a['line'] = x == 0 ? pairA[y] : pairB[y];
            } else {
              a['lines'] = [pairA[y], pairB[y]];
            }
          case 'fill-union':
            a['size'] = fillSizes[y];
            a['fill'] = x == 2 ? 'black' : .5;
            if (x < 2 && (split + 180 * x) % 360 != 0) {
              a['rotation'] = (split + 180 * x) % 360;
            }
          case 'corner-step':
            a['dot'] = _corners[(corners[y] + x) % 4];
          case 'size-dots':
            a['size'] = sizes[y];
            a['dots'] = dotStart + x;
          case 'ray-intersection':
            if (x == 2) {
              a['line'] = shared[y];
            } else {
              a['lines'] = [shared[y], if (x == 0) pairA[y] else pairB[y]];
            }
          case 'corner-reflection':
            a['dot'] = _corners[x == 0 ? corners[y] : corners[y] ^ 1];
          case 'binary-fill-row':
            a['fill'] = x.isEven == fill ? 'black' : 'white';
          case 'arrow-column':
            a['arrow'] = _arrows[(arrow + y) % 4];
          case 'form-ray':
            a['line'] = (start + x * step) % 360;
          case 'sized-ray-union':
            a['size'] = sizes[y];
            if (x < 2) {
              a['line'] = x == 0 ? pairA[0] : pairB[0];
            } else {
              a['lines'] = [pairA[0], pairB[0]];
            }
          case 'outline-latin':
            a['form'] = forms[(x + y * shift) % 3];
          case 'dot-sum':
            a['dots'] = x < 2 ? inputs[y][x] : inputs[y][0] + inputs[y][1];
          case 'size-latin':
            a['size'] = _sizes[(phase + x + y * shift) % 3];
          case 'growing-turn':
            a['line'] = (start + x * (y + 1) * growing) % 360;
          case 'corner-grid':
            a['dot'] = _corners[(corners[0] + x - y) % 4];
          case 'size-transfer':
            a['size'] = sizes[y];
            a['dots'] = dotStart + x;
            a['edgeLines'] = edgeStart - x;
        }
        return a;
      }

      var blank = rows * cols - 1;
      if ([
        'size-fill',
        'size-dots',
        'binary-fill-row',
        'arrow-column',
        'form-ray',
        'outline-latin',
        'size-latin',
        'corner-grid',
        'size-transfer',
      ].contains(pattern)) {
        blank = r.nextInt(rows * cols);
      }
      if (pattern == 'size-columns') {
        blank = (rows - 1) * cols + r.nextInt(cols);
      }
      final complete =
          List.generate(rows * cols, (i) => cell(i ~/ cols, i % cols));
      final shown = fixed
          ? Map<String, Object?>.from(source['figureSpec'] as Map)
          : <String, Object?>{
              'kind': 'figure-matrix',
              'rows': rows,
              'cols': cols,
              'cells': [
                for (var i = 0; i < complete.length; i++)
                  if (i == blank) 'blank' else complete[i],
              ],
            };
      final rawCells = shown['cells']! as List;
      final ncols = shown['cols']! as int;
      final b = rawCells.indexOf('blank');
      final y = b ~/ ncols;
      final x = b % ncols;
      Map<String, Object?> at(int yy, int xx) =>
          Map<String, Object?>.from(rawCells[yy * ncols + xx] as Map);
      Map<String, Object?> originalAnswer() => switch (pattern) {
            'ray-turn' => {'form': 'square', 'line': 270},
            'size-columns' => {'form': 'square', 'size': 'large'},
            'size-fill' => {'form': 'square', 'size': 'large', 'fill': 'white'},
            'ray-union' => {
                'form': 'square',
                'lines': [45, 135],
              },
            'fill-union' => {
                'form': 'square',
                'size': 'large',
                'fill': 'black',
              },
            'corner-step' => {'form': 'square', 'dot': 'top-right'},
            'size-dots' => {'form': 'triangle', 'size': 'large', 'dots': 3},
            'ray-intersection' => {'form': 'square', 'line': 135},
            'corner-reflection' => {'form': 'pentagon', 'dot': 'bottom-left'},
            'binary-fill-row' => {'form': 'star', 'fill': 'black'},
            'arrow-column' => {'form': 'circle', 'arrow': 'down'},
            'form-ray' => {'form': 'pentagon', 'line': 90},
            'sized-ray-union' => {
                'form': 'square',
                'size': 'large',
                'lines': [90, 0],
              },
            'outline-latin' => {'form': 'triangle'},
            'dot-sum' => {'form': 'circle', 'dots': 4},
            'size-latin' => {'form': 'square', 'size': 'medium'},
            'growing-turn' => {'form': 'square', 'line': 270},
            'corner-grid' => {'form': 'square', 'dot': 'top-left'},
            'size-transfer' => {
                'form': 'square',
                'size': 'large',
                'dots': 3,
                'edgeLines': 1,
              },
            _ => throw StateError(pattern),
          };
      final answer = fixed ? originalAnswer() : complete[blank];
      final extra = fixed
          ? switch (pattern) {
              'size-columns' => 'triangle',
              'binary-fill-row' => 'circle',
              'outline-latin' => 'pentagon',
              'size-latin' => 'circle',
              _ => null
            }
          : forms.firstWhere(
              (f) => !rawCells
                  .whereType<Map<String, Object?>>()
                  .any((a) => a['form'] == f),
              orElse: () => forms.last,
            );
      List<num> rays(Map<String, Object?> a) => [
            if (a['line'] != null) a['line']! as num,
            if (a['lines'] != null) ...(a['lines']! as List).cast<num>(),
          ];
      Map<String, Object?> setRays(
        Map<String, Object?> a,
        Iterable<num> values,
      ) {
        final result = Map<String, Object?>.of(a)
          ..remove('line')
          ..remove('lines');
        final list = values.toSet().toList()..sort();
        if (list.length == 1) {
          result['line'] = list.single;
        } else {
          result['lines'] = list;
        }
        return result;
      }

      final mistakes = t.mistakes.map((m) => m.id).toList();
      final figures = <Map<String, Object?>>[answer];
      try {
        for (final id in mistakes) {
          var wrong = Map<String, Object?>.of(answer);
          switch (id) {
            case 'hold-ray' || 'freeze-ray':
              wrong['line'] = at(y, x == 0 ? 1 : x - 1)['line'];
            case 'copy-first-row-ray':
              wrong['line'] = at(0, 1)['line'];
            case 'copy-first-row-form' ||
                  'copy-example-form' ||
                  'copy-top-form':
              wrong['form'] = at(0, 0)['form'];
            case 'copy-above' || 'copy-middle-size':
              wrong['size'] = at(1, 0)['size'];
            case 'restart-top' || 'copy-top-size':
              wrong['size'] = at(0, 0)['size'];
            case 'change-form' || 'introduce-fourth-form':
              wrong['form'] = extra;
            case 'mislocate-blank' || 'repeat-middle':
              wrong['fill'] = answer['fill'] == 'white' ? 'black' : 'white';
            case 'first-only' || 'first-ray-only':
              wrong = setRays(wrong, rays(at(y, 0)));
            case 'second-only' || 'second-ray-only':
              wrong = setRays(wrong, rays(at(y, 1)));
            case 'copy-example-rays':
              wrong = setRays(wrong, rays(at(0, 2)));
            case 'erase-fill':
              wrong['fill'] = 'white';
            case 'first-half-only' || 'second-half-only':
              final input = at(y, id == 'first-half-only' ? 0 : 1);
              wrong['fill'] = .5;
              if (input['rotation'] != null) {
                wrong['rotation'] = input['rotation'];
              }
            case 'hold-dot':
              wrong['dot'] = at(1, 0)['dot'];
            case 'double-step' || 'reverse-step':
              wrong['dot'] = _corners[
                  (_corners.indexOf(at(1, 0)['dot']! as String) +
                          (id == 'double-step' ? 2 : 3)) %
                      4];
            case 'freeze-dots':
              wrong['dots'] = at(y, x == 0 ? 1 : x - 1)['dots'];
            case 'union-not-intersection':
              wrong = setRays(wrong, [...rays(at(y, 0)), ...rays(at(y, 1))]);
            case 'first-exclusive':
              wrong = setRays(
                wrong,
                rays(at(y, 0)).where((v) => !rays(at(y, 1)).contains(v)),
              );
            case 'second-exclusive':
              wrong = setRays(
                wrong,
                rays(at(y, 1)).where((v) => !rays(at(y, 0)).contains(v)),
              );
            case 'copy-example-location':
              wrong['dot'] = at(0, 1)['dot'];
            case 'average-fill':
              wrong['fill'] = .5;
            case 'restart-cycle':
              wrong['arrow'] = at(0, 0)['arrow'];
            case 'take-half-turn':
              wrong['arrow'] = _arrows[
                  (_arrows.indexOf(at(1, 0)['arrow']! as String) + 2) % 4];
            case 'repeat-above':
              final key = pattern == 'arrow-column' ? 'arrow' : 'dot';
              wrong[key] = at(y - 1, x)[key];
            case 'copy-middle-form':
              wrong['form'] = at(1, 0)['form'];
            case 'repeat-neighbor' || 'repeat-adjacent':
              final key = pattern == 'outline-latin'
                  ? 'form'
                  : pattern == 'size-latin'
                      ? 'size'
                      : 'dot';
              wrong[key] = at(y, x == 0 ? 1 : x - 1)[key];
            case 'repeat-row-start' || 'copy-row-start':
              final key = pattern == 'outline-latin'
                  ? 'form'
                  : pattern == 'size-latin'
                      ? 'size'
                      : 'dot';
              wrong[key] = at(y, 0)[key];
            case 'add-sequence-step':
              wrong['dots'] =
                  2 * (at(y, 1)['dots']! as int) - (at(y, 0)['dots']! as int);
            case 'copy-second':
              wrong['dots'] = at(y, 1)['dots'];
            case 'subtract-inputs':
              wrong['dots'] =
                  ((at(y, 1)['dots']! as int) - (at(y, 0)['dots']! as int))
                      .abs();
            case 'use-smallest-step':
              wrong['line'] = ((at(y, 1)['line']! as num) +
                      (at(0, 1)['line']! as num) -
                      (at(0, 0)['line']! as num)) %
                  360;
            case 'copy-first-row-diagonal':
              wrong['line'] = at(0, 1)['line'];
            case 'freeze-edge-count':
              wrong['edgeLines'] = at(y, x == 0 ? 1 : x - 1)['edgeLines'];
            default:
              throw StateError(id);
          }
          figures.add(wrong);
        }
      } on Object {
        if (fixed) rethrow;
        continue;
      }
      if (figures.any(
        (a) =>
            a.values.contains(null) ||
            ['dots', 'edgeLines'].any(
              (k) => a[k] is int && ((a[k]! as int) < 0 || (a[k]! as int) > 5),
            ),
      )) {
        continue;
      }
      if (figures
              .map((f) => dataKey(canonicalSeriesItem(f, 0, mirror: false)))
              .toSet()
              .length !=
          4) {
        continue;
      }
      // A quarter-turn example may also fit reflection. Use starts for which
      // both operations agree, so no competing solver completes a wrong choice.
      if (!fixed &&
          pattern == 'corner-step' &&
          corners[0] % 2 != corners[1] % 2) {
        continue;
      }
      if (!fixed && pattern == 'ray-turn') {
        final from = at(0, 0)['line']! as int;
        final to = at(0, 1)['line'];
        if ([90, 180, 270, 360].any((axis) => (axis - from) % 360 == to)) {
          continue;
        }
      }
      if (!fixed &&
          pattern == 'size-dots' &&
          [...rawCells.whereType<Map<String, Object?>>(), ...figures].any(
            (a) => !_countableDots(a),
          )) {
        continue;
      }
      final slots = <String, Object?>{
        'answerText': _describe(answer, pattern),
        if (mistakes
            .any((m) => ['change-form', 'introduce-fourth-form'].contains(m)))
          'extraForm': extra,
      };
      final choices = List.generate(
        4,
        (i) => <String, Object?>{
          'text': fixed
              ? ((source['choices'] as List)[i] as Map)['text']
              : _describe(figures[i], pattern),
          'figure': figures[i],
          if (i == 0) 'correct': true else 'mistake': mistakes[i - 1],
        },
      );
      final cosmetic = [
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
      final form = answer['form'];
      final cosmetics = <String, Object?>{if (cosmetic) 'form': form};
      final ruleShown = <String, Object?>{
        ...shown,
        'cells': [
          for (final cell in rawCells)
            if (cell is Map)
              {
                for (final entry in cell.entries)
                  if (!cosmetic || entry.key != 'form')
                    entry.key as String: entry.value,
              }
            else
              cell,
        ],
      };
      if (!fixed &&
          pattern != 'corner-step' &&
          (choices.first['text']! as String).length >
              choices
                  .skip(1)
                  .map((c) => (c['text']! as String).length)
                  .reduce(max)) {
        continue;
      }
      final raw = <String, Object?>{
        'index': index,
        if (fixed) 'source': source['id'],
        'slots': slots,
        'figureSpec': shown,
        'choices': choices,
        'ruleKey': 'pending',
        'signature': 'pending',
        'cosmetics': cosmetics,
      };
      final before = parseVariants({
        'variants': [raw],
      }).single;
      final v = parseVariants({
        'variants': [
          {...raw, 'signature': canonicalSignature(before)},
        ],
      }).single;
      return RuleResult(
        variant: v,
        ruleParams: {
          'pattern': pattern,
          'shown': ruleShown,
        },
        cosmetics: cosmetics,
      );
    }
    throw StateError('$name: no valid noncolliding draw');
  }
}

String _describe(Map<String, Object?> a, String pattern) {
  String cap(String s) => '${s[0].toUpperCase()}${s.substring(1)}';
  const words = ['zero', 'one', 'two', 'three', 'four', 'five'];
  const directions = [
    'up',
    'upper-right',
    'right',
    'lower-right',
    'down',
    'lower-left',
    'left',
    'upper-left',
  ];
  String count(String key, String label) =>
      '${words[a[key]! as int]} $label${a[key] == 1 ? '' : 's'}';
  final outline = [
    if (a['size'] != null) '${a['size']}',
    if (a['fill'] != null)
      switch (a['fill']) {
        .5 => 'half-filled',
        _ => '${a['fill']}',
      },
    '${a['form']}',
  ].join(' ');
  final rays = [
    if (a['line'] != null) a['line']! as num,
    if (a['lines'] != null) ...(a['lines']! as List).cast<num>(),
  ]..sort();
  final rayWords = rays.map((r) => directions[r ~/ 45]).toList();
  final rayText = rays.isEmpty
      ? ''
      : rays.length == 1
          ? 'only the ${rayWords.single} ray'
          : 'rays ${rayWords.take(rayWords.length - 1).join(', ')} '
              'and ${rayWords.last}';
  return switch (pattern) {
    'ray-turn' ||
    'form-ray' =>
      '${cap(outline)} with line pointing ${rayWords.single}',
    'ray-union' ||
    'ray-intersection' ||
    'sized-ray-union' =>
      '${cap(outline)} with $rayText',
    'corner-step' ||
    'corner-reflection' ||
    'corner-grid' =>
      '${cap(outline)} with dot at ${a['dot']}',
    'size-dots' || 'dot-sum' => '${cap(outline)} with ${count('dots', 'dot')}',
    'size-transfer' => '${cap(outline)}; ${count('dots', 'dot')}; '
        '${count('edgeLines', 'edge line')}',
    'arrow-column' => 'Arrow pointing ${a['arrow']}',
    'growing-turn' => 'Line pointing ${rayWords.single}',
    'fill-union' => a['fill'] == .5
        ? '${switch (a['rotation'] ?? 0) {
            0 => 'Bottom',
            90 => 'Left',
            180 => 'Top',
            _ => 'Right'
          }}-half-filled ${a['form']}'
        : 'Fully ${a['fill']} ${a['form']}',
    _ => cap(outline),
  };
}

// At the matrix painter's 18px base radius. Triangles and stars have narrow
// interiors; cap counts before dots crowd each other or the outline.
bool _countableDots(Map<String, Object?> a) {
  final count = a['dots']! as int;
  final small = a['size'] == 'small';
  return count <=
      switch (a['form']) {
        'triangle' => small ? 2 : 3,
        'star' => small ? 1 : 2,
        'pentagon' => small ? 3 : 5,
        _ => small ? 4 : 5,
      };
}
