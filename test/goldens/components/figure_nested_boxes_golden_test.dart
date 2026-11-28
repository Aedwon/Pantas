import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';

import '../golden_harness.dart';

/// The nested-boxes figure in the reader, as a phone gives it room: a 320
/// phone leaves 272 (24 px of page padding each side), a 390 phone 342.
///
/// Its own file: run before the web `figure` sheet in one file, this phone
/// sheet left the focus highlight in touch mode and the Focus cell lost its
/// ring.
Widget _nestedBoxes() => const ProviderScope(
      child: ContentRenderer(
        readerFigures: true,
        blocks: [
          {
            '_type': 'figureSpec',
            'spec': {
              'kind': 'concept-diagram',
              'type': 'nested-boxes',
              'boxes': [
                'Natural Numbers',
                'Whole Numbers',
                'Integers',
                'Rational Numbers',
                'Irrational Numbers',
                'Real Numbers',
              ],
            },
            'semanticsLabel': 'Nested sets of real numbers.',
          },
        ],
      ),
    );

void main() {
  goldenSheet(
    'figure_nested_boxes',
    [
      GoldenState('Phone 320', (_) => _nestedBoxes(), width: 272),
      GoldenState('Phone 390', (_) => _nestedBoxes(), width: 342),
    ],
    cellWidth: 342,
    columns: 2,
  );
}
