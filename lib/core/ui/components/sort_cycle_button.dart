import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum SortCycleOrder { weakest, strongest, alphabetical }

class SortCycleButton extends StatefulWidget {
  const SortCycleButton({
    required this.value,
    required this.onChanged,
    super.key,
  });
  final SortCycleOrder value;
  final ValueChanged<SortCycleOrder> onChanged;

  @override
  State<SortCycleButton> createState() => _SortCycleButtonState();
}

class _SortCycleButtonState extends State<SortCycleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  late SortCycleOrder _from;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(SortCycleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _from = oldWidget.value;
      if (MediaQuery.disableAnimationsOf(context)) {
        _motion.value = 1;
      } else {
        _motion.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  void _cycle() =>
      widget.onChanged(SortCycleOrder.values[(widget.value.index + 1) % 3]);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final label = switch (widget.value) {
      SortCycleOrder.weakest => 'Weakest first',
      SortCycleOrder.strongest => 'Strongest first',
      SortCycleOrder.alphabetical => 'A to Z',
    };
    return Semantics(
      label: 'Sort: $label',
      button: true,
      onTap: _cycle,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: _cycle,
          onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
          borderRadius: BorderRadius.circular(10),
          child: SizedBox.square(
            dimension: 44,
            child: Center(
              child: AnimatedScale(
                scale: _pressed && !still ? .88 : 1,
                duration: still
                    ? Duration.zero
                    : Duration(milliseconds: _pressed ? 120 : 220),
                curve: PantasCurves.easeOut,
                child: DecoratedBox(
                  key: const ValueKey('sort-square'),
                  decoration: BoxDecoration(
                    color: colors.fill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox.square(
                    dimension: 36,
                    child: AnimatedBuilder(
                      animation: _motion,
                      builder: (context, child) {
                        final ms = (still ? 1 : _motion.value) * 520;
                        final toLetters =
                            widget.value == SortCycleOrder.alphabetical;
                        final fromLetters =
                            _from == SortCycleOrder.alphabetical;
                        final fade = PantasCurves.houseOut.transform(
                          (ms / (toLetters ? 220 : 300)).clamp(0.0, 1.0),
                        );
                        final barsOpacity = toLetters
                            ? 1 - fade
                            : fromLetters
                                ? fade
                                : 1.0;
                        final barsScale = toLetters
                            ? 1 - .4 * fade
                            : fromLetters
                                ? .6 + .4 * fade
                                : 1.0;
                        final rotation = toLetters
                            ? -20 * fade
                            : fromLetters
                                ? -20 * (1 - fade)
                                : 0.0;
                        final letterProgress = PantasCurves.popB.transform(
                          ((ms - (toLetters ? 120 : 0)) /
                                  (toLetters ? 300 : 200))
                              .clamp(0.0, 1.0),
                        );
                        final lettersOpacity = toLetters
                            ? letterProgress.clamp(0.0, 1.0)
                            : fromLetters
                                ? (1 - letterProgress).clamp(0.0, 1.0)
                                : 0.0;
                        final lettersScale = toLetters
                            ? .6 + .4 * letterProgress
                            : 1 - .4 * letterProgress;
                        final morph = PantasCurves.houseOut
                            .transform((ms / 520).clamp(0.0, 1.0));
                        final fromStrong = _from != SortCycleOrder.weakest;
                        final toStrong = widget.value != SortCycleOrder.weakest;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Opacity(
                              opacity: barsOpacity,
                              child: Transform.rotate(
                                angle: rotation * math.pi / 180,
                                child: Transform.scale(
                                  scale: barsScale,
                                  child: SizedBox(
                                    width: 14,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (var i = 0; i < 3; i++) ...[
                                          if (i > 0) const SizedBox(height: 3),
                                          SizedBox(
                                            key: ValueKey('sort-bar-$i'),
                                            width: (fromStrong
                                                    ? 14 - 4 * i
                                                    : 6 + 4 * i) +
                                                ((toStrong
                                                            ? 14 - 4 * i
                                                            : 6 + 4 * i) -
                                                        (fromStrong
                                                            ? 14 - 4 * i
                                                            : 6 + 4 * i)) *
                                                    morph,
                                            height: 2.4,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: colors.label,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Opacity(
                              key: const ValueKey('sort-alphabet-opacity'),
                              opacity: lettersOpacity,
                              child: Transform.scale(
                                scale: lettersScale,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'A–Z',
                                    style: context.type.footnote.copyWith(
                                      color: colors.label,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -.26,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
    );
  }
}
