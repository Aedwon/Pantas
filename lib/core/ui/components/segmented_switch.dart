import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/components/pro_tag.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// A track wider than its row scrolls sideways (SegmentedControl README) and
/// keeps the selected segment in view, so the chosen view is never the one
/// scrolled off.
class _SelectedInView extends StatefulWidget {
  const _SelectedInView({
    required this.selected,
    required this.count,
    required this.width,
    required this.child,
  });

  final int selected;
  final int count;
  final double width;
  final Widget child;

  @override
  State<_SelectedInView> createState() => _SelectedInViewState();
}

class _SelectedInViewState extends State<_SelectedInView> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _reveal(animate: false));
  }

  @override
  void didUpdateWidget(_SelectedInView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Centers the selected segment in the row, as far as the track allows.
  void _reveal({bool animate = true}) {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    final cell = (widget.width - PantasSpace.s4) / widget.count;
    final center = PantasSpace.s2 + cell * (widget.selected + .5);
    final target = (center - position.viewportDimension / 2)
        .clamp(0.0, position.maxScrollExtent);
    if (!animate || MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpTo(target);
    } else {
      unawaited(
        _controller.animateTo(
          target,
          duration: PantasDurations.flip,
          curve: PantasCurves.house,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: widget.width, child: widget.child),
      );
}

class SegmentedSwitch extends StatelessWidget {
  const SegmentedSwitch({
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.proMarks = const [],
    super.key,
  })  : bookmarks = false,
        enabled = true,
        assert(
          labels.length > 1,
          'A segmented switch needs two or more labels.',
        ),
        assert(
          selected >= 0 && selected < labels.length,
          'Selected segment must exist.',
        );

  const SegmentedSwitch.bookmarks({
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    super.key,
  })  : bookmarks = true,
        proMarks = const [];
  final bool bookmarks;
  final bool enabled;

  /// Segment indexes that carry the Pro mark after their label (a Free
  /// student's locked views, as on the wide switch).
  final List<int> proMarks;
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  /// The label of a segment: `web-label` 14, 600 selected and 500 not.
  static TextStyle _label(Color color, {required bool selected}) =>
      PantasType.webLabel.copyWith(
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: color,
      );

  static List<BoxShadow> _segmentShadow(BuildContext context) =>
      context.shadows.segment;

  @override
  Widget build(BuildContext context) {
    if (bookmarks) return _bookmarks(context);
    if (context.wideWeb) {
      return WebSegmentedControl(
        labels: labels,
        selected: selected,
        onChanged: onChanged,
      );
    }
    final colors = context.colors;
    final textScaler = MediaQuery.textScalerOf(context);
    final fontSize = PantasType.webLabel.fontSize!;
    final lineHeight = PantasType.webLabel.height!;
    final large = textScaler.scale(fontSize) > PantasSpace.s20;
    // The thumb is as tall as a segment's label box: 32 px (`icon-btn-sm`),
    // or the scaled line plus its padding. It sits in the middle of the 44 px
    // touch target, so the hit area is real and the drawn segment is smaller.
    final box = math.max<double>(
      PantasSize.iconBtnSm,
      textScaler.scale(fontSize) * lineHeight +
          (large ? PantasSpace.s12 : PantasSpace.s0),
    );
    final inset = math.max<double>(0, (PantasSize.targetTouch - box) / 2);
    final radius = BorderRadius.circular(PantasRadius.sm);
    // Every label stays on one line; the track is as wide as the widest label
    // needs, and scrolls when the labels do not fit the row (ruling 1).
    double natural(String label) {
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: _label(colors.textOnFill, selected: true),
        ),
        textDirection: Directionality.of(context),
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    // The Pro mark is its own text on a 6 px side padding, 6 px after the
    // label.
    double markWidth() {
      final painter = TextPainter(
        text: const TextSpan(text: 'Pro', style: PantasType.webPro),
        textDirection: Directionality.of(context),
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      final width = painter.width + PantasSpace.s12 + PantasSpace.s6;
      painter.dispose();
      return width;
    }

    final contents = [
      for (final (i, label) in labels.indexed)
        natural(label) + (proMarks.contains(i) ? markWidth() : 0),
    ];
    final widest = contents.reduce(math.max) + PantasSpace.s24;
    // Each segment keeps 4 px of padding on both sides (`_segment`).
    const minPad = PantasSpace.s8;
    final proportional = [for (final c in contents) c + minPad];
    return LayoutBuilder(
      builder: (context, constraints) {
        final equalNeed = widest * labels.length + PantasSpace.s4;
        final bounded = constraints.hasBoundedWidth;
        // Equal columns when they fit. If they do not, but every segment
        // still fits at its own natural width, the columns share the row in
        // proportion to their labels: a Free student's Subjects, Topics (Pro)
        // and Lessons (Pro) fit a phone row without scrolling and without
        // cutting a Pro mark. Only then does the track scroll.
        final shared = bounded &&
            equalNeed > constraints.maxWidth &&
            proportional.reduce((a, b) => a + b) + PantasSpace.s4 <=
                constraints.maxWidth;
        final need = equalNeed;
        final scrolls = bounded && !shared && need > constraints.maxWidth;
        final weights =
            shared ? proportional : List<double>.filled(labels.length, 1);
        final weightSum = weights.reduce((a, b) => a + b);
        final track = Stack(
          children: [
            Positioned.fill(
              top: PantasSpace.s6,
              bottom: PantasSpace.s6,
              child: DecoratedBox(
                key: const ValueKey('segmented-switch-track'),
                decoration: BoxDecoration(
                  color: colors.fill,
                  borderRadius: radius,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(PantasSpace.s2),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cells = [
                    for (final w in weights)
                      constraints.maxWidth * w / weightSum,
                  ];
                  final offsets = <double>[];
                  var run = 0.0;
                  for (final cell in cells) {
                    offsets.add(run);
                    run += cell;
                  }
                  return Stack(
                    children: [
                      // One thumb slides under the labels (item 17, demo 7):
                      // 240 ms on the shared ease. Only a translation changes.
                      Positioned.fill(
                        child: ExcludeSemantics(
                          child: IgnorePointer(
                            child: SlidingMarker(
                              key: const ValueKey('segmented-switch-thumb'),
                              offsets: offsets,
                              lengths: cells,
                              index: selected,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: inset),
                                child: DecoratedBox(
                                  key: const ValueKey('segment-thumb'),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceSegmentOn,
                                    borderRadius: radius,
                                    boxShadow: _segmentShadow(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < labels.length; i++)
                            Expanded(
                              flex: (weights[i] * 1000).round(),
                              child: _segment(context, i, large, radius),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
        if (!scrolls) return track;
        return _SelectedInView(
          selected: selected,
          count: labels.length,
          width: need,
          child: track,
        );
      },
    );
  }

  Widget _segment(
    BuildContext context,
    int i,
    bool large,
    BorderRadius radius,
  ) {
    final colors = context.colors;
    return Semantics(
      selected: i == selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: WebKeyboardRing(
        borderRadius: radius,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onChanged(i),
            borderRadius: radius,
            hoverColor: i == selected
                ? Colors.transparent
                : colors.textPrimary.withValues(alpha: PantasOpacity.hover),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: PantasSize.targetTouch,
              ),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  key: ValueKey('segment-$i'),
                  constraints: const BoxConstraints(
                    minHeight: PantasSize.iconBtnSm,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: PantasSpace.s4,
                      vertical: large ? PantasSpace.s6 : PantasSpace.s0,
                    ),
                    child: Center(
                      heightFactor: 1,
                      child: FadingColor(
                        color: i == selected
                            ? colors.textPrimary
                            : colors.textOnFill,
                        builder: (context, color, _) {
                          final label = Text(
                            labels[i],
                            maxLines: 1,
                            softWrap: false,
                            textAlign: TextAlign.center,
                            style: _label(color, selected: i == selected),
                          );
                          if (!proMarks.contains(i)) return label;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              label,
                              const SizedBox(width: PantasSpace.s6),
                              const ProMark(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bookmarks(BuildContext context) {
    final c = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(PantasRadius.sm);
    return AnimatedOpacity(
      duration: still ? Duration.zero : PantasDurations.fade,
      curve: PantasCurves.house,
      opacity: enabled ? 1 : PantasOpacity.disabled,
      child: ExcludeFocus(
        excluding: !enabled,
        child: IgnorePointer(
          ignoring: !enabled,
          child: Semantics(
            enabled: enabled,
            child: Stack(
              children: [
                Positioned.fill(
                  top: PantasSpace.s6,
                  bottom: PantasSpace.s6,
                  child: DecoratedBox(
                    key: const ValueKey('segmented-switch-track'),
                    decoration: BoxDecoration(
                      color: c.fill,
                      borderRadius: radius,
                    ),
                  ),
                ),
                Positioned.fill(
                  left: PantasSpace.s2,
                  right: PantasSpace.s2,
                  top: PantasSpace.s8,
                  bottom: PantasSpace.s8,
                  child: AnimatedAlign(
                    key: const ValueKey('bookmark-sort-position'),
                    alignment: Alignment(
                      -1 + 2 * selected / (labels.length - 1),
                      0,
                    ),
                    duration: still ? Duration.zero : PantasDurations.flip,
                    curve: PantasCurves.house,
                    child: FractionallySizedBox(
                      widthFactor: 1 / labels.length,
                      heightFactor: 1,
                      child: DecoratedBox(
                        key: const ValueKey('bookmark-sort-pill'),
                        decoration: BoxDecoration(
                          color: c.surfaceSegmentOn,
                          borderRadius: radius,
                          boxShadow: _segmentShadow(context),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(PantasSpace.s2),
                  child: Row(
                    children: [
                      for (var i = 0; i < labels.length; i++)
                        Expanded(
                          child: Semantics(
                            selected: i == selected,
                            child: WebKeyboardRing(
                              borderRadius: radius,
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkWell(
                                  onTap: enabled ? () => onChanged(i) : null,
                                  borderRadius: radius,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: PantasSize.targetTouch,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: PantasSpace.s4,
                                        vertical: PantasSpace.s6,
                                      ),
                                      child: Center(
                                        heightFactor: 1,
                                        child: Text(
                                          labels[i],
                                          textAlign: TextAlign.center,
                                          style: _label(
                                            c.textPrimary,
                                            selected: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
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
