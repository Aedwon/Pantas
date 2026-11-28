import '../model.dart';
import 'signature.dart';

/// Canonicalize a labeled net, its query and its correct answer under D4.
/// Label spelling, cell order, planar translation and choice order add no
/// capacity. References in slots and text choices follow their labeled cells.
/// Query slots use `operation`, `face`, `faces` and optional `upFace`.
Object canonicalCubeNet(Variant variant) {
  final shown = variant.figureSpec!;
  final raw = (shown['cells']! as List).cast<List<Object?>>();
  final labels = (shown['labels']! as List).cast<String>();
  if (raw.length != 6 || labels.length != 6 || labels.toSet().length != 6) {
    throw const FormatException('cube-net requires six uniquely labeled cells');
  }
  final alternatives = <String>[];
  for (final mirror in [false, true]) {
    for (var turns = 0; turns < 4; turns++) {
      final points = raw.map((p) {
        var row = p[0]! as int;
        var col = p[1]! as int;
        if (mirror) col = -col;
        for (var n = 0; n < turns; n++) {
          final old = row;
          row = -col;
          col = old;
        }
        return (row, col);
      }).toList();
      final minRow = points.map((p) => p.$1).reduce((a, b) => a < b ? a : b);
      final minCol = points.map((p) => p.$2).reduce((a, b) => a < b ? a : b);
      final positions = [
        for (final p in points) [p.$1 - minRow, p.$2 - minCol],
      ];
      final byLabel = <String, Object?>{
        for (var i = 0; i < labels.length; i++) labels[i]: positions[i],
      };
      Object? reference(Object? value) {
        if (value is List) return value.map(reference).toList();
        if (value is String) {
          if (!byLabel.containsKey(value)) {
            throw FormatException('unknown queried face $value');
          }
          return byLabel[value];
        }
        return value;
      }

      String answer(String text) {
        // Relations are unordered, while other text (for example top then
        // shadow) retains its order. Normalize before substituting coordinates.
        final token = byLabel.keys.map(RegExp.escape).join('|');
        final pair = RegExp('\\b($token)\\b( and |\\s*-\\s*)\\b($token)\\b');
        var normalized = text.replaceAllMapped(pair, (match) {
          final ends = [
            dataKey(byLabel[match[1]]),
            dataKey(byLabel[match[3]]),
          ]..sort();
          return '@pair${dataKey(ends)}';
        });
        final separator = text.contains(';') ? ';' : ', ';
        if (pair.allMatches(text).length == 3) {
          normalized =
              (normalized.split(separator).map((s) => s.trim()).toList()
                    ..sort())
                  .join(';');
        }
        if (normalized.contains(',') &&
            RegExp('^($token)(, ($token)){2}' r'\.?$').hasMatch(text)) {
          final faces = text
              .replaceAll('.', '')
              .split(', ')
              .map((label) => dataKey(byLabel[label]))
              .toList()
            ..sort();
          return '@set${dataKey(faces)}';
        }
        return normalized.replaceAllMapped(
          RegExp(r'\b[A-Za-z0-9]+\b'),
          (m) =>
              byLabel.containsKey(m[0]) ? '@${dataKey(byLabel[m[0]])}' : m[0]!,
        );
      }

      final correct = variant.choices.singleWhere((choice) => choice.correct);
      final cells = positions.map(dataKey).toList()..sort();
      alternatives.add(
        dataKey({
          'cells': cells,
          'showFolded': shown['showFolded'] ?? false,
          'operation': variant.slots['operation'],
          for (final key in ['face', 'faces', 'upFace'])
            if (variant.slots.containsKey(key))
              key: key == 'faces'
                  ? ((reference(variant.slots[key])! as List)
                      .map(dataKey)
                      .toList()
                    ..sort())
                  : reference(variant.slots[key]),
          'answer': answer(correct.text),
        }),
      );
    }
  }
  return (alternatives..sort()).first;
}
