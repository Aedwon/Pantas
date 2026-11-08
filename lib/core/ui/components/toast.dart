import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_shadows.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';

// The toast uses the inverted `toast-bg` and `toast-text` pair in both themes.

/// Confirms the result of an action for a few seconds, with an optional
/// action such as Undo (design system: Toast). Entering takes
/// `PantasDurations.fade` and rises 16, leaving takes `flip` and falls 8,
/// both on `PantasCurves.house`. Under reduced motion it only fades over
/// `short2`.
class Toast extends StatelessWidget {
  const Toast({
    required this.message,
    this.onUndo,
    this.keyHint,
    this.visible = true,
    this.web = false,
    super.key,
  });

  /// Wide web layout: intrinsic width and a padded pill-less surface.
  final bool web;
  final String message;
  final String? keyHint;
  final VoidCallback? onUndo;
  final bool visible;

  /// How far the toast rises as it enters.
  static const double _enterRise = PantasSpace.s16;

  /// How far the toast falls as it leaves.
  static const double _exitFall = PantasSpace.s8;

  /// `.toast--phone` keeps 13 on the sides of the message (phone board).
  static const double _phoneInsetY = PantasSpace.s12 + 1;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = MediaQuery.disableAnimationsOf(context);
    final messageStyle =
        (web ? PantasType.webRowValue : PantasType.phoneSubhead)
            .copyWith(color: colors.toastText);
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: still ? (visible ? 1 : 0) : 0,
        end: visible ? 1 : 0,
      ),
      duration: still
          ? PantasDurations.short2
          : visible
              ? PantasDurations.fade
              : PantasDurations.flip,
      curve: still ? PantasCurves.fade : PantasCurves.house,
      builder: (context, value, child) => ExcludeFocus(
        excluding: !visible,
        child: IgnorePointer(
          ignoring: !visible,
          child: ExcludeSemantics(
            excluding: !visible,
            child: Opacity(
              opacity: value,
              child: Transform.translate(
                key: const ValueKey('toast-rise'),
                offset: Offset(
                  0,
                  still ? 0 : (visible ? _enterRise : _exitFall) * (1 - value),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: web
              ? const EdgeInsets.fromLTRB(
                  PantasSpace.s18,
                  PantasSpace.s4,
                  PantasSpace.s6,
                  PantasSpace.s4,
                )
              : const EdgeInsets.symmetric(
                  horizontal: PantasSpace.s16,
                  vertical: _phoneInsetY,
                ),
          decoration: BoxDecoration(
            color: colors.toastBg,
            borderRadius: BorderRadius.circular(PantasRadius.lg),
            boxShadow: context.shadows.toast,
          ),
          child: Row(
            mainAxisSize: web ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Flexible(
                fit: !web && onUndo != null ? FlexFit.tight : FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: PantasSpace.s8,
                  ),
                  child: Text(message, style: messageStyle),
                ),
              ),
              if (web && onUndo != null) const SizedBox(width: PantasSpace.s14),
              if (keyHint != null) ...[
                const SizedBox(width: PantasSpace.s14),
                WebKeyHint(keyHint!, onButton: true),
              ],
              if (onUndo != null) _ToastAction(onPressed: onUndo!),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Undo control: 44 high, `toast-action` text, a white tint on hover,
/// a 0.97 press and the 2px accent ring for keyboard focus.
class _ToastAction extends StatelessWidget {
  const _ToastAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(PantasRadius.sm);
    return OffsetFocusRing(
      borderRadius: radius,
      child: PressScale(
        scale: .97,
        child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            minimumSize: const WidgetStatePropertyAll(
              Size(PantasSize.targetTouch, PantasSize.targetTouch),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(
                horizontal: PantasSpace.s10,
                vertical: PantasSpace.s6,
              ),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.standard,
            foregroundColor: WidgetStatePropertyAll(colors.toastAction),
            overlayColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.hovered)
                  ? colors.toastActionHover
                  : Colors.transparent,
            ),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: radius),
            ),
          ),
          child: Text(
            'Undo',
            style: PantasType.webLink.copyWith(color: colors.toastAction),
          ),
        ),
      ),
    );
  }
}
