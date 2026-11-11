import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_opacity.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';

/// The press scale of every design system 4.0 button: 0.97 over `dur-short-1`,
/// back over `dur-short-3` (`PressScale` and `AnimatedScale` read it).
const double pantasPressScale = .97;

/// The four kinds of Button plus the white button the boards draw
/// (design system 4.0, Button).
enum PantasButtonKind { primary, secondary, neutral, tertiary, white }

/// The two tones. A null tone is the kind's default: accent for primary and
/// secondary, gray for tertiary, and the only choice for neutral and white.
enum PantasButtonTone { accent, critical }

/// The size classes of the Button table.
enum PantasButtonSize {
  /// `btn--xs`: 36, the header button.
  xs,

  /// `btn`: 44.
  standard,

  /// `btn--sm`: 42.
  sm,

  /// `btn--lg`: 50.
  lg,

  /// `btn--bar`: 46, a pill when filled.
  bar,

  /// `btn--dialog`: 46, a pill when filled, half of a pair.
  dialog,

  /// `btn--notice`: 44, half of a notice pair.
  notice,

  /// `btn--pill-sm`: 44, a pill when filled.
  pillSm,

  /// `btn--phone`: 52, full width.
  phone,
}

/// True for the kind by tone pairs the matrix allows. Neutral and white have
/// no tone; primary and secondary take accent or critical; tertiary takes the
/// default, accent or critical.
bool pantasButtonPairAllowed(PantasButtonKind kind, PantasButtonTone? tone) =>
    tone == null ||
    (kind != PantasButtonKind.neutral && kind != PantasButtonKind.white);

/// The radius the height rule gives: under 40 `radius-sm`, 40 to 44
/// `radius-md`, 46 and up `radius-lg`.
double pantasButtonRadiusForHeight(double height) =>
    height < PantasSize.iconBtnMd
        ? PantasRadius.sm
        : height < PantasSize.btnBar
            ? PantasRadius.md
            : PantasRadius.lg;

/// The measurements of one size class for one kind.
@immutable
class PantasButtonMetrics {
  const PantasButtonMetrics({
    required this.height,
    required this.radius,
    required this.padLeft,
    required this.padRight,
    required this.gap,
    required this.style,
    required this.fullWidth,
  });

  /// The minimum height. The button grows at large text.
  final double height;

  /// [PantasRadius.full] for a pill.
  final double radius;
  final double padLeft;
  final double padRight;

  /// Between the icon, the label and the key hint.
  final double gap;
  final TextStyle style;
  final bool fullWidth;

  bool get pill => radius >= PantasRadius.full;

  OutlinedBorder shape({BorderSide side = BorderSide.none}) => pill
      ? StadiumBorder(side: side)
      : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: side,
        );
}

/// Measurements for a size class and a kind.
///
/// [heightOverride] stands in for a board that draws a different height (a
/// 40 or 48 button); the radius then follows the height rule. [keyHint] is
/// true when a visible hint follows the label.
PantasButtonMetrics pantasButtonMetrics(
  PantasButtonSize size,
  PantasButtonKind kind, {
  double? heightOverride,
  bool keyHint = false,
}) {
  final tertiary = kind == PantasButtonKind.tertiary;
  final h = heightOverride;
  final base = switch (size) {
    PantasButtonSize.xs => const PantasButtonMetrics(
        height: PantasSize.btnXs,
        radius: PantasRadius.sm,
        padLeft: PantasSpace.s10,
        padRight: PantasSpace.s8,
        gap: PantasSpace.s8,
        style: PantasType.webLabel,
        fullWidth: false,
      ),
    PantasButtonSize.standard => const PantasButtonMetrics(
        height: PantasSize.btn,
        radius: PantasRadius.md,
        padLeft: PantasSpace.s20,
        padRight: PantasSpace.s20,
        gap: PantasSpace.s8,
        style: PantasType.webButton,
        fullWidth: false,
      ),
    PantasButtonSize.sm => const PantasButtonMetrics(
        height: PantasSize.btnSm,
        radius: PantasRadius.md,
        padLeft: PantasSpace.s18,
        padRight: PantasSpace.s18,
        gap: PantasSpace.s8,
        style: PantasType.webButton,
        fullWidth: false,
      ),
    PantasButtonSize.lg => const PantasButtonMetrics(
        height: PantasSize.btnLg,
        radius: PantasRadius.lg,
        padLeft: PantasSpace.s20,
        padRight: PantasSpace.s20,
        gap: PantasSpace.s8,
        style: PantasType.webButtonLg,
        fullWidth: false,
      ),
    PantasButtonSize.bar => PantasButtonMetrics(
        height: PantasSize.btnBar,
        radius: tertiary ? PantasRadius.lg : PantasRadius.full,
        // D72: the floating-bar padding is 22 and 14 beside a hint.
        padLeft: PantasSpace.s20 + PantasSpace.s2,
        padRight: keyHint ? PantasSpace.s14 : PantasSpace.s20 + PantasSpace.s2,
        gap: PantasSpace.s10,
        style: PantasType.webButton,
        fullWidth: false,
      ),
    PantasButtonSize.dialog => PantasButtonMetrics(
        height: PantasSize.btnBar,
        radius: tertiary ? PantasRadius.lg : PantasRadius.full,
        padLeft: PantasSpace.s12,
        padRight: PantasSpace.s12,
        gap: PantasSpace.s8,
        style: PantasType.webButton,
        fullWidth: false,
      ),
    PantasButtonSize.notice => const PantasButtonMetrics(
        height: PantasSize.btn,
        radius: PantasRadius.md,
        padLeft: PantasSpace.s12,
        padRight: PantasSpace.s12,
        gap: PantasSpace.s8,
        style: PantasType.webLink,
        fullWidth: false,
      ),
    PantasButtonSize.pillSm => PantasButtonMetrics(
        height: PantasSize.btn,
        radius: tertiary ? PantasRadius.md : PantasRadius.full,
        padLeft: PantasSpace.s20,
        padRight: PantasSpace.s20,
        gap: PantasSpace.s8,
        style: PantasType.webLink,
        fullWidth: false,
      ),
    PantasButtonSize.phone => const PantasButtonMetrics(
        height: PantasSize.btnPhone,
        radius: PantasRadius.lg,
        padLeft: PantasSpace.s20,
        padRight: PantasSpace.s20,
        gap: PantasSpace.s8,
        style: PantasType.phoneHeadline,
        fullWidth: true,
      ),
  };
  if (h == null || h == base.height) return base;
  return PantasButtonMetrics(
    height: h,
    radius: base.pill ? base.radius : pantasButtonRadiusForHeight(h),
    padLeft: base.padLeft,
    padRight: base.padRight,
    gap: base.gap,
    style: base.style,
    fullWidth: base.fullWidth,
  );
}

/// The colors of one kind by tone in one state, every slot a role.
@immutable
class PantasButtonPalette {
  const PantasButtonPalette({
    required this.fill,
    required this.label,
    required this.hoverFill,
    required this.hoverLabel,
    this.ring,
  });

  final Color fill;
  final Color label;
  final Color hoverFill;
  final Color hoverLabel;

  /// The 1px control ring of white or the 1.5px ring of secondary critical.
  final BorderSide? ring;
}

/// The colors for [kind] and [tone]. A disabled button is `fill` with the
/// `text-disabled` label; tertiary and secondary critical stay transparent.
/// Hover washes are the label color at `opacity-hover` (R4-O05).
PantasButtonPalette pantasButtonPalette(
  PantasColors c,
  PantasButtonKind kind,
  PantasButtonTone? tone, {
  required bool enabled,
}) {
  final critical = tone == PantasButtonTone.critical;
  final accent = tone == PantasButtonTone.accent;
  Color wash(Color label, [Color base = Colors.transparent]) =>
      Color.alphaBlend(label.withValues(alpha: PantasOpacity.hover), base);

  if (!enabled) {
    final clear = kind == PantasButtonKind.tertiary ||
        (kind == PantasButtonKind.secondary && critical);
    final fill = clear ? Colors.transparent : c.fill;
    return PantasButtonPalette(
      fill: fill,
      label: c.textDisabled,
      hoverFill: fill,
      hoverLabel: c.textDisabled,
    );
  }
  switch (kind) {
    case PantasButtonKind.primary:
      return critical
          ? PantasButtonPalette(
              fill: c.dangerFill,
              label: c.onDanger,
              hoverFill: c.dangerFillHover,
              hoverLabel: c.onDanger,
            )
          : PantasButtonPalette(
              fill: c.accentFill,
              label: c.onAccent,
              hoverFill: c.accentFillHover,
              hoverLabel: c.onAccent,
            );
    case PantasButtonKind.secondary:
      return critical
          ? PantasButtonPalette(
              fill: Colors.transparent,
              label: c.dangerText,
              hoverFill: wash(c.dangerTextHover),
              hoverLabel: c.dangerTextHover,
              ring: BorderSide(
                color: c.danger,
                width: PantasBorder.ringStrong,
              ),
            )
          : PantasButtonPalette(
              fill: c.accentTint,
              label: c.accentTintText,
              hoverFill: c.accentTintHover,
              hoverLabel: c.accentHover,
            );
    case PantasButtonKind.neutral:
      return PantasButtonPalette(
        fill: c.fill,
        label: c.textPrimary,
        hoverFill: wash(c.textPrimary, c.fill),
        hoverLabel: c.textPrimary,
      );
    case PantasButtonKind.tertiary:
      final label = critical
          ? c.dangerText
          : accent
              ? c.accent
              : c.textSecondary;
      final hover = critical
          ? c.dangerTextHover
          : accent
              ? c.accentHover
              : c.textPrimary;
      return PantasButtonPalette(
        fill: Colors.transparent,
        label: label,
        hoverFill: wash(hover),
        hoverLabel: hover,
      );
    case PantasButtonKind.white:
      return PantasButtonPalette(
        fill: c.surfaceCard,
        label: c.textPrimary,
        hoverFill: c.surfaceHover,
        hoverLabel: c.textPrimary,
        // `border-ring` is 1, the default width of a BorderSide.
        ring: BorderSide(color: c.borderControl),
      );
  }
}
