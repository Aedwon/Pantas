import '../../../model.dart';
import '../../signature.dart';
import '../solver.dart';

const groupingMistakes = <String, List<String>>{
  'side-count-easy': [
    'equal-length-instead-of-count',
    'proportion-instead-of-count',
    'orientation-instead-of-count',
  ],
  'outline-symmetry': ['boundary-type', 'equal-sides', 'side-count'],
  'center-cuts': ['fewest-lines', 'even-line-count', 'most-regions'],
  'dot-count': ['curved-outline', 'fewest-sides', 'uncommon-outline'],
  'boundary': ['equal-sides', 'different-side-count', 'elongated-form'],
  'side-count-medium': [
    'choose-endpoint',
    'choose-center',
    'choose-last',
    'rotated-outline',
    'regularity',
    'proportions',
  ],
  'line-count': ['choose-first', 'choose-central', 'miscount-repeated-cuts'],
  'specific-rule': [
    'overbroad-side-minimum',
    'common-symmetry',
    'common-closure',
  ],
  'region-parity': [
    'line-is-region',
    'line-parity-is-region-parity',
    'three-lines-three-regions',
  ],
  'side-parity': ['regularity', 'unequal-lengths', 'exactly-four-not-even'],
  'dot-parity': ['fewest-dots', 'most-dots', 'outline-side-count'],
  'polygon-replacement': [
    'keep-circle',
    'change-curved-shape',
    'change-internal-marks',
  ],
  'side-double-dots': ['equal-lengths', 'unequal-lengths', 'most-dots'],
};

/// Drawn symmetry, not a name-based assumption about arbitrary polygons.
const _symmetric = {
  'square',
  'rectangle',
  'rhombus',
  'triangle',
  'circle',
  'pentagon',
  'hexagon',
};
const _sides = {
  'square': 4,
  'rectangle': 4,
  'rhombus': 4,
  'parallelogram': 4,
  'triangle': 3,
  'pentagon': 5,
  'hexagon': 6,
};
const _regular = {'square', 'rhombus', 'triangle', 'pentagon', 'hexagon'};

class GroupingSolver implements FigureSolver {
  GroupingSolver(this.pattern);
  final String pattern;
  @override
  String get kind => 'shape-row';
  List<Map<String, Object?>> row(Map<String, Object?> f) =>
      (f['shapes']! as List).cast<Map<String, Object?>>();
  int count(Map<String, Object?> x, String k) => (x[k] as int?) ?? 0;
  String get operation => switch (pattern) {
        'side-count-easy' || 'side-count-medium' => 'side-count',
        _ => pattern,
      };
  int answer(List<Map<String, Object?>> a) {
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
    final values = a.map(property).toList();
    final odd = [
      for (var i = 0; i < a.length; i++)
        if (values.where((x) => x == values[i]).length == 1) i,
    ];
    final common = values
        .toSet()
        .where((x) => values.where((y) => y == x).length == a.length - 1);
    if (odd.length != 1 || common.length != 1) {
      throw const FormatException('no unique odd position');
    }
    // Boolean rules name a required feature shared by three figures.
    // The exception must lack it, rather than reverse the stated grouping.
    if (values.first is bool &&
        (common.single != true || values[odd.single] != false)) {
      throw const FormatException('reversed majority direction');
    }
    return odd.single;
  }

  @override
  bool fits(
    Map<String, Object?> shown,
    Map<String, Object?> candidate,
    Map<String, Object?> query,
  ) {
    if (shown['kind'] != kind || query['operation'] != operation) return false;
    try {
      final a = row(shown);
      if (a.length != (pattern == 'dot-count' ? 5 : 4)) return false;
      if (pattern == 'polygon-replacement') {
        return a.where((x) => x['form'] == 'circle').length == 1 &&
            a.where((x) => _sides.containsKey(x['form'])).length == 3 &&
            candidate.keys.length == 1 &&
            _sides.containsKey(candidate['form']);
      }
      if (pattern == 'specific-rule') {
        final sides = a.map((x) => _sides[x['form']]).toList();
        final common = sides
            .toSet()
            .where((x) => sides.where((y) => y == x).length == 3)
            .toList();
        return common.length == 1 &&
            candidate['value'] == '${common.single}' &&
            (candidate['text'] == '${common.single} sides' ||
                (common.single == 3 && candidate['text'] == 'Three sides'));
      }
      return candidate['value'] == '${answer(a) + 1}';
    } on Object {
      return false;
    }
  }

  List<int> wrongPositions(Variant v) {
    final a = row(v.figureSpec!);
    final correct = answer(a);
    final ids = groupingMistakes[pattern]!;
    final selected = <int>[];
    final active = pattern == 'side-count-medium'
        ? ((v.slots['profile'] ?? 0) == 0 ? ids.take(3) : ids.skip(3))
        : ids;
    for (final id in active) {
      var pool = [
        for (var i = 0; i < a.length; i++)
          if (i != correct && !selected.contains(i)) i,
      ];
      bool filter(int i) {
        final x = a[i];
        final form = x['form'];
        return switch (id) {
          'equal-length-instead-of-count' ||
          'equal-sides' ||
          'regularity' ||
          'equal-lengths' =>
            _regular.contains(form),
          'proportion-instead-of-count' ||
          'elongated-form' ||
          'unequal-lengths' ||
          'proportions' =>
            ['rectangle', 'parallelogram'].contains(form),
          'orientation-instead-of-count' ||
          'rotated-outline' =>
            ['rhombus', 'parallelogram'].contains(form),
          'choose-endpoint' || 'choose-first' => i == 0,
          'choose-center' || 'choose-central' => i == 1,
          'choose-last' => i == 3,
          'boundary-type' || 'curved-outline' => form == 'circle',
          'side-count' => form == 'triangle',
          'uncommon-outline' => ['pentagon', 'hexagon', 'blob'].contains(form),
          'different-side-count' =>
            _sides[form] != _sides[a[selected.first]['form']],
          'even-line-count' => count(x, 'lines').isEven,
          'line-is-region' => count(x, 'lines') == 1,
          'line-parity-is-region-parity' => count(x, 'lines') == 2,
          'three-lines-three-regions' => count(x, 'lines') == 3,
          'exactly-four-not-even' || 'outline-side-count' => form == 'hexagon',
          _ => true,
        };
      }

      pool = pool.where(filter).toList();
      if ([
        'fewest-lines',
        'most-regions',
        'fewest-dots',
        'most-dots',
        'fewest-sides',
      ].contains(id)) {
        int metric(int i) => id == 'fewest-sides'
            ? (_sides[a[i]['form']] ?? 99)
            : count(a[i], id.contains('dots') ? 'dots' : 'lines');
        final all = [for (var i = 0; i < a.length; i++) metric(i)]..sort();
        final extreme = id.startsWith('fewest') ? all.first : all.last;
        if (id == 'most-dots' && all.where((x) => x == extreme).length != 1) {
          throw const FormatException('most-dots requires a unique maximum');
        }
        pool = pool.where((i) => metric(i) == extreme).toList()
          ..sort((x, y) {
            final c = metric(x).compareTo(metric(y));
            return c == 0 ? x.compareTo(y) : c;
          });
        if (['most-dots', 'most-regions'].contains(id)) {
          pool = pool.reversed.toList();
        }
      }
      if (pool.isEmpty) throw FormatException('no target for $id');
      selected.add(pool.first);
    }
    return selected;
  }

  Map<String, Object?> mistake(Variant v, String id) {
    if (pattern == 'polygon-replacement') {
      return switch (id) {
        'keep-circle' => {'form': 'circle'},
        'change-curved-shape' => {'form': 'blob'},
        _ => {'form': 'circle', 'dots': 2},
      };
    }
    if (pattern == 'specific-rule') {
      return switch (id) {
        'overbroad-side-minimum' => {
            'text': 'At least three sides',
            'value': 'minimum-3',
          },
        'common-symmetry' => {
            'text': 'At least one reflection axis',
            'value': 'symmetry',
          },
        _ => {'text': 'A closed boundary', 'value': 'closed'},
      };
    }
    final ids = groupingMistakes[pattern]!;
    final active = pattern == 'side-count-medium'
        ? ((v.slots['profile'] ?? 0) == 0 ? ids.take(3) : ids.skip(3)).toList()
        : ids;
    final i = wrongPositions(v)[active.indexOf(id)];
    return {'text': positionText(v, i), 'value': '${i + 1}'};
  }

  String positionText(Variant v, int i) {
    if (v.source == null) return 'Figure ${i + 1}';
    final suffix = v.source!.substring(v.source!.length - 4);
    const texts = <String, List<String>>{
      '0001': ['Square', 'Rectangle', 'Rhombus', 'Triangle'],
      '0002': ['Circle', 'Square', 'Triangle', 'Blob'],
      '0003': [
        'The leftmost circle',
        'The second circle from the left',
        'The third circle from the left',
        'The rightmost circle',
      ],
      '0004': ['Square', 'Triangle', 'Circle', 'Pentagon', 'Hexagon'],
      '0005': ['Square', 'Triangle', 'Rectangle', 'Circle'],
      '0006': [
        'First figure from the left',
        'Second figure from the left',
        'Third figure from the left',
        'Fourth figure from the left',
      ],
      '0008': [
        'The leftmost figure',
        'Second figure from the left',
        'Third figure from the left',
        'The rightmost figure',
      ],
      '0009': [
        'The leftmost circle',
        'Second circle from the left',
        'Third circle from the left',
        'The rightmost circle',
      ],
      '0012': [
        'The leftmost circle',
        'Second circle from the left',
        'Third circle from the left',
        'The rightmost circle',
      ],
      '0013': ['Square', 'Rectangle', 'Hexagon', 'Pentagon'],
      '0015': ['Square', 'Rectangle', 'Circle', 'Hexagon'],
      '0018': ['Square', 'Rectangle', 'Hexagon', 'Triangle'],
    };
    return texts[suffix]![i];
  }

  @override
  Map<String, Object?> ruleParams(ProblemType t, Variant v) => {
        'operation': operation,
        'shapes': (row(v.figureSpec!).map(dataKey).toList()..sort()),
        if (pattern == 'polygon-replacement')
          'replacement': v.slots['replacement'],
      };
  @override
  List<String> validateCosmetics(ProblemType t, Variant v) =>
      v.cosmetics.isEmpty ? [] : ['unexpected cosmetics'];
  @override
  List<String> validateRanges(ProblemType t, Variant v) {
    final errors = <String>[];
    final a = row(v.figureSpec!);
    if (a.length != (pattern == 'dot-count' ? 5 : 4)) errors.add('row length');
    for (final x in [
      ...a,
      ...v.choices.where((c) => c.figure != null).map((c) => c.figure!),
    ]) {
      if (!(t.params['forms']! as List).contains(x['form'])) {
        errors.add('form outside params');
      }
      if (x.keys
          .any((k) => !['form', 'dots', 'lines', 'through'].contains(k))) {
        errors.add('unsupported field');
      }
      for (final key in ['dots', 'lines']) {
        if (count(x, key) < 0 || count(x, key) > 4) {
          errors.add('$key outside 0..4');
        }
      }
      if (!['centre', 'off'].contains(x['through'] ?? 'centre')) {
        errors.add('invalid through');
      }
    }
    if (['center-cuts', 'line-count', 'region-parity'].contains(pattern) &&
        a.any((x) => x['form'] != 'circle')) {
      errors.add('circle required');
    }
    if (pattern == 'center-cuts' &&
        a.any(
          (x) =>
              count(x, 'lines') < ((x['through'] ?? 'centre') == 'off' ? 2 : 1),
        )) {
      errors.add('unreadable cuts');
    }
    return errors;
  }
}
