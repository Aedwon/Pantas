import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantas/core/ui/components/content_renderer.dart';

import '../golden_harness.dart';

String _svg() {
  const svg = '<svg xmlns="http://www.w3.org/2000/svg" width="300" '
      'height="160" viewBox="0 0 300 160"><rect x="20" y="20" width="260" '
      'height="120" fill="none" stroke="#333" stroke-width="4"/> '
      '<circle cx="150" cy="80" r="40" fill="#0f766e"/></svg>';
  return 'data:image/svg+xml;base64,${base64Encode(utf8.encode(svg))}';
}

Widget _figure({required bool reader}) => ProviderScope(
      child: ContentRenderer(
        readerFigures: reader,
        blocks: [
          {
            '_type': 'image',
            'asset': {'url': _svg(), 'credit': 'Pantas'},
            'alt': 'A circle in a square',
          },
        ],
      ),
    );

void main() {
  goldenSheet(
    'figure',
    [
      GoldenState('Question figure', (_) => _figure(reader: false), width: 340),
      GoldenState('Reader figure', (_) => _figure(reader: true), width: 340),
      GoldenState(
        'Hover',
        (_) => _figure(reader: true),
        action: GoldenAction.hover,
        width: 340,
      ),
      GoldenState(
        'Focus',
        (_) => _figure(reader: true),
        action: GoldenAction.focus,
        width: 340,
      ),
    ],
    cellWidth: 340,
    web: true,
    columns: 2,
  );
}
