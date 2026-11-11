import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// One chip of the QuestionNavigator grid (design system 4.0): a 36 px circle
/// with the question number.
///
/// Blank is the `surface-card` fill with a `border-control` ring and a
/// `text-secondary` number. Answered is the `divider` fill with no ring and a
/// `text-primary` number. Current has the heavy `text-primary` ring and a
/// 700 number. Locked ([enabled] false) is transparent with a `fill` ring and
/// a `text-disabled` number. A flag is an `accent` dot at the top right with
/// a `surface-card` edge, on any state. [name] is the spoken name, which
/// carries the state so color is never the only cue. The chip owns the tap.
class QuestionNavigatorChip extends StatelessWidget {
  const QuestionNavigatorChip({
    required this.number,
    required this.name,
    required this.onTap,
    this.enabled = true,
    this.answered = false,
    this.current = false,
    this.flagged = false,
    super.key,
  });

  final int number;
  final String name;
  final VoidCallback onTap;
  final bool enabled;
  final bool answered;
  final bool current;
  final bool flagged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final border = BorderRadius.circular(PantasRadius.full);
    final side = current
        ? BorderSide(color: c.textPrimary, width: PantasBorder.ringCurrent)
        : !enabled
            ? BorderSide(color: c.fill)
            : answered
                ? BorderSide.none
                : BorderSide(
                    color: c.borderControl,
                    width: PantasBorder.ringStrong,
                  );
    final label = Text(
      '$number',
      style: (current
              ? PantasType.webFieldLabel.copyWith(fontWeight: FontWeight.w700)
              : PantasType.webFieldLabel)
          .copyWith(
        color: !enabled
            ? c.textDisabled
            : answered || current
                ? c.textPrimary
                : c.textSecondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
    return Semantics(
      selected: current,
      button: true,
      enabled: enabled,
      label: name,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: PantasSize.qnav,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: PressScale(
                scale: pantasPressScale,
                enabled: enabled,
                child: OffsetFocusRing(
                  borderRadius: border,
                  child: FocusableActionDetector(
                    enabled: enabled,
                    mouseCursor:
                        enabled ? SystemMouseCursors.click : MouseCursor.defer,
                    actions: {
                      ActivateIntent: CallbackAction<ActivateIntent>(
                        onInvoke: (_) {
                          onTap();
                          return null;
                        },
                      ),
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      excludeFromSemantics: true,
                      onTap: enabled ? onTap : null,
                      child: DecoratedBox(
                        key: const ValueKey('question-chip-fill'),
                        decoration: ShapeDecoration(
                          color: answered
                              ? c.divider
                              : enabled
                                  ? c.surfaceCard
                                  : Colors.transparent,
                          shape: CircleBorder(side: side),
                        ),
                        child: Center(child: label),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (flagged)
              Positioned(
                top: -PantasSpace.s2,
                right: -PantasSpace.s2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c.accent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c.surfaceCard,
                      width: PantasBorder.ringSelected,
                    ),
                  ),
                  child: const SizedBox.square(dimension: PantasSize.flagDot),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
