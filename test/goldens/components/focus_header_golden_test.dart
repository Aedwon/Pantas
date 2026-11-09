import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_timer.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

const _close = IconData(0xe4f6, fontFamily: 'Phosphor');
const _flag = IconData(0xe244, fontFamily: 'Phosphor');

Widget _bar({bool timer = false}) => WebTopBar(
      leading:
          WebTopBarButton(tooltip: 'Close', glyph: _close, onPressed: () {}),
      title: Text(timer ? '' : 'Question 3 of 10'),
      trailing: timer
          ? const PantasTimer(
              timeText: '42:10',
              fractionLeft: 0.7,
              inline: true,
            )
          : WebTopBarButton(tooltip: 'Report', glyph: _flag, onPressed: () {}),
    );

void main() {
  goldenSheet(
    'focus_header',
    [
      GoldenState('Desktop', (_) => _bar(), width: 520),
      GoldenState('With timer', (_) => _bar(timer: true), width: 520),
      GoldenState(
        'Centered title',
        (_) => WebCenteredTopBar(
          leading: WebTopBarButton(
            tooltip: 'Close',
            glyph: _close,
            onPressed: () {},
          ),
          title: 'Mock exam',
          trailing: const PantasTimer(
            timeText: '42:10',
            fractionLeft: 0.7,
            inline: true,
          ),
        ),
        width: 520,
      ),
      GoldenState(
        'Close, focus',
        (_) => _bar(),
        action: GoldenAction.focus,
        width: 520,
      ),
    ],
    cellWidth: 520,
    columns: 2,
    web: true,
  );
}
