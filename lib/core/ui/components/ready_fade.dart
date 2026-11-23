import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_colors.dart';

/// Blends a primary action from its disabled colors to its ready colors when
/// the form behind it becomes valid: 300 ms in all, the first third held (so
/// the color moves for 200 ms). A new [serial] replays the blend. Shared by
/// the note form and the report form (QN_WrongOpen and QN_Report: the Send
/// button turns teal over 200 ms once there is text).
class ReadyFade extends StatelessWidget {
  const ReadyFade({required this.serial, required this.child, super.key});

  /// Changes each time the action becomes ready.
  final int serial;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      key: ValueKey(serial),
      tween: Tween(begin: 0, end: 1),
      duration: reduced ? Duration.zero : const Duration(milliseconds: 300),
      builder: (context, progress, child) {
        final blend = const Interval(1 / 3, 1).transform(progress);
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            extensions: [
              for (final extension in theme.extensions.values)
                if (extension is PantasColors)
                  colors.copyWith(
                    accentFill: Color.lerp(
                      colors.fill,
                      colors.accentFill,
                      blend,
                    ),
                    onAccent: Color.lerp(
                      colors.textDisabled,
                      colors.onAccent,
                      blend,
                    ),
                  )
                else
                  extension,
            ],
          ),
          child: child!,
        );
      },
      child: child,
    );
  }
}
