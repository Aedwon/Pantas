import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum PantasButtonVariant { primary, secondary, tertiary, destructive }

class PantasButton extends StatefulWidget {
  const PantasButton({
    required this.label,
    this.onPressed,
    this.variant = PantasButtonVariant.primary,
    this.busy = false,
    this.height = 52,
    this.fontSize = 17,
    this.radius = 14,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final PantasButtonVariant variant;
  final bool busy;
  final double height;
  final double fontSize;
  final double radius;
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
    final foreground = !enabled
        ? c.tertiaryLabel
        : solid
            ? variant == PantasButtonVariant.primary &&
                    Theme.of(context).brightness == Brightness.dark
                ? c.surface
                : Colors.white
            : variant == PantasButtonVariant.destructive
                ? c.destructive
                : variant == PantasButtonVariant.secondary &&
                        Theme.of(context).brightness == Brightness.dark
                    ? c.label
                    : c.accent;
    final background = !enabled
        ? c.fill
        : solid
            ? variant == PantasButtonVariant.destructive
                ? c.destructive
                : c.accentFill
            : variant == PantasButtonVariant.secondary
                ? c.accentTint
                : Colors.transparent;
    return AnimatedScale(
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
            minimumSize: WidgetStatePropertyAll(Size(double.infinity, height)),
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(
                horizontal: 16,
                vertical: height == 44 ? 10 : 12,
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
            children: [
              if (busy) ...[
                SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                    value: MediaQuery.disableAnimationsOf(context) ? 1 : null,
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
    );
  }
}
