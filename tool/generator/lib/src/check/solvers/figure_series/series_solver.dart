import '../../../model.dart';
import '../../signature.dart';
import '../solver.dart';

const _sizes = ['small', 'medium', 'large'];
const _corners = ['top-left', 'top-right', 'bottom-right', 'bottom-left'];
const _arrows = ['up', 'right', 'down', 'left'];
const _forms = ['square', 'circle', 'triangle', 'pentagon', 'star'];

/// Independent implementation of the documented series contracts. No rule
/// import.
class SeriesSolver implements FigureSolver {
  SeriesSolver(this.pattern, {this.doubleCounts = false});
  final bool doubleCounts;
  final String pattern;
  @override
  String get kind => 'figure-series';

  List<Map<String, Object?>> _items(Map<String, Object?> shown) =>
      (shown['items']! as List).cast<Map<String, Object?>>();
  int _count(Map<String, Object?> item, String key) => (item[key] as int?) ?? 0;
  num _angle(Map<String, Object?> item) => (item['line']! as num) % 360;
  Object _fill(Map<String, Object?> item) => item['fill'] ?? 'white';
  Object _size(Map<String, Object?> item) => item['size'] ?? 'large';

  Map<String, Object?> _state(List<Map<String, Object?>> a, int i) {
    final result = Map<String, Object?>.of(a.first);
    final first = a.first;
    final second = a[1];
    int growingCount(String key, int step) => doubleCounts
        ? _count(first, key) * (1 << step)
        : _count(first, key) + step;
    switch (pattern) {
      case 'ray-step':
        result['line'] =
            (_angle(first) + i * ((_angle(second) - _angle(first)) % 360)) %
                360;
      case 'binary-fill':
        result['fill'] = i.isEven ? _fill(first) : _fill(second);
      case 'size-fill':
        result['size'] =
            _sizes[(_sizes.indexOf(_size(first) as String) + i) % 3];
        result['fill'] = i.isEven ? _fill(first) : _fill(second);
      case 'two-arrow-turns':
        result['arrow'] =
            _arrows[(_arrows.indexOf(first['arrow']! as String) + i) % 4];
      case 'dots-size':
        result['dots'] = growingCount('dots', i);
        result['size'] = i.isEven ? _size(first) : _size(second);
      case 'arrow-alternation':
        result['arrow'] = a[i % 2]['arrow'];
      case 'two-fill-steps':
        final start = ((first['fill']! as num) * 4).toInt() - 1;
        result['fill'] = ((start + i) % 3 + 1) / 4;
      case 'outline-triple':
        result['form'] = a[i % 3]['form'];
      case 'four-tracks':
        result['form'] = a[i % 2]['form'];
        result['size'] = _size(a[i % 2]);
        result['line'] = (_angle(first) + 90 * i) % 360;
        result['edgeLines'] = growingCount('edgeLines', i);
      case 'corner-edge-count':
        result['dot'] =
            _corners[(_corners.indexOf(first['dot']! as String) + i) % 4];
        result['edgeLines'] = growingCount('edgeLines', i);
      case 'double-fill':
        final phase = a.take(3).map((x) => x['fill']).toList().indexOf('white');
        result['fill'] = i % 3 == phase ? 'white' : 'black';
      case 'transfer-count':
        result['dots'] = growingCount('dots', i);
        result['edgeLines'] = _count(first, 'edgeLines') - i;
      case 'interleaved-count':
        result['form'] = a[i % 2]['form'];
        result['dots'] =
            i.isEven ? growingCount('dots', i ~/ 2) : _count(second, 'dots');
      case 'fill-ray-dots':
        result['fill'] = _fill(a[i % 2]);
        result['line'] = _angle(a[i % 2]);
        result['dots'] = growingCount('dots', i);
      case 'size-corner-ray':
        result['size'] = _size(a[i % 2]);
        result['line'] = _angle(a[i % 2]);
        result['dot'] =
            _corners[(_corners.indexOf(first['dot']! as String) + i) % 4];
      default:
        throw FormatException('unknown series pattern $pattern');
    }
    return result;
  }

  Map<String, Object?> _normal(Map<String, Object?> a) => {
        'form': a['form'],
        'size': a['size'] ?? 'large',
        'fill': switch (a['fill']) {
          'white' || null => 0,
          'black' => 1,
          final Object x => x
        },
        'dots': a['dots'] ?? 0,
        'edgeLines': a['edgeLines'] ?? 0,
        if (a['line'] != null) 'line': (a['line']! as num) % 360,
        if (a['dot'] != null) 'dot': a['dot'],
        if (a['arrow'] != null) 'arrow': a['arrow'],
        'rotation': (a['rotation'] as num?) ?? 0,
      };
  bool _same(Map<String, Object?> a, Map<String, Object?> b) =>
      dataKey(_normal(a)) == dataKey(_normal(b));

  @override
  bool fits(
    Map<String, Object?> shown,
    Map<String, Object?> candidate,
    Map<String, Object?> query,
  ) {
    if (shown['kind'] != kind || shown['items'] is! List) return false;
    try {
      final a = _items(shown);
      if (!_lengths.contains(a.length)) return false;
      final horizon = query['horizon'] ?? 1;
      if (horizon !=
          (['two-arrow-turns', 'two-fill-steps'].contains(pattern) ? 2 : 1)) {
        return false;
      }
      if ((shown['blank'] ?? true) != (horizon == 1)) return false;
      // Feature keys are part of the contract: a solver cannot ignore a track.
      final keys = a.first.keys.toSet();
      final expectedKeys = switch (pattern) {
        'ray-step' => {'form', 'line'},
        'binary-fill' || 'two-fill-steps' || 'double-fill' => {'form', 'fill'},
        'size-fill' => {'form', 'size', 'fill'},
        'two-arrow-turns' || 'arrow-alternation' => {'form', 'arrow'},
        'dots-size' => {'form', 'dots', 'size'},
        'outline-triple' => {'form'},
        'four-tracks' => {'form', 'size', 'line', 'edgeLines'},
        'corner-edge-count' => {'form', 'dot', 'edgeLines'},
        'transfer-count' => {'form', 'dots', 'edgeLines'},
        'interleaved-count' => {'form', 'dots'},
        'fill-ray-dots' => {'form', 'fill', 'line', 'dots'},
        'size-corner-ray' => {'form', 'size', 'dot', 'line'},
        _ => <String>{},
      };
      if (keys.length != expectedKeys.length ||
          !keys.containsAll(expectedKeys)) {
        return false;
      }
      if (a.any(
        (x) =>
            x.keys.length != keys.length || !x.keys.toSet().containsAll(keys),
      )) {
        return false;
      }
      if (candidate.keys.length != expectedKeys.length ||
          !candidate.keys.toSet().containsAll(expectedKeys)) {
        return false;
      }
      if (!_initialValid(a)) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_same(a[i], _state(a, i))) return false;
      }
      return _same(candidate, _state(a, a.length + (horizon as int) - 1));
    } on Object {
      return false;
    }
  }

  List<int> get _lengths => switch (pattern) {
        'ray-step' || 'binary-fill' => [3, 4, 5],
        'arrow-alternation' => [4, 5],
        'size-fill' ||
        'two-fill-steps' ||
        'outline-triple' ||
        'double-fill' =>
          [5],
        'corner-edge-count' ||
        'interleaved-count' ||
        'fill-ray-dots' ||
        'size-corner-ray' =>
          [4],
        _ => [3]
      };

  bool _initialValid(List<Map<String, Object?>> a) {
    final first = a.first;
    final second = a[1];
    return switch (pattern) {
      'ray-step' =>
        [45, 90, 135].contains((_angle(second) - _angle(first)) % 360),
      'binary-fill' ||
      'size-fill' =>
        {'white', 'black'}.containsAll([_fill(first), _fill(second)]) &&
            _fill(first) != _fill(second),
      'dots-size' => _size(first) != _size(second),
      'arrow-alternation' => (_arrows.indexOf(second['arrow']! as String) -
                  _arrows.indexOf(first['arrow']! as String)) %
              4 ==
          1,
      'outline-triple' => a.take(3).map((x) => x['form']).toSet().length == 3,
      'four-tracks' =>
        first['form'] != second['form'] && _size(first) != _size(second),
      'double-fill' =>
        a.take(3).where((x) => x['fill'] == 'white').length == 1 &&
            a.take(3).where((x) => x['fill'] == 'black').length == 2,
      'interleaved-count' => first['form'] != second['form'],
      'fill-ray-dots' => [.25, .5, .75].contains(_fill(first)) &&
          [.25, .5, .75].contains(_fill(second)) &&
          _fill(first) != _fill(second) &&
          [45, 90, 135].contains((_angle(second) - _angle(first)) % 360),
      'corner-edge-count' => a.every((x) => x['form'] == 'square'),
      'size-corner-ray' => first['form'] == 'square' &&
          _size(first) != _size(second) &&
          (_angle(first) - _angle(second)) % 360 == 90,
      _ => true,
    };
  }

  Map<String, Object?> mistake(Variant v, String id) {
    final a = _items(v.figureSpec!);
    final result =
        _state(a, a.length + ((v.slots['horizon'] as int?) ?? 1) - 1);
    final last = a.last;
    switch (id) {
      case 'double-turn':
        result['line'] =
            (_angle(last) + 2 * ((_angle(a[1]) - _angle(a[0])) % 360)) % 360;
      case 'early-restart':
        result['line'] = a.first['line'];
      case 'reverse-turn':
        result['line'] =
            (_angle(last) - ((_angle(a[1]) - _angle(a[0])) % 360)) % 360;
      case 'repeat-fill' || 'freeze-fill':
        result['fill'] = last['fill'];
      case 'average-fill':
        result['fill'] = .5;
      case 'gradual-fill':
        result['fill'] = .25;
      case 'reset-size-early':
        result['size'] = 'small';
      case 'freeze-size':
        result['size'] = last['size'];
      case 'one-step-only':
        return _state(a, a.length);
      case 'reverse-once':
        result['arrow'] =
            _arrows[(_arrows.indexOf(last['arrow']! as String) + 3) % 4];
      case 'zero-steps':
        return Map.of(last);
      case 'freeze-dots':
        result['dots'] = last['dots'];
      case 'restart-dots-on-matching-size':
        result['dots'] = a[1]['dots'];
      case 'assume-continuous-turn':
        result['arrow'] =
            _arrows[(_arrows.indexOf(last['arrow']! as String) + 1) % 4];
      case 'repeat-last':
        return Map.of(last);
      case 'invent-four-direction-cycle':
        result['arrow'] =
            _arrows[(_arrows.indexOf(a[1]['arrow']! as String) + 2) % 4];
      case 'keep-increasing':
        result['fill'] = 1;
      case 'accumulate-fill':
        result['fill'] = (_fill(a.first) as num) + (_fill(a[1]) as num);
      case 'restart-early':
        result['form'] = a.first['form'];
      case 'increase-sides':
        result['form'] = switch (result['form']) {
          'triangle' => 'square',
          'square' => 'pentagon',
          _ => throw const FormatException('unsupported side increment')
        };
      case 'freeze-edge-count' || 'freeze-lines' || 'freeze-edges':
        result['edgeLines'] = last['edgeLines'];
      case 'freeze-form-and-ray':
        result['form'] = last['form'];
        result['line'] = last['line'];
      case 'freeze-dot':
        result['dot'] = last['dot'];
      case 'skip-corner':
        result['dot'] =
            _corners[(_corners.indexOf(last['dot']! as String) + 2) % 4];
      case 'continue-majority-fill':
        result['fill'] = 'black';
      case 'change-outline':
        result['form'] = v.slots['extraForm'];
      case 'restart-edge-count':
        result['edgeLines'] = a.first['edgeLines'];
      case 'continue-even-track':
        return Map.of(last);
      case 'count-all-positions':
        result['dots'] = 5;
      case 'repeat-odd-count':
        result['dots'] = a[a.length - 2]['dots'];
      case 'copy-even-count':
        result['dots'] = a[1]['dots'];
      case 'freeze-ray':
        result['line'] = last['line'];
      default:
        throw FormatException('unknown mistake $id');
    }
    return result;
  }

  @override
  Map<String, Object?> ruleParams(ProblemType type, Variant variant) {
    final formCosmetic = ![
      'outline-triple',
      'four-tracks',
      'double-fill',
      'interleaved-count',
    ].contains(pattern);
    return {
      'pattern': pattern,
      'items': _items(variant.figureSpec!)
          .map(
            (x) => {
              for (final e in x.entries)
                if (!formCosmetic || e.key != 'form') e.key: e.value,
            },
          )
          .toList(),
    };
  }

  @override
  List<String> validateCosmetics(ProblemType type, Variant v) {
    final expected = ![
      'outline-triple',
      'four-tracks',
      'double-fill',
      'interleaved-count',
    ].contains(pattern);
    if (!expected) return v.cosmetics.isEmpty ? [] : ['unexpected cosmetics'];
    final form = _items(v.figureSpec!).first['form'];
    return [
      if (dataKey(v.cosmetics) != dataKey({'form': form}))
        'cosmetic form mismatch',
      if ([..._items(v.figureSpec!), ...v.choices.map((x) => x.figure!)]
          .any((x) => x['form'] != form))
        'form varies within cosmetic version',
    ];
  }

  @override
  List<String> validateRanges(ProblemType type, Variant v) {
    final errors = <String>[];
    final a = _items(v.figureSpec!);
    for (final item in [...a, ...v.choices.map((x) => x.figure!)]) {
      if (!_forms.contains(item['form']) ||
          !(type.params['forms']! as List).contains(item['form'])) {
        errors.add('unsupported form');
      }
      if (item['size'] != null &&
          (!_sizes.contains(item['size']) ||
              !(type.params['sizes']! as List).contains(item['size']))) {
        errors.add('unsupported size');
      }
      for (final key in ['dots', 'edgeLines']) {
        final count = _count(item, key);
        if (count < 0 || count > 5) errors.add('$key out of range');
      }
      if (item['line'] != null && ((item['line']! as num) % 45 != 0)) {
        errors.add('unreadable ray angle');
      }
      final fill = item['fill'];
      if (fill != null && !['white', 'black', .25, .5, .75, 1].contains(fill)) {
        errors.add('unsupported fill');
      }
    }
    if (!_lengths.contains(a.length) ||
        !(type.params['lengths']! as List).contains(a.length)) {
      errors.add('length out of range');
    }
    if (a.first['dots'] != null &&
        !(type.params['initialDots']! as List).contains(a.first['dots'])) {
      errors.add('initial dots outside params');
    }
    if (a.first['edgeLines'] != null &&
        !(type.params['initialEdges']! as List)
            .contains(a.first['edgeLines'])) {
      errors.add('initial edges outside params');
    }
    if (pattern == 'ray-step' &&
        !(type.params['steps']! as List)
            .contains((_angle(a[1]) - _angle(a[0])) % 360)) {
      errors.add('step outside params');
    }
    if (['dots-size', 'transfer-count'].contains(pattern) &&
        ![0, 1, 2].contains(a.first['dots'])) {
      errors.add('initial dots out of range');
    }
    if (pattern == 'four-tracks' && ![0, 1, 2].contains(a.first['edgeLines'])) {
      errors.add('initial edges out of range');
    }
    if (pattern == 'corner-edge-count' &&
        ![0, 1].contains(a.first['edgeLines'])) {
      errors.add('initial edges out of range');
    }
    if (pattern == 'transfer-count' &&
        ![3, 4, 5].contains(a.first['edgeLines'])) {
      errors.add('initial edges out of range');
    }
    if (pattern == 'interleaved-count' &&
        ![0, 1, 2, 3].contains(a.first['dots'])) {
      errors.add('initial odd dots out of range');
    }
    if (pattern == 'fill-ray-dots' && ![0, 1].contains(a.first['dots'])) {
      errors.add('initial dots out of range');
    }
    return errors;
  }
}

const seriesMistakes = <String, List<String>>{
  'ray-step': ['double-turn', 'early-restart', 'reverse-turn'],
  'binary-fill': ['repeat-fill', 'average-fill', 'gradual-fill'],
  'size-fill': ['freeze-fill', 'reset-size-early', 'freeze-size'],
  'two-arrow-turns': ['one-step-only', 'reverse-once', 'zero-steps'],
  'dots-size': ['freeze-size', 'freeze-dots', 'restart-dots-on-matching-size'],
  'arrow-alternation': [
    'assume-continuous-turn',
    'repeat-last',
    'invent-four-direction-cycle',
  ],
  'two-fill-steps': ['keep-increasing', 'repeat-last', 'one-step-only'],
  'outline-triple': ['restart-early', 'repeat-last', 'increase-sides'],
  'four-tracks': ['freeze-edge-count', 'freeze-size', 'freeze-form-and-ray'],
  'corner-edge-count': ['freeze-dot', 'freeze-lines', 'skip-corner'],
  'double-fill': ['continue-majority-fill', 'average-fill', 'change-outline'],
  'transfer-count': ['freeze-edges', 'freeze-dots', 'restart-edge-count'],
  'interleaved-count': [
    'continue-even-track',
    'count-all-positions',
    'repeat-odd-count',
  ],
  'fill-ray-dots': ['freeze-fill', 'freeze-ray', 'accumulate-fill'],
  'size-corner-ray': ['freeze-size', 'freeze-dot', 'freeze-ray'],
};
