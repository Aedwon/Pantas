import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class StateView extends StatelessWidget {
  const StateView({
    required this.message,
    this.onRetry,
    this.error,
    this.icon,
    super.key,
  }) : fullScreen = false;
  const StateView.fullScreen({required this.onRetry, this.error, super.key})
      : message = 'Something went wrong.',
        fullScreen = true,
        icon = null;
  final String message;
  final VoidCallback? onRetry;
  // Error is deliberately not rendered. Callers keep diagnostic handling.
  final Object? error;
  final Widget? icon;
  final bool fullScreen;
  @override
  Widget build(BuildContext context) {
    final mark = IconTheme(
      data: IconThemeData(
        size: fullScreen ? 38 : 60,
        color: context.colors.chevron,
      ),
      child: icon ?? PantasIcons.progressError,
    );
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (fullScreen)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.colors.fill,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: mark,
          )
        else
          mark,
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.type.sectionHero.copyWith(
            fontSize: fullScreen ? 24 : 20,
            height: fullScreen ? 1.25 : 1.35,
            letterSpacing: fullScreen ? -.288 : -.2,
          ),
        ),
        if (fullScreen) ...[
          const SizedBox(height: 14),
          Text(
            "Nothing you've done is lost.",
            textAlign: TextAlign.center,
            style: context.type.subhead.copyWith(
              fontSize: 16,
              color: context.colors.secondaryLabel,
              height: 1.45,
            ),
          ),
        ] else if (onRetry != null) ...[
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: PantasButton(
              label: 'Try Again',
              variant: PantasButtonVariant.secondary,
              height: 44,
              fontSize: 15,
              radius: 99,
              onPressed: onRetry,
            ),
          ),
        ],
      ],
    );
    if (!fullScreen) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: content,
      );
    }
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(36),
            child: content,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
          child: PantasButton(label: 'Try Again', onPressed: onRetry),
        ),
      ),
    );
  }
}
