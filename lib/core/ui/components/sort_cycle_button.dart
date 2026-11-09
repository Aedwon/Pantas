import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

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

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _motion = AnimationController(
      vsync: this,
      // ds-board: sort morph 520 ms, no token
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
    // The 36 px square follows the height rule (under 40 is `radius-sm`).
    final radius = BorderRadius.circular(
      pantasButtonRadiusForHeight(PantasSize.btnXs),
    );
    return Semantics(
      label: 'Sort: $label',
      button: true,
      onTap: _cycle,
      excludeSemantics: true,
      child: OffsetFocusRing(
        borderRadius: radius,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: _cycle,
            hoverColor: colors.textPrimary.withValues(
              alpha: PantasOpacity.hover,
            ),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            borderRadius: radius,
            child: SizedBox.square(
              dimension: PantasSize.targetTouch,
              child: Center(
                child: PressScale(
                  scale: pantasPressScale,
                  child: DecoratedBox(
                    key: const ValueKey('sort-square'),
                    decoration: BoxDecoration(
                      color: colors.fill,
                      borderRadius: radius,
                    ),
                    child: SizedBox.square(
                      dimension: PantasSize.btnXs,
                      child: AnimatedBuilder(
                        animation: _motion,
                        builder: (context, child) =>
                            _glyph(context, still: still),
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

  /// The three bars and the "A to Z" letters, crossfading as the order
  /// changes.
  Widget _glyph(BuildContext context, {required bool still}) {
    final colors = context.colors;
    final ms = (still ? 1 : _motion.value) * 520;
    final toLetters = widget.value == SortCycleOrder.alphabetical;
    final fromLetters = _from == SortCycleOrder.alphabetical;
    final fade = PantasCurves.house.transform(
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
      ((ms - (toLetters ? 120 : 0)) / (toLetters ? 300 : 200)).clamp(0.0, 1.0),
    );
    final lettersOpacity = toLetters
        ? letterProgress.clamp(0.0, 1.0)
        : fromLetters
            ? (1 - letterProgress).clamp(0.0, 1.0)
            : 0.0;
    final lettersScale =
        toLetters ? .6 + .4 * letterProgress : 1 - .4 * letterProgress;
    final morph = PantasCurves.house.transform((ms / 520).clamp(0.0, 1.0));
    final fromStrong = _from != SortCycleOrder.weakest;
    final toStrong = widget.value != SortCycleOrder.weakest;
    // Strongest first: 14, 10, 6. Weakest first: 6, 10, 14.
    double barWidth({required bool strong, required int i}) => strong
        ? PantasSpace.s14 - PantasSpace.s4 * i
        : PantasSpace.s6 + PantasSpace.s4 * i;
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
                width: PantasSpace.s14,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(height: PantasSpace.s6 / 2),
                      SizedBox(
                        key: ValueKey('sort-bar-$i'),
                        width: barWidth(strong: fromStrong, i: i) +
                            (barWidth(strong: toStrong, i: i) -
                                    barWidth(strong: fromStrong, i: i)) *
                                morph,
                        height: PantasSize.ringStroke,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.textPrimary,
                            borderRadius: BorderRadius.circular(
                              PantasSpace.s2,
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
                style: PantasType.phoneFootnoteStrong.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
