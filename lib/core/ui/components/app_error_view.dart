import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Replaces the framework's error screen in release builds.
///
/// One line, on paper. No stack trace, no error code, no icon and no button:
/// a student can do nothing with any of them, and the framework's red screen
/// is useful to a developer and frightening to everyone else.
///
/// Installed only when [kReleaseMode]. See `installAppErrorView`.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key});

  /// The copy is settled. No apology, no instruction, no code.
  static const message = 'Something went wrong here.';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      color: colors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            message,
            style:
                context.textStyles.bodyLarge.copyWith(color: colors.inkMuted),
          ),
        ),
      ),
    );
  }
}

/// Swaps the framework's red error screen for [AppErrorView].
///
/// Release builds only. The red screen carries the exception and the stack,
/// which is exactly what a developer needs and exactly what a student must
/// never see, so debug keeps it.
void installAppErrorView() {
  if (!kReleaseMode) return;
  ErrorWidget.builder = (_) => const AppErrorView();
}
