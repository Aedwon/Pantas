import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/segmented_switch.dart';

import '../golden_harness.dart';

SegmentedSwitch _switch(int selected) => SegmentedSwitch(
      labels: const ['Lessons', 'Practice', 'Mocks'],
      selected: selected,
      onChanged: (_) {},
    );

void main() {
  goldenSheet(
    'segmented_control',
    [
      GoldenState('First selected', (_) => _switch(0), width: 340),
      GoldenState('Middle selected', (_) => _switch(1), width: 340),
      GoldenState(
        'Hover',
        (_) => _switch(0),
        action: GoldenAction.hover,
        at: const Alignment(0.7, 0),
        width: 340,
      ),
      GoldenState(
        'Pressed',
        (_) => _switch(0),
        action: GoldenAction.pressed,
        at: const Alignment(0.7, 0),
        width: 340,
      ),
      GoldenState(
        'Focus',
        (_) => _switch(0),
        action: GoldenAction.focus,
        width: 340,
      ),
      GoldenState(
        'Bookmarks',
        (_) => SegmentedSwitch.bookmarks(
          labels: const ['Lessons', 'Questions'],
          selected: 0,
          onChanged: (_) {},
        ),
        width: 340,
      ),
      GoldenState(
        'Bookmarks disabled',
        (_) => SegmentedSwitch.bookmarks(
          labels: const ['Lessons', 'Questions'],
          selected: 0,
          enabled: false,
          onChanged: (_) {},
        ),
        width: 340,
      ),
    ],
    cellWidth: 340,
    columns: 2,
    web: true,
  );
}
