import '../model.dart';
import 'signature.dart';

/// Canonicalize the whole ordered sequence and correct answer under D4.
/// Components use their drawn orientation, including the bottom fill/edge marks
/// and the off-center dot rows on triangles and stars. Words never add
/// capacity.
Object canonicalSeries(Variant variant) {
  final keys = <String>[];
  for (final mirror in [false, true]) {
    for (var turn = 0; turn < 4; turn++) {
      final shown = variant.figureSpec!;
      final answer = variant.choices.singleWhere((c) => c.correct);
      keys.add(
        dataKey({
          'blank': shown['blank'] ?? true,
          'items': (shown['items']! as List)
              .cast<Map<String, Object?>>()
              .map((raw) => canonicalSeriesItem(raw, turn, mirror: mirror))
              .toList(),
          'answer': canonicalSeriesItem(answer.figure!, turn, mirror: mirror),
          // Different query horizons are different problems, not wording
          // cosmetics.
          'horizon': variant.slots['horizon'] ?? 1,
        }),
      );
    }
  }
  return (keys..sort()).first;
}

/// Drawn item normalization shared by series and matrices.
Map<String, Object?> canonicalSeriesItem(
  Map<String, Object?> raw,
  int turn, {
  required bool mirror,
}) {
  num angle(num value) => ((mirror ? -value : value) + turn * 90) % 360;
  final form = raw['form'];
  final rotation = (raw['rotation'] as num?) ?? 0;
  final orientation = angle(rotation);
  final fill = switch (raw['fill']) {
    'black' => 1,
    'white' || null => 0,
    final num n => n,
    _ => throw const FormatException('invalid fill'),
  };
  final lines = <num>[
    if (raw['line'] is num) raw['line']! as num,
    if (raw['lines'] is List) ...(raw['lines']! as List).cast<num>(),
  ].map((a) => angle(rotation + a)).toList()
    ..sort();
  final dot = switch (raw['dot']) {
    'top-left' => 315,
    'top-right' => 45,
    'bottom-right' => 135,
    'bottom-left' => 225,
    'top' => 0,
    _ => null,
  };
  final arrow = switch (raw['arrow']) {
    'up' => 0,
    'right' => 90,
    'down' => 180,
    'left' => 270,
    _ => null,
  };
  final dots = (raw['dots'] as int?) ?? 0;
  final edges = (raw['edgeLines'] as int?) ?? 0;
  return {
    'form': form,
    'size': raw['size'] ?? 'large',
    'outline': switch (form) {
      'circle' => 0,
      'square' => orientation % 90,
      'triangle' => orientation % 120,
      'pentagon' || 'star' => orientation % 72,
      _ => throw const FormatException('invalid form'),
    },
    'fill': fill,
    if (fill > 0 && fill < 1) 'fillDirection': angle(rotation + 180),
    'lines': lines,
    if (dot != null) 'dot': angle(rotation + dot),
    if (arrow != null) 'arrow': angle(rotation + arrow),
    'dots': dots,
    if (dots > 0 && (form == 'triangle' || form == 'star'))
      'dotRow': orientation,
    if (dots > 1 && form != 'triangle' && form != 'star')
      'dotRow': orientation % 180,
    'edgeLines': edges,
    if (edges > 0) 'edgeDirection': angle(rotation + 180),
  };
}
