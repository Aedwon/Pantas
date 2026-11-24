import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:pantas/core/ui/ds.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';

/// The line under the top bar, split into one segment per `##` section
/// (spec "Section line"). Each segment is as long as its section, with 3 px
/// between them. The one being read fills as you read. A segment is a
/// button: on hover or focus it thickens from 2 to 4 px over 100 ms and its
/// name shows below after 100 ms. A click or Enter takes the page there.
class ReaderSectionLine extends StatelessWidget {
  const ReaderSectionLine({
    required this.titles,
    required this.weights,
    required this.fills,
    required this.onJump,
    super.key,
  });

  /// One name for each section.
  final List<String> titles;

  /// How long each section is. Only the proportions matter.
  final List<double> weights;

  /// How much of each segment is filled, from 0 to 1.
  final ValueListenable<List<double>> fills;
  final ValueChanged<int> onJump;

  /// The line itself is 2 px high, thickened to 4 on hover.
  static const double rest = 2;
  static const double hovered = 4;

  /// The hit area is 16 px tall (spec).
  // ds-board: fs.css .prog, 16 px hit area
  static const double hit = PantasSpace.s16;
  // ds-board: fs.css .prog, 3 px between segments
  static const double gap = 3;

  @override
  Widget build(BuildContext context) {
    if (titles.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: hit,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < titles.length; i++) ...[
            if (i > 0) const SizedBox(width: gap),
            Expanded(
              flex: ((i < weights.length ? weights[i] : 1) * 1000)
                  .round()
                  .clamp(1, 1 << 30),
              child: _Segment(
                key: ValueKey(('section-segment', i)),
                title: titles[i],
                index: i,
                fills: fills,
                onJump: onJump,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatefulWidget {
  const _Segment({
    required this.title,
    required this.index,
    required this.fills,
    required this.onJump,
    super.key,
  });
  final String title;
  final int index;
  final ValueListenable<List<double>> fills;
  final ValueChanged<int> onJump;

  @override
  State<_Segment> createState() => _SegmentState();
}

class _SegmentState extends State<_Segment> {
  bool _hover = false;
  bool _focus = false;
  bool _tip = false;
  bool _tipMounted = false;
  Timer? _delay;
  Timer? _gone;

  bool get _active => _hover || _focus;

  void _sync() {
    _delay?.cancel();
    if (_active) {
      _gone?.cancel();
      _tipMounted = true;
      // ds-board: MO scene 4, the name shows after 100 ms
      _delay = Timer(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _tip = true);
      });
    } else {
      _tip = false;
      // The name stays in the tree only while it shows or fades out.
      // ds-board: the name leaves over 100 ms
      _gone = Timer(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _tipMounted = false);
      });
    }
  }

  @override
  void dispose() {
    _delay?.cancel();
    _gone?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    // ds-board: MO scene 4, the segment and its name take 100 ms
    const hover = Duration(milliseconds: 100);
    final quick = still ? Duration.zero : hover;
    return Semantics(
      button: true,
      label: widget.title,
      onTap: () => widget.onJump(widget.index),
      excludeSemantics: true,
      child: MouseRegion(
        onEnter: (_) => setState(() {
          _hover = true;
          _sync();
        }),
        onExit: (_) => setState(() {
          _hover = false;
          _sync();
        }),
        child: FocusableActionDetector(
          mouseCursor: SystemMouseCursors.click,
          onShowFocusHighlight: (v) => setState(() {
            _focus = v;
            _sync();
          }),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onJump(widget.index);
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => widget.onJump(widget.index),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: webKeyboardInput,
                  builder: (context, keyboard, _) => AnimatedContainer(
                    duration: quick,
                    curve: PantasCurves.enter,
                    height: _active
                        ? ReaderSectionLine.hovered
                        : ReaderSectionLine.rest,
                    decoration: BoxDecoration(
                      color: c.fill,
                      border: _focus && keyboard
                          ? Border.all(color: c.accent, width: 2)
                          : null,
                    ),
                    child: ValueListenableBuilder<List<double>>(
                      valueListenable: widget.fills,
                      builder: (context, fills, _) => Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: widget.index < fills.length
                              ? fills[widget.index].clamp(0.0, 1.0)
                              : 0,
                          heightFactor: 1,
                          child: ColoredBox(color: c.accent),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_tipMounted)
                  Positioned(
                    top: ReaderSectionLine.hit / 2 + 10,
                    child: IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _tip ? 1 : 0,
                        duration: quick,
                        curve: PantasCurves.enter,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: c.label,
                            borderRadius:
                                BorderRadius.circular(PantasRadius.sm),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: PantasSpace.s10,
                              vertical: PantasSpace.s6,
                            ),
                            child: Text(
                              widget.title,
                              maxLines: 1,
                              softWrap: false,
                              style: PantasType.webSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: c.background,
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
        ),
      ),
    );
  }
}

/// The shared ease, for a click that takes the page to a section.
const sectionJumpCurve = PantasCurves.move;
const sectionJumpDuration = Duration(milliseconds: 400);
