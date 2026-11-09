import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_timer.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/web/web_components.dart';

import '../golden_harness.dart';

/// The question page's header: Close with its Esc hint at the left, the
/// title centered, and Report at the right (the quiz and the assessment).
Widget _header({Widget? trailing, String title = 'Mathematics'}) =>
    WebCenteredTopBar(
      title: title,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WebTopBarButton(
            tooltip: 'Leave session',
            onPressed: () {},
            icon: Icon(PantasIcons.close, size: 22),
          ),
          const SizedBox(width: 10),
          const WebKeyHint('Esc'),
        ],
      ),
      trailing: trailing ?? _report(),
    );

Widget _report() => WebTopBarButton(
      tooltip: 'Report a question',
      onPressed: () {},
      icon: PantasIcons.report,
    );

const _clock = PantasTimer(timeText: '42:10', fractionLeft: 0.7, inline: true);

void main() {
  goldenSheet(
    'focus_header',
    [
      GoldenState('Desktop', (_) => _header(), width: 560),
      GoldenState(
        'Mock exam, clock',
        (_) => _header(
          title: 'UPCAT Mock Exam',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [_clock, const SizedBox(width: 8), _report()],
          ),
        ),
        width: 560,
      ),
      GoldenState(
        'Close, focus',
        (_) => _header(),
        action: GoldenAction.focus,
        width: 560,
      ),
      GoldenState(
        'Report, hover',
        (_) => _header(),
        action: GoldenAction.hover,
        at: const Alignment(0.97, 0),
        width: 560,
      ),
      GoldenState(
        'Top bar (review)',
        (_) => WebTopBar(
          leading:
              WebBackLink(label: 'Results', onPressed: () {}, nudge: false),
          title: const SizedBox.shrink(),
          trailing: WebButton(
            label: 'Flag',
            keyHint: 'F',
            variant: WebButtonVariant.tertiary,
            onPressed: () {},
          ),
        ),
        width: 560,
      ),
    ],
    cellWidth: 560,
    columns: 2,
    web: true,
  );
}
