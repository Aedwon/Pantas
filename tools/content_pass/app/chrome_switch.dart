import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';

import 'motion.dart';
import 'palette.dart';

/// One segment of a [ChromeSwitch]: words, or an icon with a name.
class SwitchSegment {
  const SwitchSegment.text(String this.label)
      : icon = null,
        tooltip = null,
        quarterTurns = 0;
  const SwitchSegment.icon(
    IconData this.icon,
    String this.tooltip, {
    this.quarterTurns = 0,
  }) : label = null;

  final String? label;
  final IconData? icon;
  final int quarterTurns;
  final String? tooltip;

  String get name => label ?? tooltip!;
}

const _trackHeight = 28.0;
const _pad = 2.0;
const _labelStyle = TextStyle(
  fontFamily: 'Geist',
  fontSize: 12,
  fontWeight: FontWeight.w600,
);

/// The reviewer's segmented switch, built like the app's SegmentedSwitch: a
/// recessed track with 2px padding, and a thumb that slides to the selection.
/// The thumb is filled green with white text.
class ChromeSwitch extends StatelessWidget {
  const ChromeSwitch({
    required this.palette,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final Palette palette;
  final List<SwitchSegment> segments;
  final int selected;
  final ValueChanged<int> onChanged;

  /// A switch that does not apply keeps its place, dimmed and inert.
  final bool enabled;

  static double _width(SwitchSegment s) {
    if (s.icon != null) return 36;
    final painter = TextPainter(
      text: TextSpan(text: s.label, style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width.ceilToDouble() + 24;
  }

  @override
  Widget build(BuildContext context) {
    final widths = [for (final s in segments) _width(s)];
    var left = _pad;
    final lefts = <double>[];
    for (final w in widths) {
      lefts.add(left);
      left += w;
    }
    final total = left + _pad;
    final slide = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 280);
    final index = selected.clamp(0, segments.length - 1);
    return AnimatedOpacity(
      duration: chromeDuration(context, 160),
      opacity: enabled ? 1 : 0.4,
      child: ExcludeFocus(
        excluding: !enabled,
        child: IgnorePointer(
          ignoring: !enabled,
          child: SizedBox(
            width: total,
            height: _trackHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: palette.track,
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: slide,
                  curve: PantasCurves.popA,
                  left: lefts[index],
                  width: widths[index],
                  top: _pad,
                  bottom: _pad,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      color: thumbGreen,
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                  ),
                ),
                for (var i = 0; i < segments.length; i++)
                  Positioned(
                    left: lefts[i],
                    width: widths[i],
                    top: _pad,
                    bottom: _pad,
                    child: _Segment(
                      palette: palette,
                      segment: segments[i],
                      selected: i == index,
                      onTap: () => onChanged(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.palette,
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  final Palette palette;
  final SwitchSegment segment;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : palette.muted;
    final content = TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: chromeDuration(context, 160),
      builder: (context, c, _) => Center(
        child: segment.icon != null
            ? RotatedBox(
                quarterTurns: segment.quarterTurns,
                child: Icon(segment.icon, size: 17, color: c),
              )
            : Text(
                segment.label!,
                maxLines: 1,
                style: _labelStyle.copyWith(
                  color: c,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
      ),
    );
    final body = HoverFill(
      hover: selected ? Colors.transparent : palette.hover,
      builder: (context, _) => SizedBox.expand(child: content),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: segment.name,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: segment.tooltip == null
            ? body
            : Tooltip(
                message: segment.tooltip,
                waitDuration: const Duration(milliseconds: 500),
                child: body,
              ),
      ),
    );
  }
}
