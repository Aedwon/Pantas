import '../model.dart';
import 'signature.dart';

/// Row order does not change a grouping task. Keep multiplicity and mark the
/// keyed figure, rather than its position. Wrong choices add no capacity.
Object canonicalShapeRow(Variant v) {
  final shapes =
      (v.figureSpec!['shapes']! as List).cast<Map<String, Object?>>();
  Map<String, Object?> normal(Map<String, Object?> x) => {
        'form': x['form'],
        'dots': x['dots'] ?? 0,
        'lines': x['lines'] ?? 0,
        'through': x['through'] ?? 'centre',
      };
  final correct = v.choices.singleWhere((c) => c.correct);
  final position = int.tryParse(correct.value ?? '');
  final positional =
      v.slots['operation'] != 'specific-rule' && position != null;
  final row = [
    for (var i = 0; i < shapes.length; i++)
      dataKey({
        'figure': normal(shapes[i]),
        if (positional) 'key': i == position - 1,
      }),
  ]..sort();
  return {
    'shapes': row,
    'operation': v.slots['operation'],
    if (!positional)
      'answer':
          correct.figure != null ? normal(correct.figure!) : correct.value,
  };
}
