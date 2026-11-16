import 'package:flutter/material.dart';
import 'package:pantas/core/dev/input_check.dart';
import 'package:pantas/core/dev/input_check_probe.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// Wraps the app with the numbers overlay when the staging `?perf=1` switch
/// is on, and returns [child] untouched otherwise.
Widget withInputCheckOverlay(Widget child) {
  final probe = InputCheck.probe;
  return probe == null ? child : InputCheckOverlay(probe: probe, child: child);
}

/// Listens for scrolling at the root and shows the last drag and fling at the
/// top of the screen. It ignores pointers, so it never blocks a tap.
class InputCheckOverlay extends StatelessWidget {
  const InputCheckOverlay({
    required this.probe,
    required this.child,
    super.key,
  });

  final InputCheckProbe probe;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        probe.onScroll(notification);
        return false;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned(
            top: MediaQuery.viewPaddingOf(context).top,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: ValueListenableBuilder<InputCheckReport>(
                valueListenable: probe.report,
                builder: (context, report, _) => _Readout(report: report),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.report});

  final InputCheckReport report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: scheme.onInverseSurface,
          decoration: TextDecoration.none,
        );
    return DecoratedBox(
      decoration:
          BoxDecoration(color: scheme.inverseSurface.withValues(alpha: 0.85)),
      child: Padding(
        padding: const EdgeInsets.all(PantasSpace.s4),
        child: DefaultTextStyle(
          style: style ?? const TextStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._lines('Drag', report.drag),
              ..._lines('Fling', report.fling),
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> _lines(String name, InputWindow? w) {
  if (w == null) return [Text('$name: nothing measured yet')];
  final share = w.movedShare;
  return [
    Text(
      '$name: drawn ${w.framesPerSecond.round()}/s, '
      'screen ${w.vsyncsPerSecond.round()}/s, '
      'touch ${w.movesPerSecond.round()}/s in '
      '${w.batchesPerSecond.round()} batches/s',
    ),
    Text(
      '  list moved in ${share == null ? 'no' : '${(share * 100).round()}%'}'
      ' of drawn frames, did not move on ${w.vsyncsWithoutMove} '
      'of ${w.vsyncs} screen frames',
    ),
  ];
}
