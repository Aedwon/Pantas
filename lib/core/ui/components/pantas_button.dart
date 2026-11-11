import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/core/ui/components/offset_focus_ring.dart';
import 'package:pantas/core/ui/components/pantas_button_parts.dart';
import 'package:pantas/core/ui/components/pantas_button_spec.dart';
import 'package:pantas/core/ui/motion/press_scale.dart';
import 'package:pantas/core/ui/motion/selection_motion.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// The older names of the button kinds. Each is a kind by tone pair of the
/// design system (see [PantasButton.kind]); new code names the kind and tone.
///
/// On a phone: primary is primary, secondary is secondary, tertiary is
/// tertiary in accent, destructive is primary critical and neutral is
/// neutral. On a wide screen tertiary is the gray tertiary and neutral is
/// the white button the boards draw.
enum PantasButtonVariant { primary, secondary, tertiary, destructive, neutral }

/// The one control for every action (design system 4.0, Button).
///
/// Name a [kind] and a [tone], or keep the older [variant]. A [kind] wins
/// over [variant]. Neutral and white take no tone; primary and secondary take
/// accent (the default) or critical; tertiary takes the default, accent or
/// critical.
class PantasButton extends StatefulWidget {
  const PantasButton({
    required this.label,
    this.onPressed,
    this.variant = PantasButtonVariant.primary,
    this.kind,
    this.tone,
    this.busy = false,
    this.height,
    this.fontSize,
    this.radius,
    this.fullWidth = true,
    this.horizontalPadding,
    this.disabledOpacity,
    this.disabledForeground,
    this.trailing,
    super.key,
  })  : assert(
          kind != null || tone == null,
          'A tone needs a kind',
        ),
        assert(
          tone == null ||
              (kind != PantasButtonKind.neutral &&
                  kind != PantasButtonKind.white),
          'Neutral and white take no tone',
        ),
        _filterChip = false,
        _chipSelected = false;
  const PantasButton.filterChip({
    required this.label,
    required bool selected,
    this.onPressed,
    super.key,
  })  : _filterChip = true,
        _chipSelected = selected,
        variant = PantasButtonVariant.tertiary,
        kind = null,
        tone = null,
        busy = false,
        height = PantasSize.iconBtnSm,
        fontSize = null,
        radius = PantasRadius.full,
        fullWidth = false,
        horizontalPadding = PantasSpace.s14,
        disabledOpacity = null,
        disabledForeground = null,
        trailing = null;
  final bool _filterChip;
  final bool _chipSelected;
  final String label;
  final VoidCallback? onPressed;
  final PantasButtonVariant variant;

  /// The kind. When set it replaces [variant].
  final PantasButtonKind? kind;

  /// The tone. Null is the kind's default.
  final PantasButtonTone? tone;
  final bool busy;

  /// A minimum height other than the phone's 52. The radius then follows the
  /// height rule.
  final double? height;

  /// A label size other than the size class's own. The nearest of the
  /// system's button label styles is used.
  final double? fontSize;

  /// Only a pill request is read: a radius of [PantasRadius.full] or more
  /// asks for the pill that bar, dialog and compact buttons take (filled
  /// kinds only). Any other radius follows the height rule.
  final double? radius;
  final bool fullWidth;
  final double? horizontalPadding;
  final double? disabledOpacity;
  final Color? disabledForeground;

  /// Phone only: drawn 2 px after the label (the question bar's Next chevron).
  final Widget? trailing;

  bool get _pillRequest => radius != null && radius! >= PantasRadius.full;

  /// The kind and tone on a phone.
  (PantasButtonKind, PantasButtonTone?) get _phonePair {
    final k = kind;
    if (k != null) return (k, tone);
    return switch (variant) {
      PantasButtonVariant.primary => (PantasButtonKind.primary, null),
      PantasButtonVariant.secondary => (PantasButtonKind.secondary, null),
      PantasButtonVariant.tertiary => (
          PantasButtonKind.tertiary,
          PantasButtonTone.accent
        ),
      PantasButtonVariant.destructive => (
          PantasButtonKind.primary,
          PantasButtonTone.critical
        ),
      PantasButtonVariant.neutral => (PantasButtonKind.neutral, null),
    };
  }

  /// The kind and tone on a wide screen.
  (PantasButtonKind, PantasButtonTone?) get _widePair {
    final k = kind;
    if (k != null) return (k, tone);
    return switch (variant) {
      PantasButtonVariant.primary => (PantasButtonKind.primary, null),
      PantasButtonVariant.secondary => (PantasButtonKind.secondary, null),
      PantasButtonVariant.tertiary => (PantasButtonKind.tertiary, null),
      PantasButtonVariant.destructive => (
          PantasButtonKind.primary,
          PantasButtonTone.critical
        ),
      PantasButtonVariant.neutral => (PantasButtonKind.white, null),
    };
  }

  PantasButtonSize get _size {
    final h = height ?? PantasSize.btnPhone;
    if (_pillRequest) {
      return h >= PantasSize.btnBar
          ? PantasButtonSize.bar
          : PantasButtonSize.pillSm;
    }
    return h >= PantasSize.btnLg
        ? (h == PantasSize.btnLg ? PantasButtonSize.lg : PantasButtonSize.phone)
        : PantasButtonSize.standard;
  }

  @override
  State<PantasButton> createState() => _PantasButtonState();
}

class _PantasButtonState extends State<PantasButton> {
  bool _pressed = false;
  late final WidgetStatesController _states = WidgetStatesController()
    ..addListener(_statesChanged);
  void _statesChanged() {
    final pressed = _states.value.contains(WidgetState.pressed);
    if (pressed == _pressed || !mounted) return;
    // A child can clear its pressed state while this button is rebuilding.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _statesChanged();
      });
      return;
    }
    setState(() => _pressed = pressed);
  }

  @override
  void dispose() {
    _states
      ..removeListener(_statesChanged)
      ..dispose();
    super.dispose();
  }

  /// The system's label style nearest to a caller's [size].
  TextStyle _styleFor(double size, TextStyle sizeStyle) {
    final link = PantasType.webLink.fontSize!;
    final button = PantasType.webButton.fontSize!;
    if (size <= link) return PantasType.webLink;
    if (size <= button) return PantasType.webButton;
    return sizeStyle.fontSize! >= PantasType.phoneHeadline.fontSize!
        ? sizeStyle
        : PantasType.phoneHeadline;
  }

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb && !widget._filterChip) {
      final (kind, tone) = widget._widePair;
      return WebButton(
        label: widget.label,
        onPressed: widget.onPressed,
        busy: widget.busy,
        kind: kind,
        tone: tone,
        size: widget._size == PantasButtonSize.phone
            ? PantasButtonSize.standard
            : widget._size,
      );
    }
    final onPressed = widget.onPressed;
    final busy = widget.busy;
    final label = widget.label;
    final chip = widget._filterChip;

    final c = context.colors;
    final webFeedback =
        Theme.of(context).splashFactory == NoSplash.splashFactory;
    final still = MediaQuery.disableAnimationsOf(context);
    final enabled = onPressed != null || busy;
    final dimmed = !enabled && widget.disabledOpacity != null;
    final (kind, tone) =
        chip ? (PantasButtonKind.tertiary, null) : widget._phonePair;
    var metrics = pantasButtonMetrics(
      chip ? PantasButtonSize.sm : widget._size,
      kind,
      heightOverride: widget.height,
    );
    if (widget.fontSize != null && !chip) {
      metrics = PantasButtonMetrics(
        height: metrics.height,
        radius: metrics.radius,
        padLeft: metrics.padLeft,
        padRight: metrics.padRight,
        gap: metrics.gap,
        style: _styleFor(widget.fontSize!, metrics.style),
        fullWidth: metrics.fullWidth,
      );
    }
    final palette = pantasButtonPalette(
      c,
      kind,
      tone,
      enabled: enabled || dimmed,
    );
    final rest = !enabled && !dimmed
        ? widget.disabledForeground ?? palette.label
        : palette.label;
    final foreground = chip
        ? enabled
            ? widget._chipSelected
                ? c.surfaceCard
                : c.textPrimary
            : rest
        : rest;
    final background = chip
        ? enabled
            ? widget._chipSelected
                ? c.textPrimary
                : c.surfaceCard
            : c.fill
        : palette.fill;
    final ring = !chip && (enabled || dimmed) ? palette.ring : null;
    final horizontal = widget.horizontalPadding ?? metrics.padLeft;
    final radius = chip ? PantasRadius.full : metrics.radius;
    Widget labelText(Color color) => Text(
          label,
          textAlign: TextAlign.center,
          style: chip
              ? PantasType.webLabel.copyWith(color: color)
              : metrics.style.copyWith(color: color),
        );
    final shape = chip
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))
        : metrics.shape();
    final button = ConstrainedBox(
      constraints: BoxConstraints(minHeight: metrics.height),
      child: TextButton(
        statesController: _states,
        onPressed: busy ? null : onPressed,
        style: ButtonStyle(
          tapTargetSize: chip ? MaterialTapTargetSize.shrinkWrap : null,
          animationDuration: still ? Duration.zero : PantasDurations.short2,
          minimumSize: WidgetStatePropertyAll(
            Size(widget.fullWidth ? double.infinity : 0, metrics.height),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: chip ? PantasSpace.s0 : PantasSpace.s8,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            // A phone layout has no hover: a mouse resting on a button in a
            // narrow browser must not fill it (O_Age). A press shows the
            // hover colors on every layout (`:active`).
            final hovered =
                states.contains(WidgetState.hovered) && context.wideWeb;
            final washed =
                enabled && (hovered || states.contains(WidgetState.pressed));
            if (chip) {
              // A chip's fill is the layer behind the button, which fades.
              if (washed && !widget._chipSelected && webFeedback) {
                return Theme.of(context).hoverColor;
              }
              return Colors.transparent;
            }
            return washed && !dimmed ? palette.hoverFill : background;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            final hovered =
                states.contains(WidgetState.hovered) && context.wideWeb;
            final washed =
                enabled && (hovered || states.contains(WidgetState.pressed));
            return washed && !chip && !dimmed ? palette.hoverLabel : foreground;
          }),
          side: WidgetStatePropertyAll(ring ?? BorderSide.none),
          shape: WidgetStatePropertyAll(shape),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (busy) ...[
              PantasSpinner.inline(color: foreground),
              SizedBox(width: metrics.gap),
            ],
            Flexible(
              child: chip
                  ? FadingColor(
                      color: foreground,
                      builder: (context, color, _) => labelText(color),
                    )
                  : labelText(foreground),
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: PantasSpace.s2),
              IconTheme(
                data: IconThemeData(color: foreground, size: PantasSpace.s16),
                child: widget.trailing!,
              ),
            ],
          ],
        ),
      ),
    );
    // Item 17, demo 5: the fill fades over 160 ms on the ease. Material does
    // not animate a button's own fill, so the chip paints it behind.
    final pressable = chip
        ? FadingColor(
            color: background,
            builder: (context, fill, child) => DecoratedBox(
              key: const ValueKey('chip-fill'),
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.circular(radius),
              ),
              child: child,
            ),
            child: button,
          )
        : button;
    final ringed = OffsetFocusRing(
      borderRadius: BorderRadius.circular(radius),
      child: ButtonWidthLock(busy: busy && !chip, child: pressable),
    );
    return Semantics(
      selected: chip ? widget._chipSelected : null,
      child: Opacity(
        opacity: dimmed ? widget.disabledOpacity! : 1,
        child: chip
            // A chip shrinks to 96% under a press on every build, web
            // included, then springs back (item 17, demo 5).
            ? PressScale(scale: .96, enabled: enabled, child: ringed)
            : AnimatedScale(
                key: const ValueKey('pantas-button-scale'),
                scale: still
                    ? 1
                    : _pressed
                        ? pantasPressScale
                        : 1,
                duration: still
                    ? Duration.zero
                    : _pressed
                        ? PantasDurations.short1
                        : PantasDurations.short3,
                curve: PantasCurves.move,
                child: ringed,
              ),
      ),
    );
  }
}
