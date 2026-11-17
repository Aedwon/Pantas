/// Shape-row contracts. Params: forms uses the nine supported forms; counts
/// are 0..4. No cosmetic attributes are added. Each row has four shapes,
/// except dot-count with five. Odd-row answers are 1-based text positions.
/// Source profiles reserve 0006 and 0008 for the medium side-count rule.
///
/// Drawn reflection symmetry table: square, rectangle, rhombus, triangle,
/// circle, pentagon, hexagon: yes; parallelogram, blob: no.
/// side-count: three equal side counts (3..6), one different polygon.
/// outline-symmetry: three symmetric outlines, one blob.
/// center-cuts: circle lines 1..4 through center, one off-center with 2..4.
/// dot-count: four equal counts 0..4, one unequal, mixed outlines.
/// boundary: three polygons, one circle/blob.
/// line-count: three equal circle line counts 0..4, one different.
/// specific-rule: three equal polygon side counts, one different symmetric
/// polygon. Answer exact side count; broad minimum, symmetry and closure fail
/// to exclude exactly one. No boundary marks.
/// region-parity: three circles with 1..4 center lines, one uncut circle.
/// side-parity: three even-sided polygons, one triangle/pentagon.
/// dot-parity: three even counts 0/2/4, one odd 1/3, mixed outlines.
/// polygon-replacement: three polygons and circle, replace circle by polygon;
/// wrong replacements circle, blob, circle with two dots.
/// side-double-dots: three polygons with sides=2*dots, one failing polygon.
///
/// Named positional mistakes select distinct matching figures, excluding the
/// actual answer and earlier selections. A draw with no matching selection is
/// rejected. Predicates: equal-lengths/equal-sides/regularity select regular
/// polygons or rhombus; proportion/elongated/unequal-lengths select rectangle
/// or parallelogram; orientation/rotated select rhombus/parallelogram;
/// boundary-type/curved select circle; fewest-sides selects minimum polygon
/// side count; uncommon-outline selects pentagon/hexagon/blob; side-count
/// selects triangle; exactly-four selects a quadrilateral; most-dots selects
/// maximum dots; fewest-dots selects minimum dots; outline-side-count selects
/// hexagon; fewest-lines selects minimum lines; even-line-count selects even
/// lines; most-regions selects maximum lines; region mistakes select 1,2,3
/// center lines respectively. Positional mistakes choose remaining positions
/// 1/2/4 for the medium source profile and 1/2/remaining for line count.
/// All extrema are computed over the full shown row. Center-cuts requires
/// unique minima and maxima; other ties use remaining positions in row order
/// (maximum ties in reverse row order).
/// Region-parity needs line counts 1,2,3 to retain all three source mistakes.
library;

import 'dart:convert';
import 'dart:math';

import '../../check/signature.dart';
import '../../model.dart';
import '../rule.dart';
import 'sources.dart';

const groupingPatterns = [
  'side-count-easy',
  'outline-symmetry',
  'center-cuts',
  'dot-count',
  'boundary',
  'side-count-medium',
  'line-count',
  'specific-rule',
  'region-parity',
  'side-parity',
  'dot-parity',
  'polygon-replacement',
  'side-double-dots',
];
const _sourceIds = [1, 2, 3, 4, 5, 6, 9, 10, 12, 13, 15, 17, 18];
const _sides = {
  'triangle': 3,
  'square': 4,
  'rectangle': 4,
  'rhombus': 4,
  'parallelogram': 4,
  'pentagon': 5,
  'hexagon': 6,
};
const _quads = ['square', 'rectangle', 'rhombus', 'parallelogram'];
const _symmetric = [
  'square',
  'rectangle',
  'rhombus',
  'triangle',
  'circle',
  'pentagon',
  'hexagon',
];
const _regular = ['square', 'rhombus', 'triangle', 'pentagon', 'hexagon'];

class GroupingRule implements Rule {
  GroupingRule(this.pattern);
  final String pattern;
  @override
  String get name => 'group-$pattern';
  @override
  int get version => 1;
  @override
  RuleResult generate(ProblemType t, Random r, int index) {
    final sources =
        (jsonDecode(groupingSources) as List).cast<Map<String, dynamic>>();
    final sourceNumber = pattern == 'side-count-medium' && index == 1
        ? 8
        : _sourceIds[groupingPatterns.indexOf(pattern)];
    final source = sources.singleWhere(
      (q) =>
          (q['id'] as String).endsWith(sourceNumber.toString().padLeft(4, '0')),
    );
    final fixed = index < t.mergedQuestions.length;
    T pick<T>(List<T> a) => a[r.nextInt(a.length)];
    final forms = (t.params['forms']! as List).cast<String>();
    final polygons = forms.where(_sides.containsKey).toList();
    final operation =
        pattern.startsWith('side-count-') ? 'side-count' : pattern;
    for (var attempt = 0; attempt < 1000; attempt++) {
      final profile =
          pattern == 'side-count-medium' ? (fixed && index == 0 ? 0 : 1) : 0;
      final common = r.nextInt(5);
      final other = pick([
        for (var i = 0; i <= 4; i++)
          if (i != common) i,
      ]);
      final side = pattern == 'side-count-easy' ? 4 : pick([3, 4, 5, 6]);
      final commonForms = polygons.where((f) => _sides[f] == side).toList();
      final differentForms = polygons.where((f) => _sides[f] != side).toList();
      final evenForms = [..._quads, 'hexagon'];
      final replacement = fixed ? 'hexagon' : pick(polygons);
      List<Map<String, Object?>> shapes;
      Map<String, Object?> shape(
        String f, {
        int? dots,
        int? lines,
        String? through,
      }) =>
          {
            'form': f,
            if (dots != null) 'dots': dots,
            if (lines != null) 'lines': lines,
            if (through != null) 'through': through,
          };
      if (fixed) {
        shapes = ((source['figureSpec'] as Map)['shapes'] as List)
            .map((x) => Map<String, Object?>.from(x as Map))
            .toList();
      } else {
        shapes = switch (pattern) {
          'side-count-easy' || 'side-count-medium' => [
              for (var i = 0; i < 3; i++) shape(pick(commonForms)),
              shape(pick(differentForms)),
            ],
          'outline-symmetry' => [
              for (var i = 0; i < 3; i++) shape(pick(_symmetric)),
              shape('blob'),
            ],
          'center-cuts' => [
              for (var i = 0; i < 3; i++)
                shape('circle', lines: 1 + r.nextInt(4)),
              shape('circle', lines: 2 + r.nextInt(3), through: 'off'),
            ],
          'dot-count' => [
              for (var i = 0; i < 4; i++) shape(pick(forms), dots: common),
              shape(pick(forms), dots: other),
            ],
          'boundary' || 'polygon-replacement' => [
              for (var i = 0; i < 3; i++) shape(pick(polygons)),
              shape(
                pattern == 'polygon-replacement'
                    ? 'circle'
                    : pick(['circle', 'blob']),
              ),
            ],
          'line-count' => [
              for (var i = 0; i < 3; i++) shape('circle', lines: common),
              shape('circle', lines: other),
            ],
          'specific-rule' => [
              for (var i = 0; i < 3; i++)
                shape(pick(commonForms.where(_symmetric.contains).toList())),
              shape(pick(differentForms.where(_symmetric.contains).toList())),
            ],
          'region-parity' => [
              for (var i = 0; i < 3; i++)
                shape('circle', lines: 1 + r.nextInt(4)),
              shape('circle', lines: 0),
            ],
          'side-parity' => [
              for (var i = 0; i < 3; i++) shape(pick(evenForms)),
              shape(pick(['triangle', 'pentagon'])),
            ],
          'dot-parity' => [
              for (var i = 0; i < 3; i++)
                shape(pick(forms), dots: pick([0, 2, 4])),
              shape(pick(forms), dots: pick([1, 3])),
            ],
          'side-double-dots' => [
              for (var i = 0; i < 3; i++)
                for (final f in [pick(evenForms)])
                  shape(f, dots: _sides[f]! ~/ 2),
              shape(pick(polygons), dots: r.nextInt(5)),
            ],
          _ => throw StateError(pattern),
        }
          ..shuffle(r);
      }
      if (!fixed &&
          ['side-count-easy', 'boundary', 'side-count-medium']
              .contains(pattern) &&
          shapes.map(dataKey).toSet().length != shapes.length) {
        continue;
      }
      if (pattern == 'dot-parity' &&
          shapes.where((x) => x['form'] == 'hexagon').length != 1) {
        continue;
      }
      int count(Map<String, Object?> x, String k) => (x[k] as int?) ?? 0;
      Object? property(Map<String, Object?> x) => switch (operation) {
            'side-count' => _sides[x['form']],
            'outline-symmetry' => _symmetric.contains(x['form']),
            'center-cuts' => (x['through'] ?? 'centre') == 'centre',
            'dot-count' => count(x, 'dots'),
            'boundary' => _sides.containsKey(x['form']),
            'line-count' => count(x, 'lines'),
            'region-parity' => count(x, 'lines') > 0,
            'side-parity' => (_sides[x['form']] ?? -1).isEven,
            'dot-parity' => count(x, 'dots').isEven,
            'side-double-dots' => _sides[x['form']] == 2 * count(x, 'dots'),
            _ => null,
          };
      var answer = -1;
      if (!['polygon-replacement', 'specific-rule'].contains(pattern)) {
        final values = shapes.map(property).toList();
        final odd = [
          for (var i = 0; i < values.length; i++)
            if (values.where((x) => x == values[i]).length == 1) i,
        ];
        if (odd.length != 1 ||
            !values.toSet().any(
                  (x) =>
                      values.where((y) => y == x).length == shapes.length - 1,
                )) {
          continue;
        }
        answer = odd.single;
      }
      final ids = t.mistakes.map((m) => m.id).toList();
      final active = pattern == 'side-count-medium'
          ? (profile == 0 ? ids.take(3) : ids.skip(3)).toList()
          : ids;
      final wrong = <int>[];
      for (final id in active) {
        if (['polygon-replacement', 'specific-rule'].contains(pattern)) break;
        var candidates = [
          for (var i = 0; i < shapes.length; i++)
            if (i != answer && !wrong.contains(i)) i,
        ];
        candidates = candidates.where((i) {
          final f = shapes[i]['form'];
          return switch (id) {
            'equal-length-instead-of-count' ||
            'equal-sides' ||
            'regularity' ||
            'equal-lengths' =>
              _regular.contains(f),
            'proportion-instead-of-count' ||
            'elongated-form' ||
            'unequal-lengths' ||
            'proportions' =>
              ['rectangle', 'parallelogram'].contains(f),
            'orientation-instead-of-count' ||
            'rotated-outline' =>
              ['rhombus', 'parallelogram'].contains(f),
            'choose-endpoint' || 'choose-first' => i == 0,
            'choose-center' || 'choose-central' => i == 1,
            'choose-last' => i == 3,
            'boundary-type' || 'curved-outline' => f == 'circle',
            'side-count' => f == 'triangle',
            'uncommon-outline' => ['pentagon', 'hexagon', 'blob'].contains(f),
            'different-side-count' =>
              _sides[f] != _sides[shapes[wrong.first]['form']],
            'even-line-count' => count(shapes[i], 'lines').isEven,
            'line-is-region' => count(shapes[i], 'lines') == 1,
            'line-parity-is-region-parity' => count(shapes[i], 'lines') == 2,
            'three-lines-three-regions' => count(shapes[i], 'lines') == 3,
            'exactly-four-not-even' || 'outline-side-count' => f == 'hexagon',
            _ => true,
          };
        }).toList();
        if ([
          'fewest-lines',
          'most-regions',
          'fewest-dots',
          'most-dots',
          'fewest-sides',
        ].contains(id)) {
          int value(int i) => id == 'fewest-sides'
              ? (_sides[shapes[i]['form']] ?? 99)
              : count(shapes[i], id.contains('dots') ? 'dots' : 'lines');
          final all = [for (var i = 0; i < shapes.length; i++) value(i)];
          final target =
              id.startsWith('fewest') ? all.reduce(min) : all.reduce(max);
          if ((id == 'most-dots' ||
                  (pattern == 'center-cuts' &&
                      ['fewest-lines', 'most-regions'].contains(id))) &&
              all.where((x) => x == target).length != 1) {
            candidates = [];
            break;
          }
          candidates = candidates.where((i) => value(i) == target).toList()
            ..sort((a, b) {
              final d = value(a).compareTo(value(b));
              return d == 0 ? a.compareTo(b) : d;
            });
          if (['most-dots', 'most-regions'].contains(id)) {
            candidates = candidates.reversed.toList();
          }
        }
        if (candidates.isEmpty) break;
        wrong.add(candidates.first);
      }
      if (!['polygon-replacement', 'specific-rule'].contains(pattern) &&
          wrong.length != 3) {
        continue;
      }
      final figure = <String, Object?>{'kind': 'shape-row', 'shapes': shapes};
      final sourceChoices =
          (source['choices'] as List).cast<Map<String, dynamic>>();
      final positions = [answer, ...wrong];
      final choices = <Map<String, Object?>>[];
      for (var c = 0; c < 4; c++) {
        final special =
            pattern == 'polygon-replacement' || pattern == 'specific-rule';
        final form = c == 0
            ? replacement
            : c == 1
                ? 'circle'
                : c == 2
                    ? 'blob'
                    : 'circle';
        final sideCount = fixed ? 3 : side;
        final text = fixed
            ? sourceChoices[c]['text']! as String
            : special
                ? (pattern == 'polygon-replacement'
                    ? (c == 0
                        ? '${form[0].toUpperCase()}${form.substring(1)}'
                        : c == 1
                            ? 'Another circle'
                            : c == 2
                                ? 'An irregular curved blob'
                                : 'A circle with two dots')
                    : (c == 0
                        ? '$sideCount sides'
                        : c == 1
                            ? 'At least three sides'
                            : c == 2
                                ? 'At least one reflection axis'
                                : 'A closed boundary'))
                : 'Figure ${positions[c] + 1}';
        choices.add({
          if (c == 0) 'correct': true,
          if (c > 0) 'mistake': active[c - 1],
          'text': text,
          if (pattern == 'line-count' && c > 0)
            'slots': {'lineCount': count(shapes[positions[c]], 'lines')},
          if (pattern == 'polygon-replacement')
            'figure': {'form': form, if (c == 3) 'dots': 2},
          if (pattern != 'polygon-replacement')
            'value': pattern == 'specific-rule'
                ? (c == 0
                    ? '$sideCount'
                    : c == 1
                        ? 'minimum-3'
                        : c == 2
                            ? 'symmetry'
                            : 'closed')
                : '${positions[c] + 1}',
        });
      }
      // Source profiles order their wrong answers by the documented mistakes.
      final slots = <String, Object?>{
        'operation': operation,
        if (pattern == 'side-count-medium') 'profile': profile,
        if (pattern == 'polygon-replacement') 'replacement': replacement,
        'stem': fixed
            ? source['stem']
            : pattern == 'polygon-replacement'
                ? 'Which replacement for the circle makes every outline '
                    'straight-sided?'
                : pattern == 'specific-rule'
                    ? 'Which rule groups exactly three outlines by side count?'
                    : _stems[pattern],
        'explanation': fixed
            ? source['explanation']
            : pattern == 'specific-rule'
                ? 'Three outlines each have $side sides. '
                    'The remaining outline has a different side count.'
                : pattern == 'polygon-replacement'
                    ? 'The replacement has straight sides. '
                        'All four outlines are then polygons.'
                    : 'Figure ${answer + 1} breaks the shared rule. '
                        '${_reasons[pattern]}',
      };
      final params = <String, Object?>{
        'operation': operation,
        'shapes': (shapes.map(dataKey).toList()..sort()),
        if (pattern == 'polygon-replacement') 'replacement': replacement,
      };
      final variant = parseVariants({
        'variants': [
          {
            'index': index,
            if (fixed) 'source': source['id'],
            'slots': slots,
            'figureSpec': figure,
            'choices': choices,
            'ruleKey': 'pending',
            'cosmetics': <String, Object?>{},
            'signature': 'pending',
          }
        ],
      }).single;
      return RuleResult(
        variant: parseVariants({
          'variants': [
            {...variant.toMap(), 'signature': canonicalSignature(variant)},
          ],
        }).single,
        ruleParams: params,
        cosmetics: {},
      );
    }
    throw StateError('$name could not draw noncolliding mistakes');
  }
}

const _stems = {
  'side-count-easy':
      'Group the figures by number of sides. Which does not belong?',
  'side-count-medium':
      'Three outlines match in side count. Which outline breaks that count?',
  'outline-symmetry': 'Which outline has no reflection axis?',
  'center-cuts':
      'Which circle has internal lines that do not pass through its center?',
  'dot-count': 'Considering internal dot counts, which figure does not belong?',
  'boundary': 'Which outline has a curved boundary?',
  'line-count': 'Group these figures by the number of internal lines. '
      'Which does not belong?',
  'region-parity':
      'Which circle does not have an even number of enclosed regions?',
  'side-parity': 'Which outline does not have an even number of sides?',
  'dot-parity': 'Which figure does not have an even number of dots?',
  'side-double-dots':
      'In three figures, the side count is twice the internal dot count. '
          'Which breaks this relation?',
};
const _reasons = {
  'side-count-easy': 'The other three outlines have the same number of sides.',
  'side-count-medium':
      'The other three outlines have the same number of sides.',
  'outline-symmetry': 'Its reflected halves do not match across any axis.',
  'center-cuts': 'Its internal lines meet below the center.',
  'dot-count': 'Its dot count differs from the common dot count.',
  'boundary': 'Its outline curves instead of using only straight sides.',
  'line-count': 'Its internal line count differs from the common line count.',
  'region-parity': 'An uncut circle has one region. One is odd.',
  'side-parity': 'Its side count is odd.',
  'dot-parity': 'Its dot count is odd.',
  'side-double-dots': 'Its side count is not twice its dot count.',
};
