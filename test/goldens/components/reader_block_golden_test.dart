import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';

import '../golden_harness.dart';

Map<String, Object?> _block(String text, {String style = 'normal'}) => {
      '_type': 'block',
      'style': style,
      'children': [
        {'_type': 'span', 'text': text, 'marks': <String>[]},
      ],
    };

Widget _reader(List<Map<String, Object?>> blocks) => ProviderScope(
      child: ContentRenderer(blocks: blocks, readerFigures: true),
    );

void main() {
  goldenSheet(
    'reader_block',
    [
      GoldenState(
        'Note',
        (_) => _reader([
          _block('Mnemonics & Memory Aids', style: 'h2'),
          _block(
            'A fraction names a part of a whole. The bottom number says how '
            'many equal parts there are.',
            style: 'blockquote',
          ),
        ]),
        width: 360,
      ),
      GoldenState(
        'Traps to watch for',
        (_) => _reader([
          _block('Traps to Watch For', style: 'h2'),
          _block('#1: Adding the bottoms', style: 'h3'),
          _block(
            'Add fractions with the same bottom number by adding the tops '
            'only.',
            style: 'blockquote',
          ),
        ]),
        width: 360,
      ),
      GoldenState(
        'Example',
        (_) => _reader([
          _block('Examples', style: 'h2'),
          _block('#1: Comparing halves', style: 'h3'),
          _block('Which is larger, 1/2 or 1/3?'),
          {
            '_type': 'block',
            'style': 'normal',
            'children': [
              {
                '_type': 'span',
                'text': 'Solution:',
                'marks': ['strong'],
              },
            ],
          },
          _block(
            'Cut the same whole into 2 parts or 3 parts. Halves are bigger.',
          ),
        ]),
        width: 360,
      ),
    ],
    cellWidth: 360,
    columns: 2,
    web: true,
  );
}
