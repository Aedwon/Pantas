import '../model.dart';
import 'series_signature.dart';
import 'signature.dart';

/// D4 acts on both grid positions and drawn features, including the blank.
/// Choice order and wording do not add capacity.
Object canonicalMatrix(Variant variant) {
  final shown = variant.figureSpec!;
  final rows = shown['rows']! as int;
  final cols = shown['cols']! as int;
  final keys = <String>[];
  for (final mirror in [false, true]) {
    for (var turns = 0; turns < 4; turns++) {
      final outRows = turns.isEven ? rows : cols;
      final outCols = turns.isEven ? cols : rows;
      final cells = List<Object?>.filled(rows * cols, null);
      final raw = shown['cells']! as List;
      for (var i = 0; i < raw.length; i++) {
        var y = i ~/ cols;
        var x = i % cols;
        var height = rows;
        var width = cols;
        if (mirror) x = width - 1 - x;
        for (var t = 0; t < turns; t++) {
          final oldX = x;
          x = height - 1 - y;
          y = oldX;
          final oldWidth = width;
          width = height;
          height = oldWidth;
        }
        cells[y * outCols + x] = raw[i] == 'blank'
            ? 'blank'
            : canonicalSeriesItem(
                Map<String, Object?>.from(raw[i] as Map),
                turns,
                mirror: mirror,
              );
      }
      final answer = variant.choices.singleWhere((c) => c.correct);
      keys.add(
        dataKey({
          'rows': outRows,
          'cols': outCols,
          'cells': cells,
          'answer': canonicalSeriesItem(answer.figure!, turns, mirror: mirror),
        }),
      );
    }
  }
  return (keys..sort()).first;
}
