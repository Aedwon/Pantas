// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';
import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/model.dart';

Variant question(
  List<Object?> cells, {
  int rows = 2,
  int cols = 2,
  int turn = 0,
}) =>
    parseVariants({
      'variants': [
        {
          'index': 0,
          'slots': <String, Object?>{},
          'figureSpec': {
            'kind': 'figure-matrix',
            'rows': rows,
            'cols': cols,
            'cells': cells,
          },
          'choices': [
            {
              'correct': true,
              'text': 'answer',
              'figure': {'form': 'square', 'line': turn},
            }
          ],
          'ruleKey': 'key',
          'signature': 'pending',
          'cosmetics': <String, Object?>{},
        }
      ],
    }).single;
void main() {
  test('rectangular matrices rotate dimensions and mirror the whole grid', () {
    Map<String, Object?> ray(int angle) => {'form': 'square', 'line': angle};
    final a = question(
      [ray(0), ray(90), ray(180), ray(270), ray(45), 'blank'],
      cols: 3,
    );
    final rotated = question(
      [ray(0), ray(90), ray(135), ray(180), 'blank', ray(270)],
      rows: 3,
      turn: 90,
    );
    final mirrored = question(
      [ray(180), ray(270), ray(0), 'blank', ray(315), ray(90)],
      cols: 3,
    );
    expect(canonicalSignature(a), canonicalSignature(rotated));
    expect(canonicalSignature(a), canonicalSignature(mirrored));
  });
  test('matrix rotates grid and drawn rays together', () {
    final a = question([
      {'form': 'square', 'line': 0},
      {'form': 'square', 'line': 90},
      {'form': 'square', 'line': 180},
      'blank',
    ]);
    final b = question(
      [
        {'form': 'square', 'line': 270},
        {'form': 'square', 'line': 90},
        'blank',
        {'form': 'square', 'line': 180},
      ],
      turn: 90,
    );
    expect(canonicalSignature(a), canonicalSignature(b));
  });
  test('matrix signature retains blank location and relative direction', () {
    final a = question([
      {'form': 'square', 'line': 0},
      {'form': 'square', 'line': 90},
      {'form': 'square', 'line': 180},
      'blank',
    ]);
    final b = question([
      {'form': 'square', 'line': 0},
      {'form': 'square', 'line': 90},
      'blank',
      {'form': 'square', 'line': 180},
    ]);
    expect(canonicalSignature(a), isNot(canonicalSignature(b)));
  });
}
