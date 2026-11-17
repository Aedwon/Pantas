import '../model.dart';
import 'signature.dart';

/// A row's reversal is the only additional ordering reachable by a whole-row
/// rotation or reflection. Shape-row has no per-shape orientation field.
/// Defaults are materialized, and position answers move with their figures.
/// Text descriptions and choice ordering do not create capacity.
Object canonicalShapeRow(Variant v) {
  final shapes =
      (v.figureSpec!['shapes']! as List).cast<Map<String, Object?>>();
  Map<String, Object?> normal(Map<String, Object?> x) => {
        'form': x['form'],
        'dots': x['dots'] ?? 0,
        'lines': x['lines'] ?? 0,
        'through': x['through'] ?? 'centre',
      };
  final keys = <String>[];
  for (final reverse in [false, true]) {
    final choices = v.choices.map((c) {
      if (c.figure != null) return dataKey(normal(c.figure!));
      final position = int.tryParse(c.value ?? '');
      final positional = v.slots['operation'] != 'specific-rule';
      return dataKey(
        positional && position != null
            ? '${reverse ? shapes.length + 1 - position : position}'
            : c.value,
      );
    }).toList()
      ..sort();
    keys.add(
      dataKey({
        'shapes': (reverse ? shapes.reversed : shapes).map(normal).toList(),
        'operation': v.slots['operation'],
        'choices': choices,
      }),
    );
  }
  return (keys..sort()).first;
}
