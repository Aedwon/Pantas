import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

enum FloatingBarState { neutral, right, wrong }

// QV_Answer's status surface is quieter than a selected-choice tint.

class FloatingBar extends StatelessWidget {
  const FloatingBar({
    required this.left,
    required this.counter,
    required this.right,
    this.state = FloatingBarState.neutral,
    this.beforeCounter,
    this.afterCounter,
    super.key,
  })  : content = null,
        radius = PantasRadius.bar,
        inset = PantasSpace.s8,
        transitionDuration = null,
        transitionCurve = Curves.linear;

  /// QN_Report and QN_WrongOpen replace the row with a growing form.
  const FloatingBar.content({
    required Widget child,
    this.state = FloatingBarState.neutral,
    this.radius = PantasRadius.bar,
    this.inset = PantasSpace.s8,
    this.transitionDuration,
    this.transitionCurve = Curves.linear,
    super.key,
  })  : content = child,
        beforeCounter = null,
        afterCounter = null,
        left = const SizedBox.shrink(),
        counter = '',
        right = const SizedBox.shrink();

  final Widget? content;

  /// Phone only (MK_Paper): controls grouped with the counter in the middle.
  final Widget? beforeCounter;
  final Widget? afterCounter;
  final double radius;
  final double inset;
  final Duration? transitionDuration;
  final Curve transitionCurve;
  final Widget left;
  final String counter;
  final Widget right;
  final FloatingBarState state;
  static const contentBottomInset = PantasLayout.reserveBarPhone;
  @override
  Widget build(BuildContext context) {
    if (context.wideWeb && content == null) {
      return WebBottomBar(
        counter: counter,
        leading: left,
        action: right,
        state: switch (state) {
          FloatingBarState.neutral => WebBarState.neutral,
          FloatingBarState.right => WebBarState.right,
          FloatingBarState.wrong => WebBarState.wrong,
        },
      );
    }
    final c = context.colors;
    final color = switch (state) {
      FloatingBarState.neutral => c.surfaceCard,
      FloatingBarState.right => c.accentBar,
      FloatingBarState.wrong => c.dangerBar
    };
    return AnimatedContainer(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : transitionDuration ??
              (state == FloatingBarState.neutral
                  ? PantasDurations.fade
                  : PantasDurations.flip),
      curve: transitionCurve,
      constraints: const BoxConstraints(minHeight: PantasSize.bar),
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: context.shadows.bar,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: state == FloatingBarState.neutral
              ? c.edgeBar
              : (state == FloatingBarState.right ? c.accent : c.danger)
                  .withValues(alpha: PantasOpacity.barRing),
        ),
      ),
      child: TextButtonTheme(
        data: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize:
                const Size(PantasSize.targetTouch, PantasSize.targetTouch),
            padding: const EdgeInsets.symmetric(
              horizontal: PantasSpace.s12,
              vertical: PantasSpace.s10,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        child: content ??
            Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    heightFactor: 1,
                    child: left,
                  ),
                ),
                if (beforeCounter != null) beforeCounter!,
                Text(
                  counter,
                  style: PantasType.webLink.copyWith(
                    color: c.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (afterCounter != null) afterCounter!,
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    heightFactor: 1,
                    child: right,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
