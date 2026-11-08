import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';

/// The three IconButton sizes of design system 4.0.
enum PantasIconButtonSize {
  /// 44 (`size-icon-btn`), `radius-md`, 20 px icon.
  standard(PantasSize.iconBtn, PantasRadius.md, PantasSize.icon),

  /// 40 (`size-icon-btn-md`), `radius-md`, 20 px icon.
  md(PantasSize.iconBtnMd, PantasRadius.md, PantasSize.icon),

  /// 32 (`size-icon-btn-sm`), `radius-sm`, 18 px icon. Its touch target is
  /// 44 px.
  sm(PantasSize.iconBtnSm, PantasRadius.sm, PantasSpace.s18);

  const PantasIconButtonSize(this.dimension, this.radius, this.icon);
  final double dimension;
  final double radius;
  final double icon;
}

/// A square, icon-only button with a rounded-rectangle highlight (design
/// system 4.0, IconButton).
///
/// Give it a glyph ([glyph], any Phosphor Regular glyph) or an [icon] widget,
/// and always a [tooltip]: it is the accessible name. With [toggled] set the
/// button is a toggle: the outline glyph when off, the Fill glyph and
/// `accent` when on (D190), so color is never the only cue. A toggle needs a
/// [glyph].
class PantasIconButton extends StatelessWidget {
  const PantasIconButton({
    required this.tooltip,
    required this.onPressed,
    this.glyph,
    this.icon,
    this.size = PantasIconButtonSize.standard,
    this.accent = false,
    this.toggled,
    super.key,
  })  : assert(
          (glyph == null) != (icon == null),
          'Give a glyph or an icon, not both',
        ),
        assert(toggled == null || glyph != null, 'A toggle needs a glyph');

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData? glyph;
  final Widget? icon;
  final PantasIconButtonSize size;

  /// The teal variant: the icon rests in `accent`.
  final bool accent;

  /// Null for a plain button; false or true for a toggle.
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark
        ? PantasColors.dark
        : PantasColors.light;
    final on = toggled ?? false;
    final tinted = accent || on;
    final rest = tinted ? c.accent : c.textSecondary;
    final hover = tinted ? c.accentHover : c.textPrimary;
    final still = MediaQuery.disableAnimationsOf(context);
    final shown = glyph == null
        ? icon!
        : Icon(on ? PantasIcons.fill(glyph!) : glyph, size: size.icon);
    final radius = BorderRadius.circular(size.radius);
    final button = IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: size.icon,
      constraints: BoxConstraints.tightFor(
        width: size.dimension,
        height: size.dimension,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.standard,
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        animationDuration: still ? Duration.zero : PantasDurations.short2,
        fixedSize: WidgetStatePropertyAll(Size.square(size.dimension)),
        minimumSize: WidgetStatePropertyAll(Size.square(size.dimension)),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        side: const WidgetStatePropertyAll(BorderSide.none),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: radius),
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? c.textDisabled
              : s.contains(WidgetState.hovered) ||
                      s.contains(WidgetState.pressed)
                  ? hover
                  : rest,
        ),
        backgroundColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return Colors.transparent;
          final washed = s.contains(WidgetState.hovered) ||
              s.contains(WidgetState.pressed);
          return washed
              ? (s.contains(WidgetState.hovered) ? hover : rest)
                  .withValues(alpha: PantasOpacity.hover)
              : Colors.transparent;
        }),
      ),
      icon: shown,
    );
    Widget out = OffsetFocusRing(
      borderRadius: radius,
      child: PressScale(
        scale: pantasPressScale,
        enabled: onPressed != null,
        child: button,
      ),
    );
    if (size.dimension < PantasSize.targetTouch) {
      out = TouchTarget(alignment: Alignment.center, square: true, child: out);
    }
    if (toggled != null) {
      out = MergeSemantics(child: Semantics(toggled: on, child: out));
    }
    return out;
  }
}
