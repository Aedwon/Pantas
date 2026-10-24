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
    this.detail,
    this.actionLabel = 'Try Again',
    this.primaryAction = false,
    this.boardLayout = false,
    this.bookmarkLayout = false,
    super.key,
  })  : fullScreen = false,
        onboardingBlocked = false;
  const StateView.onboardingBlocked({
    required this.message,
    required this.detail,
    required this.icon,
    super.key,
  })  : bookmarkLayout = false,
        fullScreen = false,
        onboardingBlocked = true,
        onRetry = null,
        error = null,
        actionLabel = 'Try Again',
        primaryAction = false,
        boardLayout = false;
  const StateView.fullScreen({required this.onRetry, this.error, super.key})
      : bookmarkLayout = false,
        onboardingBlocked = false,
        message = 'Something went wrong.',
        fullScreen = true,
        icon = null,
        detail = null,
        actionLabel = 'Try Again',
        primaryAction = true,
        boardLayout = false;
  final bool boardLayout;
  final String message;
  final VoidCallback? onRetry;
  // Error is deliberately not rendered. Callers keep diagnostic handling.
  final Object? error;
  final Widget? icon;
  final bool fullScreen;
  final bool onboardingBlocked;
  final bool bookmarkLayout;
  final String? detail;
  final String actionLabel;
  final bool primaryAction;
  @override
  Widget build(BuildContext context) {
    final primary = !fullScreen && primaryAction;
    final compact = primary || boardLayout;
    final gap = onboardingBlocked
        ? 12.0
        : bookmarkLayout
            ? 8.0
            : compact
                ? 6.0
                : 14.0;
    final mark = ExcludeSemantics(
      child: IconTheme(
        key: const ValueKey('state-icon-theme'),
        data: IconThemeData(
          size: bookmarkLayout
              ? 34
              : fullScreen
                  ? 36
                  : compact
                      ? 40
                      : 60,
          color: fullScreen
              ? context.colors.secondaryLabel
              : context.colors.chevron,
        ),
        child: SizedBox.square(
          key: const ValueKey('state-mark'),
          dimension: onboardingBlocked
              ? 72
              : bookmarkLayout
                  ? 34
                  : fullScreen
                      ? 36
                      : compact
                          ? 40
                          : 60,
          child: icon ??
              (fullScreen
                  ? Icon(PantasIcons.appError)
                  : PantasIcons.progressError),
        ),
      ),
    );
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (fullScreen)
          Container(
            key: const ValueKey('state-mark-circle'),
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
        SizedBox(height: gap),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.type.sectionHero.copyWith(
            fontSize: onboardingBlocked
                ? 26
                : bookmarkLayout
                    ? 18
                    : fullScreen
                        ? 24
                        : 20,
            height: fullScreen ? 1.25 : 1.35,
            letterSpacing: onboardingBlocked
                ? -.312
                : bookmarkLayout
                    ? -.216
                    : fullScreen
                        ? -.288
                        : -.2,
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
        ] else ...[
          if (detail != null) ...[
            SizedBox(height: gap),
            Text(
              detail!,
              textAlign: TextAlign.center,
              style: context.type.subhead.copyWith(
                color: context.colors.secondaryLabel,
                fontSize: onboardingBlocked ? 17 : 15,
                letterSpacing: onboardingBlocked ? -.204 : 0,
                height: onboardingBlocked || bookmarkLayout ? 1.35 : 1.45,
              ),
            ),
          ],
          if (primary && onRetry != null) ...[
            const SizedBox(height: 6),
            PantasButton(
              label: actionLabel,
              onPressed: onRetry,
              height: 48,
              fullWidth: false,
              horizontalPadding: 26,
            ),
          ] else if (onRetry != null) ...[
            SizedBox(height: boardLayout ? 6 : 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: PantasButton(
                label: actionLabel,
                variant: PantasButtonVariant.secondary,
                height: 44,
                fontSize: 15,
                radius: 99,
                fullWidth: !boardLayout,
                horizontalPadding: boardLayout ? 22 : 16,
                onPressed: onRetry,
              ),
            ),
          ],
        ],
      ],
    );
    if (onboardingBlocked) return Semantics(liveRegion: true, child: content);
    if (compact) {
      return Semantics(
        liveRegion: true,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.hasBoundedHeight ? constraints.maxHeight : 0,
              ),
              child: Padding(
                key: const ValueKey('state-primary-content'),
                padding: const EdgeInsets.fromLTRB(36, 0, 36, 150),
                child: Center(child: content),
              ),
            ),
          ),
        ),
      );
    }
    if (bookmarkLayout) {
      return Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(36, 70, 36, 0),
          child: content,
        ),
      );
    }
    if (!fullScreen) {
      return Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: content,
        ),
      );
    }
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(36, 8, 36, 120),
                    child: Center(
                      child: Semantics(liveRegion: true, child: content),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.colors.background.withValues(alpha: 0),
                      context.colors.background,
                    ],
                    stops: const [0, .26],
                  ),
                ),
                child: PantasButton(label: actionLabel, onPressed: onRetry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
