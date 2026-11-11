import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/section_header.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

Widget _link() => WebTextLink(label: 'View Full Plan', onPressed: () {});

void main() {
  goldenSheet(
    'section_header',
    [
      const GoldenState('Title only', _title),
      GoldenState('With a link', (_) => SectionHeader('Today', link: _link())),
      GoldenState(
        'Link hover',
        (_) => SectionHeader('Today', link: _link()),
        action: GoldenAction.hover,
        at: const Alignment(0.9, 0),
      ),
      GoldenState(
        'Link focus',
        (_) => SectionHeader('Today', link: _link()),
        action: GoldenAction.focus,
      ),
      GoldenState(
        'In a card',
        (_) => SectionHeader('Today', inCard: true, link: _link()),
      ),
      GoldenState(
        'Phone',
        (_) => const SectionHeader('This week', phone: true),
        web: false,
      ),
      GoldenState('Group label', (_) => const GroupLabel('Account')),
      GoldenState(
        'Group note',
        (_) => const GroupNote('Changes save on this device.'),
      ),
    ],
    cellWidth: 340,
    columns: 2,
    web: true,
  );
}

Widget _title(BuildContext _) => const SectionHeader('Today');
