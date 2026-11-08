import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// Explains why a list is empty or that loading failed, and offers the next
/// step (design system: EmptyState, ErrorState). One centered `.state`
/// column: a 40 point `icon-muted` icon, the title (`web-h3` on wide screens,
/// `phone-title-3` on the phone), one line in `text-secondary` at most 360
/// wide, then at most one action 8 lower. Never red: the icon, the title and
/// the line say what happened.
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
    this.bookmarkTop = _bookmarkTop,
    this.plainMessage = false,
    super.key,
  })  : fullScreen = false,
        onboardingBlocked = false;
  const StateView.onboardingBlocked({
    required this.message,
    required this.detail,
    required this.icon,
    super.key,
  })  : bookmarkLayout = false,
        bookmarkTop = _bookmarkTop,
        fullScreen = false,
        onboardingBlocked = true,
        onRetry = null,
        error = null,
        actionLabel = 'Try Again',
        primaryAction = false,
        plainMessage = false,
        boardLayout = false;
  const StateView.fullScreen({required this.onRetry, this.error, super.key})
      : bookmarkLayout = false,
        bookmarkTop = _bookmarkTop,
        onboardingBlocked = false,
        message = 'Something went wrong.',
        fullScreen = true,
        icon = null,
        detail = null,
        actionLabel = 'Try Again',
        primaryAction = true,
        plainMessage = false,
        boardLayout = false;

  /// The phone sets the bookmark block 70 down.
  static const double _bookmarkTop = PantasSpace.s56 + PantasSpace.s14;

  final bool boardLayout;

  /// Board RD_Error: a 17 px regular message and a 28 px gray mark.
  final bool plainMessage;
  final String message;
  final VoidCallback? onRetry;
  // Error is deliberately not rendered. Callers keep diagnostic handling.
  final Object? error;
  final Widget? icon;
  final bool fullScreen;
  final bool onboardingBlocked;
  final bool bookmarkLayout;

  /// Space above the bookmark block. The phone sets it 70 px down; a wide
  /// panel centers the block itself, so it passes 0.
  final double bookmarkTop;
  final String? detail;
  final String actionLabel;
  final bool primaryAction;

  /// The label of the retry action of an error state.
  static const String _retryLabel = 'Try Again';

  /// The icon is a square of this size.
  static const double _markSize = PantasSpace.s40;

  /// The line under the title is at most this wide.
  static const double _textMax = PantasLayout.colListMax;

  /// Room the floating bar takes at the bottom of a centered state.
  static const double _barReserve = PantasLayout.reserveBar;

  @override
  Widget build(BuildContext context) {
    if (fullScreen && context.wideWeb) {
      return WebFullNotice(
        title: message,
        lead: "Nothing you've done is lost.",
        actionLabel: actionLabel,
        onPressed: onRetry,
      );
    }
    final colors = context.colors;
    final wide = context.wideWeb;
    final primary = !fullScreen && primaryAction;
    final compact = primary || boardLayout;
    final titleStyle = (wide ? PantasType.webH3 : PantasType.phoneTitle3)
        .copyWith(color: colors.textPrimary);
    final lineStyle = (wide ? PantasType.webSub : PantasType.phoneCallout)
        .copyWith(color: colors.textSecondary);
    // The retry action marks an error state. Any other action belongs to an
    // empty list and keeps its natural width.
    final isError = icon == null && actionLabel == _retryLabel;
    final mark = ExcludeSemantics(
      child: IconTheme(
        key: const ValueKey('state-icon-theme'),
        data: IconThemeData(size: _markSize, color: colors.iconMuted),
        child: SizedBox.square(
          key: const ValueKey('state-mark'),
          dimension: _markSize,
          child: icon ??
              (fullScreen
                  ? Icon(PantasIcons.appError)
                  : PantasIcons.progressError),
        ),
      ),
    );
    final line = fullScreen ? "Nothing you've done is lost." : detail;
    final Widget? action;
    if (fullScreen) {
      action = null;
    } else if (onRetry == null) {
      action = null;
    } else {
      // Natural width, centered under the text. An error fills the phone's
      // width up to the text measure.
      final button = PantasButton(
        label: actionLabel,
        variant: primary
            ? PantasButtonVariant.primary
            : PantasButtonVariant.secondary,
        height: PantasSize.btn,
        fontSize: PantasType.webLink.fontSize,
        radius: PantasRadius.full,
        fullWidth: isError && !wide && !primary,
        horizontalPadding: PantasSpace.s24,
        onPressed: onRetry,
      );
      action = isError && !wide && !primary
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _textMax),
              child: button,
            )
          : button;
    }
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(height: PantasSpace.s12),
        Text(message, textAlign: TextAlign.center, style: titleStyle),
        if (line != null) ...[
          const SizedBox(height: PantasSpace.s12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _textMax),
            child: Text(line, textAlign: TextAlign.center, style: lineStyle),
          ),
        ],
        if (action != null) ...[
          const SizedBox(height: PantasSpace.s12 + PantasSpace.s8),
          action,
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
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s24,
                  PantasSpace.s0,
                  PantasSpace.s24,
                  _barReserve,
                ),
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
          padding: EdgeInsets.fromLTRB(
            PantasSpace.s24,
            bookmarkTop,
            PantasSpace.s24,
            PantasSpace.s0,
          ),
          child: content,
        ),
      );
    }
    if (!fullScreen) {
      return Semantics(
        liveRegion: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PantasSpace.s24,
            vertical: PantasSpace.s56,
          ),
          child: content,
        ),
      );
    }
    return Scaffold(
      backgroundColor: colors.bgPage,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PantasSpace.s24,
                      PantasSpace.s8,
                      PantasSpace.s24,
                      _barReserve,
                    ),
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
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s14,
                  PantasSpace.s16,
                  PantasSpace.s32,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [colors.bgPage.withValues(alpha: 0), colors.bgPage],
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
