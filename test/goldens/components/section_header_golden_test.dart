import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/section_header.dart';

import '../golden_harness.dart';

void main() {
  goldenSheet(
    'section_header',
    [
      GoldenState('Title only', (_) => const SectionHeader('This week')),
      GoldenState(
        'With a link',
        (_) => const SectionHeader('This week', link: Text('See all')),
      ),
      GoldenState(
        'Phone',
        (_) => const SectionHeader('This week', phone: true),
      ),
      GoldenState(
        'In a card',
        (_) => const SectionHeader('This week', inCard: true),
      ),
    ],
    cellWidth: 300,
    columns: 2,
  );
}
