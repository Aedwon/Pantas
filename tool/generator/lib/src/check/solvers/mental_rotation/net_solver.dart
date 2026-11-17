import '../../../model.dart';
import '../solver.dart';

const netMistakes = <String, List<String>>{
  'opposite-easy': [
    'stop-at-first-fold',
    'left-arm-is-top',
    'stop-at-lower-neighbor',
    'attached-face-is-opposite',
    'pick-next-strip-side',
    'pick-branch-support',
  ],
  'overlap-medium': [
    'row-is-rigid',
    'six-means-valid',
    'branch-removes-sides',
    'opposite-A-C-is-overlap',
    'opposite-B-D-is-overlap',
    'row-cannot-wrap',
  ],
  'strip-first-overlap': [
    'stop-one-fold-early',
    'wait-until-last',
    'opposite-means-overlap',
  ],
  'adjacent-relation': [
    'flat-distance-means-opposite',
    'meeting-means-overlap',
    'flat-corner-means-only-corner',
  ],
  'validity-test': ['count-only', 'connectedness-only', 'symmetry-only'],
  'opposite-medium': [
    'flat-column-ends-opposite',
    'flat-distance',
    'adjacent-is-opposite',
  ],
  'all-opposites': [
    'pair-alphabetical-neighbors',
    'pair-flat-ends',
    'mix-side-pairs',
  ],
  'top-and-shadow': [
    'stop-at-side',
    'neighbor-plus-unequal-box',
    'neighbor-plus-slanted-view',
  ],
  'opposite-hard': [
    'stop-early',
    'flat-path-distance',
    'pair-path-ends',
    'lower-neighbor-is-back',
    'hidden-left-is-back',
    'right-arm-is-back',
  ],
  'three-at-corner': [
    'opposite-side-pair',
    'opposite-end-pair',
    'unchecked-third-pair',
  ],
  'nonadjacent': [
    'flat-top-neighbor',
    'sideways-fold-separates',
    'lower-neighbor',
  ],
};

typedef Cell = (int, int);

/// Signed axes propagate a complete orientation around each fold. Conflicting
/// cycles are rejected, rather than accepting a spanning tree of a rectangle.
class FoldedNet {
  FoldedNet(Map<String, Object?> figure) {
    cells = (figure['cells']! as List).map((p) {
      final a = p as List;
      return (a[0]! as int, a[1]! as int);
    }).toList();
    labels = (figure['labels']! as List).cast<String>();
    if (cells.length != 6 ||
        cells.toSet().length != 6 ||
        labels.length != 6 ||
        labels.toSet().length != 6) {
      throw const FormatException('six distinct labeled squares required');
    }
    frames[0] = (1, 2, 3);
    final queue = [0];
    for (var k = 0; k < queue.length; k++) {
      final i = queue[k];
      final (r, d, n) = frames[i]!;
      for (var j = 0; j < 6; j++) {
        final dr = cells[j].$1 - cells[i].$1;
        final dc = cells[j].$2 - cells[i].$2;
        if (dr.abs() + dc.abs() != 1) continue;
        final next = switch ((dr, dc)) {
          (0, 1) => (-n, d, r),
          (0, -1) => (n, d, -r),
          (1, 0) => (r, -n, d),
          _ => (r, n, -d),
        };
        if (frames.containsKey(j)) {
          if (frames[j] != next) consistent = false;
        } else {
          frames[j] = next;
          queue.add(j);
        }
      }
    }
    if (frames.length != 6) throw const FormatException('disconnected net');
  }
  late final List<Cell> cells;
  late final List<String> labels;
  final frames = <int, (int, int, int)>{};
  bool consistent = true;
  int normal(int i) => frames[i]!.$3;
  bool get valid =>
      consistent && frames.values.map((f) => f.$3).toSet().length == 6;
  int opposite(int i) =>
      List.generate(6, (j) => j).singleWhere((j) => normal(j) == -normal(i));
  int index(Object? face) => labels.indexOf(face! as String);
  List<int> distances(int start) {
    final dist = List.filled(6, 99)..[start] = 0;
    for (var pass = 0; pass < 6; pass++) {
      for (var i = 0; i < 6; i++) {
        for (var j = 0; j < 6; j++) {
          if ((cells[i].$1 - cells[j].$1).abs() +
                      (cells[i].$2 - cells[j].$2).abs() ==
                  1 &&
              dist[j] > dist[i] + 1) {
            dist[j] = dist[i] + 1;
          }
        }
      }
    }
    return dist;
  }

  List<int> sides(int target) => [
        for (var j = 0; j < 6; j++)
          if (normal(j).abs() != normal(target).abs()) j,
      ];
}

class NetSolver implements FigureSolver {
  NetSolver(this.pattern);
  final String pattern;
  @override
  String get kind => 'cube-net';
  List<String> active(Map<String, Object?> q) {
    final all = netMistakes[pattern]!;
    return all.length == 6
        ? all.skip((q['profile']! as int) * 3).take(3).toList()
        : all;
  }

  List<int> wrongFaces(FoldedNet n, Map<String, Object?> q) {
    final target = n.index(q['face']);
    final distances = n.distances(target);
    final pool = n.sides(target)..remove(n.index(q['upFace'] ?? q['face']));
    int spatial(int a, int b) {
      final r = n.cells[a].$1.compareTo(n.cells[b].$1);
      return r != 0 ? r : n.cells[a].$2.compareTo(n.cells[b].$2);
    }

    int near(int a, int b) {
      final d = distances[a].compareTo(distances[b]);
      return d != 0 ? d : spatial(a, b);
    }

    if (pattern == 'opposite-hard' && q['profile'] == 0) {
      if (distances.toSet().length != 6 || distances[n.opposite(target)] != 3) {
        throw const FormatException('hard path requires six successive stops');
      }
      return [
        for (final distance in [2, 4, 5]) distances.indexOf(distance),
      ];
    }
    final selected = <int>[];
    final profile = q['profile']! as int;
    final directions = switch (pattern) {
      'opposite-easy' when profile == 0 => [(-1, 0), (0, -1), (1, 0)],
      'opposite-hard' when profile == 1 => [(1, 0), (0, -1), (0, 1)],
      'top-and-shadow' => [(0, 1), (-1, 0), (1, 0)],
      'nonadjacent' => [(-1, 0), (0, 1), (1, 0)],
      _ => <Cell>[],
    };
    for (var k = 0; k < 3; k++) {
      final remaining = pool.where((i) => !selected.contains(i)).toList()
        ..sort(near);
      if (remaining.isEmpty) {
        throw const FormatException('missing side mistake');
      }
      var candidate = remaining.first;
      if (directions.isNotEmpty) {
        final p = (
          n.cells[target].$1 + directions[k].$1,
          n.cells[target].$2 + directions[k].$2
        );
        final i = n.cells.indexOf(p);
        if (pattern == 'opposite-hard' && !remaining.contains(i)) {
          throw const FormatException(
            'hard directional mistake needs its neighbor',
          );
        }
        if (remaining.contains(i)) candidate = i;
      } else if (pattern == 'opposite-medium' && k < 2) {
        final eligible = remaining
            .where((i) => k == 1 || n.cells[i].$2 == n.cells[target].$2)
            .toList();
        if (eligible.isNotEmpty) {
          eligible.sort((a, b) {
            final d = distances[b].compareTo(distances[a]);
            return d != 0 ? d : spatial(a, b);
          });
          candidate = eligible.first;
        }
      } else if (pattern == 'opposite-hard') {
        final beyond = remaining.where((i) => distances[i] > 1).toList();
        if (beyond.isNotEmpty) candidate = beyond.first;
      }
      selected.add(candidate);
    }
    return selected;
  }

  String pairText(FoldedNet n, List<List<int>> pairs) =>
      pairs.map((p) => '${n.labels[p[0]]} and ${n.labels[p[1]]}').join('; ');
  List<List<int>> pairs(FoldedNet n) => [
        for (var i = 0; i < 6; i++)
          if (i < n.opposite(i)) [i, n.opposite(i)],
      ];
  String answer(FoldedNet n, Map<String, Object?> q) {
    if (pattern == 'validity-test') {
      return 'Track whether all folded faces are distinct.';
    }
    if (pattern == 'overlap-medium') {
      if (q['profile'] == 0) return 'Two squares fold onto the same face.';
      final overlaps = [
        for (var i = 0; i < 6; i++)
          for (var j = i + 1; j < 6; j++)
            if (n.normal(i) == n.normal(j)) [i, j],
      ];
      final p = overlaps.single;
      return '${n.labels[p[0]]} and ${n.labels[p[1]]} overlap.';
    }
    if (pattern == 'strip-first-overlap') {
      final dist = n.distances(n.index(q['face']));
      return n.labels[dist.indexOf(4)];
    }
    if (pattern == 'adjacent-relation') return 'They share an edge.';
    if (pattern == 'all-opposites') return pairText(n, pairs(n));
    if (pattern == 'three-at-corner') {
      return (q['faces']! as List).cast<String>().join(', ');
    }
    final face = n.labels[n.opposite(n.index(q['face']))];
    return pattern == 'top-and-shadow' ? '$face; a square' : face;
  }

  bool admissible(FoldedNet n, Map<String, Object?> q) {
    if (pattern == 'validity-test') return !n.valid;
    if (pattern == 'overlap-medium') {
      if (n.valid || !n.consistent) return false;
      // The strip occupies indexes 0..3, with both branches above it.
      if (!List.generate(4, (i) => n.cells[i])
          .every((p) => p.$1 == n.cells[0].$1)) {
        return false;
      }
      if (!List.generate(3, (i) => n.cells[i + 1].$2 == n.cells[i].$2 + 1)
          .every((x) => x)) {
        return false;
      }
      if (q['profile'] == 0) {
        return n.cells[4].$1 == n.cells[0].$1 - 1 &&
            n.cells[5] == (n.cells[4].$1 - 1, n.cells[4].$2);
      }
      return n.cells[4].$1 == n.cells[0].$1 - 1 &&
          n.cells[5].$1 == n.cells[4].$1 &&
          n.cells[4].$2 < n.cells[5].$2;
    }
    if (pattern == 'strip-first-overlap') {
      final dist = n.distances(n.index(q['face']));
      return n.consistent &&
          dist.toSet().length == 6 &&
          (n.cells.map((p) => p.$1).toSet().length == 1 ||
              n.cells.map((p) => p.$2).toSet().length == 1);
    }
    if (!n.valid) return false;
    if (pattern == 'adjacent-relation' || pattern == 'three-at-corner') {
      final refs = (q['faces']! as List).map(n.index).toList();
      if (refs.length != (pattern == 'adjacent-relation' ? 2 : 3) ||
          refs.any((i) => i < 0) ||
          refs.toSet().length != refs.length) {
        return false;
      }
      if (pattern == 'adjacent-relation') {
        final a = n.cells[refs[0]];
        final b = n.cells[refs[1]];
        if ((a.$1 - b.$1).abs() != 1 || (a.$2 - b.$2).abs() != 1) return false;
      }
      return refs.map((i) => n.normal(i).abs()).toSet().length == refs.length;
    }
    if (pattern == 'opposite-hard' && q['profile'] == 1) {
      final front = n.index(q['face']);
      final upFace = q['upFace'];
      if (front < 0 || upFace is! String) return false;
      final up = n.index(upFace);
      return up >= 0 && n.normal(front).abs() != n.normal(up).abs();
    }
    return pattern == 'all-opposites' || n.index(q['face']) >= 0;
  }

  @override
  bool fits(
    Map<String, Object?> shown,
    Map<String, Object?> candidate,
    Map<String, Object?> query,
  ) {
    if (shown['kind'] != kind || query['operation'] != 'net-$pattern') {
      return false;
    }
    try {
      final net = FoldedNet(shown);
      if (!admissible(net, query)) return false;
      if (pattern == 'three-at-corner') {
        final refs = (candidate['text']! as String)
            .split(', ')
            .map(net.labels.indexOf)
            .toList();
        return refs.length == 3 &&
            refs.every((i) => i >= 0) &&
            refs.map((i) => net.normal(i).abs()).toSet().length == 3;
      }
      return candidate['text'] == answer(net, query);
    } on Object {
      return false;
    }
  }

  Map<String, Object?> mistake(Variant v, String id) {
    final n = FoldedNet(v.figureSpec!);
    final q = v.slots;
    final k = active(q).indexOf(id);
    if (k < 0) throw FormatException('inactive mistake $id');
    String text;
    if (pattern == 'overlap-medium') {
      text = q['profile'] == 0
          ? [
              'The four-square row cannot bend at its edges.',
              'Six connected squares must form a cube.',
              'The two-square branch leaves no side faces.',
            ][k]
          : [
              '${n.labels[0]} and ${n.labels[2]} overlap.',
              '${n.labels[1]} and ${n.labels[3]} overlap.',
              'The row cannot form four side faces.',
            ][k];
    } else if (pattern == 'validity-test') {
      text = [
        'Check only whether six squares are present.',
        'Check only whether all squares are connected.',
        'Check only whether the pattern is symmetric.',
      ][k];
    } else if (pattern == 'adjacent-relation') {
      text = [
        'They become opposite faces.',
        'They overlap on the same face.',
        'They meet only at one corner.',
      ][k];
    } else if (pattern == 'strip-first-overlap') {
      final dist = n.distances(n.index(q['face']));
      text = n.labels[dist.indexOf([3, 5, 2][k])];
    } else if (pattern == 'all-opposites') {
      text = pairText(
        n,
        [
          [
            [0, 1],
            [2, 3],
            [4, 5],
          ],
          [
            [0, 5],
            [1, 2],
            [3, 4],
          ],
          [
            [0, 3],
            [1, 4],
            [2, 5],
          ]
        ][k],
      );
    } else if (pattern == 'three-at-corner') {
      final a = (q['faces']! as List).map(n.index).toList();
      final triple = [
        [a[0], a[1], n.opposite(a[1])],
        [a[0], a[1], n.opposite(a[0])],
        [a[1], a[2], n.opposite(a[2])],
      ][k];
      text = triple.map((i) => n.labels[i]).join(', ');
    } else {
      text = n.labels[wrongFaces(n, q)[k]];
      if (pattern == 'top-and-shadow') {
        text = '$text; ${[
          'a square',
          'a rectangle with unequal sides',
          'a diamond with unequal diagonals',
        ][k]}';
      }
    }
    return {'text': text};
  }

  @override
  Map<String, Object?> ruleParams(ProblemType type, Variant v) {
    final n = FoldedNet(v.figureSpec!);
    Object coords(Object? refs) => refs is List
        ? refs.map(coords).toList()
        : [n.cells[n.index(refs)].$1, n.cells[n.index(refs)].$2];
    return {
      'operation': v.slots['operation'],
      'cells': v.figureSpec!['cells'],
      'profile': v.slots['profile'],
      for (final key in ['face', 'faces', 'upFace'])
        if (v.slots.containsKey(key)) key: coords(v.slots[key]),
    };
  }

  @override
  List<String> validateCosmetics(ProblemType type, Variant v) {
    final n = FoldedNet(v.figureSpec!);
    return canonicalJson(v.cosmetics) == canonicalJson({'labels': n.labels})
        ? []
        : ['labels differ from cosmetics'];
  }

  @override
  List<String> validateRanges(ProblemType type, Variant v) {
    try {
      final n = FoldedNet(v.figureSpec!);
      final errors = <String>[];
      if (n.cells.any((p) => p.$1 < 0 || p.$1 > 5 || p.$2 < 0 || p.$2 > 5)) {
        errors.add('coordinates outside 0..5');
      }
      if (n.labels
          .toSet()
          .difference({'A', 'B', 'C', 'D', 'E', 'F'}).isNotEmpty) {
        errors.add('labels outside A..F');
      }
      if (v.figureSpec!.keys
          .any((k) => !['kind', 'cells', 'labels'].contains(k))) {
        errors.add('unsupported field');
      }
      if (v.slots['operation'] != 'net-$pattern' ||
          !(type.params['profiles']! as List).contains(v.slots['profile'])) {
        errors.add('query outside params');
      }
      if (!admissible(n, v.slots)) errors.add('inadmissible net or query');
      return errors;
    } on Object {
      return ['malformed net or query'];
    }
  }
}
