// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';
import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/model.dart';

Variant sample(List<Map<String, Object?>> items) => parseVariants({
      'variants': [
        {
          'index': 0,
          'slots': <String, Object?>{},
          'figureSpec': {
            'kind': 'figure-series',
            'items': items,
            'blank': true,
          },
          'choices': [
            {'text': 'answer', 'correct': true, 'figure': items.last},
          ],
          'ruleKey': 'x',
          'cosmetics': <String, Object?>{},
          'signature': 'x',
        },
      ],
    }).single;

void main() {
  test('series signature collapses whole rotations and reflections', () {
    final original = sample([
      {'form': 'square', 'line': 0},
      {'form': 'square', 'line': 45},
    ]);
    final turned = sample([
      {'form': 'square', 'rotation': 90, 'line': 0},
      {'form': 'square', 'rotation': 90, 'line': 45},
    ]);
    final reflected = sample([
      {'form': 'square', 'line': 0},
      {'form': 'square', 'line': 315},
    ]);
    expect(canonicalSignature(original), canonicalSignature(turned));
    expect(canonicalSignature(original), canonicalSignature(reflected));
  });
  test('series signature retains fractional fill and count information', () {
    expect(
      canonicalSignature(
        sample([
          {'form': 'circle', 'fill': .25},
          {'form': 'circle', 'dots': 2},
        ]),
      ),
      isNot(
        canonicalSignature(
          sample([
            {'form': 'circle', 'fill': .5},
            {'form': 'circle', 'dots': 2},
          ]),
        ),
      ),
    );
  });
}
