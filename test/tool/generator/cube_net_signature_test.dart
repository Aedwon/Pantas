// ignore_for_file: avoid_relative_lib_imports
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/generator/lib/src/check/signature.dart';
import '../../../tool/generator/lib/src/model.dart';

const cross = <List<int>>[
  [0, 1],
  [1, 0],
  [1, 1],
  [1, 2],
  [2, 1],
  [3, 1],
];

Variant netVariant({
  List<List<int>> cells = cross,
  List<String> labels = const ['A', 'B', 'C', 'D', 'E', 'F'],
  String face = 'C',
}) =>
    parseVariants({
      'variants': [
        {
          'index': 0,
          'slots': {'operation': 'opposite', 'face': face},
          'figureSpec': {'kind': 'cube-net', 'cells': cells, 'labels': labels},
          'choices': [
            {'text': labels[5], 'correct': true},
            {'text': labels[0], 'mistake': 'stop-early'},
            {'text': labels[1], 'mistake': 'left-arm'},
            {'text': labels[4], 'mistake': 'lower-neighbor'},
          ],
          'ruleKey': 'test',
          'cosmetics': <String, Object?>{},
          'signature': 'test',
        },
      ],
    }).single;

Variant relationVariant(String answer) {
  final data = netVariant().toMap();
  data['choices'] = [
    {'text': answer, 'correct': true},
    {'text': 'B', 'mistake': 'probe'},
    {'text': 'C', 'mistake': 'probe'},
    {'text': 'D', 'mistake': 'probe'},
  ];
  return parseVariants({
    'variants': [data],
  }).single;
}

void main() {
  test('unordered query face pairs add no capacity', () {
    Variant query(List<String> faces) => parseVariants({
          'variants': [
            {
              ...relationVariant('They share an edge.').toMap(),
              'slots': {'operation': 'net-adjacent-relation', 'faces': faces},
            }
          ],
        }).single;
    expect(
      canonicalSignature(query(['A', 'B'])),
      canonicalSignature(query(['B', 'A'])),
    );
  });
  test('overlap endpoint order adds no capacity', () {
    expect(
      canonicalSignature(relationVariant('A and E overlap.')),
      canonicalSignature(relationVariant('E and A overlap.')),
    );
  });
  test('opposite pairs and their endpoints are unordered', () {
    expect(
      canonicalSignature(relationVariant('A-F, B-D, C-E')),
      canonicalSignature(relationVariant('E-C, F-A, D-B')),
    );
  });
  test('source opposite-pair lists ignore pair and endpoint order', () {
    expect(
      canonicalSignature(relationVariant('A and E; B and D; C and F')),
      canonicalSignature(relationVariant('F and C; E and A; D and B')),
    );
  });
  test('corner sets ignore face order', () {
    expect(
      canonicalSignature(relationVariant('A, B, C')),
      canonicalSignature(relationVariant('C, A, B')),
    );
  });
  test('different relations remain distinct', () {
    expect(
      canonicalSignature(relationVariant('A and E overlap.')),
      isNot(canonicalSignature(relationVariant('A and E are opposite.'))),
    );
  });
  test('cube-net signature ignores consistent label renaming', () {
    expect(
      canonicalSignature(netVariant()),
      canonicalSignature(
        netVariant(
          labels: ['P', 'Q', 'R', 'S', 'T', 'U'],
          face: 'R',
        ),
      ),
    );
  });
  test('cube-net signature normalizes every planar isometry and translation',
      () {
    final expected = canonicalSignature(netVariant());
    for (final reflected in [false, true]) {
      for (var turn = 0; turn < 4; turn++) {
        final transformed = cross.map((p) {
          var row = p[0];
          var col = reflected ? -p[1] : p[1];
          for (var n = 0; n < turn; n++) {
            final old = row;
            row = -col;
            col = old;
          }
          return [row + 4, col + 4];
        }).toList();
        expect(canonicalSignature(netVariant(cells: transformed)), expected);
      }
    }
  });
  test('queried face remains part of the spatial problem', () {
    expect(
      canonicalSignature(netVariant(face: 'A')),
      isNot(canonicalSignature(netVariant())),
    );
  });
  test('changed answer face set remains part of the whole question', () {
    final original = netVariant();
    final changed = original.toMap();
    final choices = original.choices.map((c) => c.toMap()).toList();
    choices[1]['text'] = 'D';
    changed['choices'] = choices;
    expect(
      canonicalSignature(
        parseVariants({
          'variants': [changed],
        }).single,
      ),
      isNot(canonicalSignature(original)),
    );
  });
  test('cell order is not spatial capacity when labels follow their cells', () {
    final original = netVariant();
    final reversed = original.toMap();
    reversed['figureSpec'] = {
      'kind': 'cube-net',
      'cells': cross.reversed.toList(),
      'labels': ['F', 'E', 'D', 'C', 'B', 'A'],
    };
    expect(
      canonicalSignature(
        parseVariants({
          'variants': [reversed],
        }).single,
      ),
      canonicalSignature(original),
    );
  });
}
