import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum PantasButtonVariant { primary, secondary, tertiary, destructive }

class PantasButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: TextButton(
        onPressed: busy ? null : onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(double.infinity, height)),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
                horizontal: 16, vertical: height == 44 ? 10 : 12,),
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
                    letterSpacing: fontSize < 17 ? 0 : -.204,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
