/// Cube-net contracts, version 1.
/// Params: cells are six distinct edge-connected squares in the 0..5 grid.
/// Valid tasks use the 11 free foldable hexominoes; validity-test uses the
/// remaining 24. overlap-medium uses a four-square row plus either a two-deep
/// branch (profile 0) or two same-side flaps (profile 1), with repeated
/// normals.
/// strip-first-overlap uses one straight six-square strip.
/// Labels A..F are cosmetics, consistently attached to cells and query refs.
/// No rotations, mirrors, translations or relabelings add signature capacity.
/// Slots operation, face, faces, upFace describe the question, not the figure.
/// ruleParams are operation, cells, and queried cell coordinates (face/faces/
/// upFace), plus profile. Cell order is preserved, labels are excluded.
///
/// Opposite tasks compare folded normals. Each wrong face has an orthogonal
/// normal. Named errors select distinct side faces, with geometric priorities:
/// easy profile 0: upper neighbor, left neighbor, lower neighbor, then closest
/// graph distance and row/column order. Profile 1: attached support, next strip
/// side, other branch support, ordered by graph distance then row/column.
/// medium: farthest same-column side, farthest remaining side, closest side.
/// hard profile 0: skip the first fold, then ascending graph distance;
/// profile 1 requires perpendicular front and up faces. Mistakes select
/// lower, left, right neighbors, excluding upFace, then closest remaining side.
/// top-and-shadow: right, upper, lower side neighbors (closest fallback), with
/// square, unequal rectangle, unequal diamond respectively. nonadjacent:
/// upper, right, lower side neighbors (closest fallback).
/// A directional priority without that neighbor falls back to graph distance.
/// Hard profile 0 excludes graph-distance-one faces when possible.
///
/// Adjacent-relation queries distinct orthogonal normals. Mistakes are
/// opposite, overlap, corner-only. Validity-test mistakes are count-only,
/// connectedness-only, symmetry-only. overlap profile 0 mistakes are row-is-
/// rigid, six-means-valid, branch-removes-sides; profile 1 mistakes are
/// opposite
/// strip pairs 0/2 and 1/3 called overlaps, then row-cannot-wrap.
/// strip-first-overlap asks from the first endpoint: answer distance 4;
/// mistakes stop-one-fold-early (3), wait-until-last (5),
/// opposite-means-overlap
/// (2). all-opposites compares three opposite pairs; mistakes
/// pair-alphabetical-
/// neighbors, pair-flat-ends, mix-side-pairs use index pairings 01/23/45,
/// 05/12/34, 03/14/25. Reject a draw if any is the true matching or duplicated.
/// three-at-corner uses sorted cell-index triple (a,b,c), one per
/// opposite pair.
/// Mistakes opposite-side-pair=(a,b,opposite(b)), opposite-end-pair=
/// (a,b,opposite(a)), unchecked-third-pair=(b,c,opposite(c)).
/// Draws whose named mistakes coincide or become correct are rejected.
library;

import 'dart:convert';
import 'dart:math';

import '../../check/signature.dart';
import '../../model.dart';
import '../../rule_key.dart';
import '../rule.dart';
import 'sources.dart';

const netPatterns = [
  'opposite-easy',
  'overlap-medium',
  'strip-first-overlap',
  'adjacent-relation',
  'validity-test',
  'opposite-medium',
  'all-opposites',
  'top-and-shadow',
  'opposite-hard',
  'three-at-corner',
  'nonadjacent',
];
const _sourceGroups = [
  [1, 15],
  [2, 16],
  [7],
  [8],
  [9],
  [11],
  [13],
  [14],
  [17, 18],
  [19],
  [20],
];
const _mistakes = [
  [
    'stop-at-first-fold',
    'left-arm-is-top',
    'stop-at-lower-neighbor',
    'attached-face-is-opposite',
    'pick-next-strip-side',
    'pick-branch-support',
  ],
  [
    'row-is-rigid',
    'six-means-valid',
    'branch-removes-sides',
    'opposite-A-C-is-overlap',
    'opposite-B-D-is-overlap',
    'row-cannot-wrap',
  ],
  ['stop-one-fold-early', 'wait-until-last', 'opposite-means-overlap'],
  [
    'flat-distance-means-opposite',
    'meeting-means-overlap',
    'flat-corner-means-only-corner',
  ],
  ['count-only', 'connectedness-only', 'symmetry-only'],
  ['flat-column-ends-opposite', 'flat-distance', 'adjacent-is-opposite'],
  ['pair-alphabetical-neighbors', 'pair-flat-ends', 'mix-side-pairs'],
  ['stop-at-side', 'neighbor-plus-unequal-box', 'neighbor-plus-slanted-view'],
  [
    'stop-early',
    'flat-path-distance',
    'pair-path-ends',
    'lower-neighbor-is-back',
    'hidden-left-is-back',
    'right-arm-is-back',
  ],
  ['opposite-side-pair', 'opposite-end-pair', 'unchecked-third-pair'],
  ['flat-top-neighbor', 'sideways-fold-separates', 'lower-neighbor'],
];
typedef _Point = (int, int);
typedef _Vector = (int, int, int);
_Vector _neg(_Vector a) => (-a.$1, -a.$2, -a.$3);
_Vector _cross(_Vector a, _Vector b) => (
      a.$2 * b.$3 - a.$3 * b.$2,
      a.$3 * b.$1 - a.$1 * b.$3,
      a.$1 * b.$2 - a.$2 * b.$1
    );

class _Geometry {
  _Geometry(this.points) {
    final basis = <int, (_Vector, _Vector)>{0: ((1, 0, 0), (0, 1, 0))};
    final pending = [0];
    for (var cursor = 0; cursor < pending.length; cursor++) {
      final i = pending[cursor];
      final (right, down) = basis[i]!;
      final normal = _cross(right, down);
      for (var j = 0; j < 6; j++) {
        final delta =
            (points[j].$1 - points[i].$1, points[j].$2 - points[i].$2);
        if (delta.$1.abs() + delta.$2.abs() != 1) continue;
        final next = switch (delta) {
          (0, 1) => (_neg(normal), down),
          (0, -1) => (normal, down),
          (1, 0) => (right, _neg(normal)),
          _ => (right, normal),
        };
        if (basis.containsKey(j)) {
          if (basis[j] != next) consistent = false;
        } else {
          basis[j] = next;
          pending.add(j);
        }
      }
    }
    if (basis.length != 6) throw const FormatException('disconnected');
    normals = [for (var i = 0; i < 6; i++) _cross(basis[i]!.$1, basis[i]!.$2)];
  }
  final List<_Point> points;
  late final List<_Vector> normals;
  bool consistent = true;
  bool get valid => consistent && normals.toSet().length == 6;
  int opposite(int a) => normals.indexOf(_neg(normals[a]));
  List<int> distances(int start) {
    final result = List.filled(6, -1)..[start] = 0;
    final todo = [start];
    for (var k = 0; k < todo.length; k++) {
      for (var j = 0; j < 6; j++) {
        final a = points[todo[k]];
        final b = points[j];
        if (result[j] < 0 && (a.$1 - b.$1).abs() + (a.$2 - b.$2).abs() == 1) {
          result[j] = result[todo[k]] + 1;
          todo.add(j);
        }
      }
    }
    return result;
  }
}

List<_Point> _normalize(Iterable<_Point> raw) {
  final a = raw.toList();
  final r = a.map((p) => p.$1).reduce(min);
  final c = a.map((p) => p.$2).reduce(min);
  return a.map((p) => (p.$1 - r, p.$2 - c)).toList()
    ..sort(
      (a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2),
    );
}

String _shapeKey(Iterable<_Point> points) {
  final forms = <String>[];
  for (final reflected in [false, true]) {
    var a = points.map((p) => (p.$1, reflected ? -p.$2 : p.$2)).toList();
    for (var turn = 0; turn < 4; turn++) {
      forms.add(_normalize(a).join(';'));
      a = a.map((p) => (-p.$2, p.$1)).toList();
    }
  }
  return (forms..sort()).first;
}

List<List<_Point>> _hexominoes() {
  var shapes = <String, List<_Point>>{
    '(0, 0)': [(0, 0)],
  };
  for (var size = 1; size < 6; size++) {
    final next = <String, List<_Point>>{};
    for (final a in shapes.values) {
      for (final p in a) {
        for (final step in [(-1, 0), (1, 0), (0, -1), (0, 1)]) {
          final q = (p.$1 + step.$1, p.$2 + step.$2);
          if (a.contains(q)) continue;
          final b = _normalize([...a, q]);
          next.putIfAbsent(_shapeKey(b), () => b);
        }
      }
    }
    shapes = next;
  }
  return shapes.values.toList();
}

final _allShapes = _hexominoes();
final _validShapes = _allShapes.where((a) => _Geometry(a).valid).toList();

class NetRule implements Rule {
  NetRule(this.pattern);
  final String pattern;
  @override
  String get name => 'net-$pattern';
  @override
  int get version => 1;
  @override
  RuleResult generate(ProblemType t, Random r, int index) {
    final group = netPatterns.indexOf(pattern);
    final fixed = index < t.mergedQuestions.length;
    final profile =
        fixed ? index : (_sourceGroups[group].length == 2 ? r.nextInt(2) : 0);
    final sourceNumber = _sourceGroups[group][profile];
    final source = (jsonDecode(netSources) as List)
        .cast<Map<String, dynamic>>()
        .singleWhere(
          (q) => (q['id'] as String)
              .endsWith(sourceNumber.toString().padLeft(4, '0')),
        );
    final labels = ['A', 'B', 'C', 'D', 'E', 'F'];
    for (var attempt = 0; attempt < 2000; attempt++) {
      List<_Point> cells;
      if (fixed) {
        cells = ((source['figureSpec'] as Map)['cells'] as List)
            .map((p) => ((p as List)[0] as int, p[1] as int))
            .toList();
      } else if (pattern == 'strip-first-overlap') {
        cells = [for (var i = 0; i < 6; i++) (0, i)];
      } else if (pattern == 'overlap-medium') {
        final first = r.nextInt(4);
        final second = r.nextInt(4);
        if (profile == 1 && first >= second) continue;
        cells = [
          for (var i = 0; i < 4; i++) (2, i),
          (1, first),
          if (profile == 0) (0, first) else (1, second),
        ];
      } else {
        final pool = pattern == 'validity-test'
            ? _allShapes.where((a) => !_Geometry(a).valid).toList()
            : _validShapes;
        cells = pool[r.nextInt(pool.length)];
      }
      final geometry = _Geometry(cells);
      if (pattern == 'overlap-medium' &&
          (geometry.valid || !geometry.consistent)) {
        continue;
      }
      final query = <String, Object?>{'operation': name, 'profile': profile};
      var face = r.nextInt(6);
      if (fixed) {
        face = switch (sourceNumber) {
          1 || 14 || 18 => 2,
          7 || 17 => 0,
          11 => 5,
          15 => 4,
          20 => 1,
          _ => 0
        };
      }
      if (pattern == 'strip-first-overlap') face = 0;
      if (![
        'overlap-medium',
        'validity-test',
        'adjacent-relation',
        'all-opposites',
        'three-at-corner',
      ].contains(pattern)) {
        query['face'] = labels[face];
      }
      if (pattern == 'opposite-hard' && profile == 1) {
        final candidates = [
          for (var j = 0; j < 6; j++)
            if (j != face && j != geometry.opposite(face)) j,
        ];
        query['upFace'] =
            fixed ? 'A' : labels[candidates[r.nextInt(candidates.length)]];
      }
      if (pattern == 'adjacent-relation' || pattern == 'three-at-corner') {
        List<int> refs;
        if (fixed) {
          refs = pattern == 'adjacent-relation' ? [0, 1] : [0, 1, 2];
        } else {
          final count = pattern == 'adjacent-relation' ? 2 : 3;
          refs = (List.generate(6, (i) => i)..shuffle(r)).take(count).toList()
            ..sort();
          if (refs.map((i) => geometry.normals[i]).any(
                (a) => refs.map((j) => geometry.normals[j]).contains(_neg(a)),
              )) {
            continue;
          }
        }
        query['faces'] = refs.map((i) => labels[i]).toList();
      }
      final answer = _answer(geometry, labels, query);
      final wrong = _wrong(geometry, labels, query);
      if (wrong.toSet().length != 3 || wrong.contains(answer)) continue;
      final ids = _mistakes[group]
          .skip(_mistakes[group].length == 6 ? 3 * profile : 0)
          .take(3)
          .toList();
      final sourceChoices =
          (source['choices'] as List).cast<Map<String, dynamic>>();
      final actualChoices = fixed
          ? sourceChoices.map((c) => c['text'] as String).toList()
          : [answer, ...wrong];
      final shown = fixed
          ? Map<String, Object?>.from(source['figureSpec'] as Map)
          : <String, Object?>{
              'kind': 'cube-net',
              'cells': [
                for (final p in cells) [p.$1, p.$2],
              ],
              'labels': labels,
            };
      query['stemText'] = fixed ? source['stem'] : _stem(query);
      query['explanationText'] =
          fixed ? source['explanation'] : _explanation(query, answer);
      final cosmetics = <String, Object?>{'labels': labels};
      Object coords(Object? v) => v is List
          ? v.map(coords).toList()
          : [
              cells[labels.indexOf(v! as String)].$1,
              cells[labels.indexOf(v as String)].$2,
            ];
      final parameters = <String, Object?>{
        'operation': name,
        'cells': shown['cells'],
        'profile': profile,
        for (final key in ['face', 'faces', 'upFace'])
          if (query.containsKey(key)) key: coords(query[key]),
      };
      final map = <String, Object?>{
        'index': index,
        if (fixed) 'source': source['id'],
        'slots': query,
        'figureSpec': shown,
        'choices': [
          {'correct': true, 'text': actualChoices[0]},
          for (var k = 0; k < 3; k++)
            {
              'mistake': ids[k],
              'text': actualChoices[k + 1],
              'slots': {
                'noteText': fixed
                    ? sourceChoices[k + 1]['rationale']
                    : _note(pattern, k, wrong[k]),
              },
            },
        ],
        'ruleKey': taskRuleKey(name, parameters),
        'cosmetics': cosmetics,
        'signature': 'pending',
      };
      final v = parseVariants({
        'variants': [map],
      }).single;
      return RuleResult(
        variant: parseVariants({
          'variants': [
            {...map, 'signature': canonicalSignature(v)},
          ],
        }).single,
        ruleParams: parameters,
        cosmetics: cosmetics,
      );
    }
    throw StateError('$name cannot draw three distinct mistakes');
  }

  String _answer(_Geometry g, List<String> l, Map<String, Object?> q) {
    if (pattern == 'validity-test') {
      return 'Track whether all folded faces are distinct.';
    }
    if (pattern == 'overlap-medium') {
      if (q['profile'] == 0) return 'Two squares fold onto the same face.';
      final pairs = [
        for (var a = 0; a < 6; a++)
          for (var b = a + 1; b < 6; b++)
            if (g.normals[a] == g.normals[b]) (a, b),
      ];
      if (pairs.length != 1) return 'invalid overlap count';
      return '${l[pairs.single.$1]} and ${l[pairs.single.$2]} overlap.';
    }
    if (pattern == 'strip-first-overlap') return l[4];
    if (pattern == 'adjacent-relation') return 'They share an edge.';
    if (pattern == 'all-opposites') {
      return [
        for (var i = 0; i < 6; i++)
          if (i < g.opposite(i)) '${l[i]} and ${l[g.opposite(i)]}',
      ].join('; ');
    }
    if (pattern == 'three-at-corner') return (q['faces']! as List).join(', ');
    final answer = l[g.opposite(l.indexOf(q['face']! as String))];
    return pattern == 'top-and-shadow' ? '$answer; a square' : answer;
  }

  List<String> _wrong(_Geometry g, List<String> l, Map<String, Object?> q) {
    if (pattern == 'overlap-medium') {
      return q['profile'] == 0
          ? [
              'The four-square row cannot bend at its edges.',
              'Six connected squares must form a cube.',
              'The two-square branch leaves no side faces.',
            ]
          : [
              '${l[0]} and ${l[2]} overlap.',
              '${l[1]} and ${l[3]} overlap.',
              'The row cannot form four side faces.',
            ];
    }
    if (pattern == 'validity-test') {
      return [
        'Check only whether six squares are present.',
        'Check only whether all squares are connected.',
        'Check only whether the pattern is symmetric.',
      ];
    }
    if (pattern == 'strip-first-overlap') return [l[3], l[5], l[2]];
    if (pattern == 'adjacent-relation') {
      return [
        'They become opposite faces.',
        'They overlap on the same face.',
        'They meet only at one corner.',
      ];
    }
    if (pattern == 'all-opposites') {
      return [
        for (final pairing in [
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
        ])
          pairing.map((p) => '${l[p[0]]} and ${l[p[1]]}').join('; '),
      ];
    }
    if (pattern == 'three-at-corner') {
      final a = (q['faces']! as List).cast<String>().map(l.indexOf).toList();
      return [
        for (final triple in [
          [a[0], a[1], g.opposite(a[1])],
          [a[0], a[1], g.opposite(a[0])],
          [a[1], a[2], g.opposite(a[2])],
        ])
          triple.map((i) => l[i]).join(', '),
      ];
    }
    final target = l.indexOf(q['face']! as String);
    final opposite = g.opposite(l.indexOf(q['face']! as String));
    final d = g.distances(target);
    final pool = [
      for (var i = 0; i < 6; i++)
        if (i != target && i != opposite && l[i] != q['upFace']) i,
    ];
    final chosen = <int>[];
    int planar(int a, int b) => g.points[a].$1 != g.points[b].$1
        ? g.points[a].$1.compareTo(g.points[b].$1)
        : g.points[a].$2.compareTo(g.points[b].$2);
    final directions = switch (pattern) {
      'opposite-easy' when q['profile'] == 0 => [(-1, 0), (0, -1), (1, 0)],
      'opposite-hard' when q['profile'] == 1 => [(1, 0), (0, -1), (0, 1)],
      'top-and-shadow' => [(0, 1), (-1, 0), (1, 0)],
      'nonadjacent' => [(-1, 0), (0, 1), (1, 0)],
      _ => <_Point>[],
    };
    for (var k = 0; k < 3; k++) {
      final options = pool.where((i) => !chosen.contains(i)).toList()
        ..sort((a, b) => d[a] != d[b] ? d[a].compareTo(d[b]) : planar(a, b));
      var pick = options.first;
      if (directions.isNotEmpty) {
        final wanted = (
          g.points[target].$1 + directions[k].$1,
          g.points[target].$2 + directions[k].$2
        );
        for (final i in options) {
          if (g.points[i] == wanted) pick = i;
        }
      } else if (pattern == 'opposite-medium' && k < 2) {
        final far = options
            .where((i) => k == 1 || g.points[i].$2 == g.points[target].$2)
            .toList()
          ..sort((a, b) => d[a] != d[b] ? d[b].compareTo(d[a]) : planar(a, b));
        if (far.isNotEmpty) pick = far.first;
      } else if (pattern == 'opposite-hard') {
        final later = options.where((i) => d[i] > 1);
        if (later.isNotEmpty) pick = later.first;
      }
      chosen.add(pick);
    }
    return [
      for (var k = 0; k < 3; k++)
        pattern == 'top-and-shadow'
            ? '${l[chosen[k]]}; ${[
                'a square',
                'a rectangle with unequal sides',
                'a diamond with unequal diagonals',
              ][k]}'
            : l[chosen[k]],
    ];
  }

  String _stem(Map<String, Object?> q) {
    final f = q['face'];
    return switch (pattern) {
      'overlap-medium' => q['profile'] == 0
          ? 'The six squares are folded along their shared edges. '
              'Why does this pattern fail to make a cube?'
          : 'Why can this six-square pattern not form a cube?',
      'validity-test' => 'A student proposes this six-square pattern as a cube '
          'net. Which test decides whether it works?',
      'strip-first-overlap' =>
        'Fold the strip along each shared edge to try to make a '
            'cube. Which square first overlaps $f?',
      'adjacent-relation' =>
        'Fold the labeled net into a cube. Which relationship '
            'holds between ${(q['faces']! as List)[0]} and '
            '${(q['faces']! as List)[1]}?',
      'all-opposites' => 'After folding the labeled net, which list gives the '
          'three pairs of opposite faces?',
      'three-at-corner' =>
        'Fold the net into a cube. Which set of three faces can '
            'meet at one corner?',
      'top-and-shadow' =>
        'The labeled net folds into a cube. With $f resting flat '
            'on the table, parallel light shines vertically '
            'downward. Which face is at the top, and what is the '
            'shadow outline?',
      'nonadjacent' => 'After this net folds into a cube, face $f is painted '
          'red. Which unpainted face does not share an edge with '
          '$f?',
      'opposite-hard' when q['profile'] == 1 =>
        'The folded cube has $f facing front and ${q['upFace']} '
            'facing up. Which face is at the back?',
      _ => 'Fold the labeled net into a cube. Which face is opposite $f?',
    };
  }

  String _explanation(Map<String, Object?> q, String answer) =>
      switch (pattern) {
        'validity-test' =>
          'A cube needs one square in each of six face directions. '
              'Following the folds tests whether every square reaches '
              'a different direction without conflict.',
        'overlap-medium' => q['profile'] == 0
            ? 'The four-square row wraps around the cube. Two squares '
                'reach the same face direction, leaving another face '
                'open.'
            : '$answer The four-square row wraps around the sides. '
                'Both attached squares close the same end.',
        'strip-first-overlap' =>
          'Each fold turns the next face by 90 degrees. Four turns '
              'return to the first face direction, so $answer overlaps '
              '${q['face']}.',
        'adjacent-relation' =>
          'The two faces point in perpendicular directions after '
              'folding. They share an edge on the cube.',
        'all-opposites' =>
          'Track each face through the folds. The faces in each '
              'pair point in opposite directions across the cube: '
              '$answer.',
        'three-at-corner' =>
          'The three selected faces include one face from each '
              'opposite pair. They meet at one corner: $answer.',
        'top-and-shadow' =>
          'The face across from ${q['face']} becomes the top. '
              'Parallel vertical rays project the cube as a square. '
              'The answer is $answer.',
        _ => 'Track the face directions through each fold. $answer '
            'faces across the cube from ${q['face']}. Opposite faces '
            'do not share an edge.',
      };
  String _note(String pattern, int k, String wrong) => switch (pattern) {
        'validity-test' => switch (k) {
            0 => 'This checks only the number of faces. Six squares match '
                'a cube. Check that every folded face reaches a '
                'different direction.',
            1 => 'This checks only connectedness. A net must be one '
                'piece. Check for overlap after folding.',
            _ => 'This uses flat symmetry as proof. A balanced pattern '
                'can look promising. Check all folded face directions.',
          },
        'overlap-medium' => 'This uses a feature of the flat strip instead of '
            'tracking the attached squares. The row attracts '
            'attention. Check which folded faces reach the same '
            'direction.',
        'adjacent-relation' => switch (k) {
            0 => 'This assumes the faces point in opposite directions. '
                'Flat placement can be misleading. Track where each '
                'face points after folding.',
            1 => 'This confuses meeting with overlap. Folding brings '
                'faces together. Check whether they face in the same '
                'direction.',
            _ => 'This counts only a corner contact. The free edges can '
                'look as though they cannot meet. Check the full edge '
                'after folding.',
          },
        'strip-first-overlap' => switch (k) {
            0 => 'This stops one fold early. The fourth square looks like '
                'the end of a loop. Count directions from the first '
                'square.',
            1 => 'This waits until the last square. The end looks like '
                'the closing face. Check for overlap after each fold.',
            _ => 'This confuses opposite with overlapping. Two turns face '
                'away from the start. Check whether both faces point '
                'the same way.',
          },
        'all-opposites' =>
          'This pairs faces by flat positions instead of folded '
              'directions. The grouping looks orderly on paper. Check '
              'that each pair faces across the cube.',
        'three-at-corner' =>
          'This includes two opposite faces. The three labels look '
              'like a nearby group. Check every pair before selecting '
              'a corner.',
        'top-and-shadow' =>
          'This stops at a side face or uses a slanted outline. '
              'The flat neighbor looks like a top face. Track the '
              'opposite face and the vertical rays.',
        _ => 'This selects the side face $wrong. Its position in the '
            'flat net can look opposite. Track the folded direction '
            'and check whether it shares an edge with the named '
            'face.',
      };
}
