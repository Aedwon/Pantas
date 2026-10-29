import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

enum PantasButtonVariant { primary, secondary, tertiary, destructive, neutral }

class PantasButton extends StatefulWidget {
  const PantasButton({
    required this.label,
    this.onPressed,
    this.variant = PantasButtonVariant.primary,
    this.busy = false,
    this.height = 52,
    this.fontSize = 17,
    this.radius = 14,
    this.fullWidth = true,
    this.horizontalPadding = 16,
    this.disabledOpacity,
    this.disabledForeground,
    super.key,
  })  : _filterChip = false,
        _chipSelected = false;
  const PantasButton.filterChip({
    required this.label,
    required bool selected,
    this.onPressed,
    super.key,
  })  : _filterChip = true,
        _chipSelected = selected,
        variant = PantasButtonVariant.tertiary,
        busy = false,
        height = 32,
        fontSize = 14,
        radius = 99,
        fullWidth = false,
        horizontalPadding = 14,
        disabledOpacity = null,
        disabledForeground = null;
  final bool _filterChip;
  final bool _chipSelected;
  final String label;
  final VoidCallback? onPressed;
  final PantasButtonVariant variant;
  final bool busy;
  final double height;
  final double fontSize;
  final double radius;
  final bool fullWidth;
  final double horizontalPadding;
  final double? disabledOpacity;
  final Color? disabledForeground;
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

  @override
  Widget build(BuildContext context) {
    if (context.wideWeb && !widget._filterChip) {
      return WebButton(
        label: widget.label,
        onPressed: widget.onPressed,
        busy: widget.busy,
        large: widget.height == 50,
        variant: switch (widget.variant) {
          PantasButtonVariant.primary => WebButtonVariant.primary,
          PantasButtonVariant.secondary => WebButtonVariant.secondary,
          PantasButtonVariant.tertiary => WebButtonVariant.tertiary,
          PantasButtonVariant.destructive => WebButtonVariant.danger,
          PantasButtonVariant.neutral => WebButtonVariant.white,
        },
      );
    }
    final onPressed = widget.onPressed;
    final busy = widget.busy;
    final variant = widget.variant;
    final height = widget.height;
    final radius = widget.radius;
    final fontSize = widget.fontSize;
    final label = widget.label;

    final c = context.colors;
    final enabled = onPressed != null || busy;
    final solid = variant == PantasButtonVariant.primary ||
        variant == PantasButtonVariant.destructive;
    final dimmed = !enabled && widget.disabledOpacity != null;
    final foreground = !enabled && !dimmed
        ? widget.disabledForeground ?? c.tertiaryLabel
        : widget._filterChip
            ? widget._chipSelected
                ? c.surface
                : c.label
            : solid
                ? (variant == PantasButtonVariant.destructive
                    ? c.onDestructive
                    : c.onAccent)
                : variant == PantasButtonVariant.neutral
                    ? c.label
                    : variant == PantasButtonVariant.secondary &&
                            Theme.of(context).brightness == Brightness.dark
                        ? c.label
                        : c.accent;
    final background = !enabled && !dimmed
        ? c.fill
        : widget._filterChip
            ? widget._chipSelected
                ? c.label
                : c.surface
            : solid
                ? variant == PantasButtonVariant.destructive
                    ? c.destructive
                    : c.accentFill
                : variant == PantasButtonVariant.neutral
                    ? c.fill
                    : variant == PantasButtonVariant.secondary
                        ? c.accentTint
                        : context.colors.transparent;
    return Semantics(
      selected: widget._filterChip ? widget._chipSelected : null,
      child: Opacity(
        opacity: dimmed ? widget.disabledOpacity! : 1,
        child: AnimatedScale(
          key: const ValueKey('pantas-button-scale'),
          scale: MediaQuery.disableAnimationsOf(context)
              ? 1
              : _pressed
                  ? .97
                  : 1,
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 140),
          curve: PantasCurves.ease,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: TextButton(
              statesController: _states,
              onPressed: busy ? null : onPressed,
              style: ButtonStyle(
                tapTargetSize: widget._filterChip
                    ? MaterialTapTargetSize.shrinkWrap
                    : null,
                minimumSize: WidgetStatePropertyAll(
                  Size(widget.fullWidth ? double.infinity : 0, height),
                ),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: widget.horizontalPadding,
                    vertical: widget._filterChip
                        ? 0
                        : height == 44
                            ? 10
                            : 12,
                  ),
                ),
                backgroundColor: WidgetStatePropertyAll(background),
                foregroundColor: WidgetStatePropertyAll(foreground),
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
                overlayColor:
                    WidgetStatePropertyAll(foreground.withValues(alpha: .08)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize:
                    widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (busy) ...[
                    SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                        value:
                            MediaQuery.disableAnimationsOf(context) ? 1 : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: context.type.emphasized.copyWith(
                        color: foreground,
                        fontSize: fontSize,
                        letterSpacing: fontSize < 17 ? 0 : -.204,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
