import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/onboarding_frame.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_key_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// Space between Back and the title on every wide step.
const double titleTopGap = PantasSpace.s28;

/// The setup rail belongs to onboarding, outside the signed-in sidebar shell.
class OnboardingWebPage extends StatelessWidget {
  const OnboardingWebPage({
    required this.title,
    required this.children,
    required this.onBack,
    this.detail,
    this.progress,
    this.bottom,
    this.bodyGap = PantasSpace.s28,
    this.gap = PantasSpace.s28,
    this.bottomGap = PantasSpace.s40,
    this.centerBody = false,
    this.surfaceBackground = false,
    this.detailLineHeight = 1.4,
    this.topPadding = PantasSpace.s4,
    this.focusTarget,
    super.key,
  });
  final String title;
  final String? detail;
  final int? progress;
  final VoidCallback? onBack;
  final List<Widget> children;
  final Widget? bottom;
  final double bodyGap;

  /// Web only: space between the title block and the body. The title keeps one
  /// place on every step, so the frame stays still (Nov 2 decision).
  final double gap;

  /// Web only: space above the action row.
  final double bottomGap;
  final bool centerBody;
  final bool surfaceBackground;
  final double detailLineHeight;

  /// Phone only: space between the progress bar and the title.
  final double topPadding;

  /// Web only: the step's text field. The field is drawn as the active input,
  /// so it is the one that holds focus, and typing works with no click first.
  final FocusNode? focusTarget;

  @override
  Widget build(BuildContext context) {
    if (!context.wideWeb) {
      return PantasPage.onboarding(
        title: title,
        detail: detail,
        progress: progress,
        onBack: onBack,
        bottom: bottom,
        bodyGap: bodyGap,
        centerBody: centerBody,
        surfaceBackground: surfaceBackground,
        detailLineHeight: detailLineHeight,
        topPadding: topPadding,
        children: children,
      );
    }
    final t = context.webTokens;
    final actions = bottom is OnboardingActions
        ? (bottom! as OnboardingActions).children
        : [if (bottom != null) bottom!];
    final primary = actions
        .whereType<OnboardingButton>()
        .where((button) => button.variant == PantasButtonVariant.primary)
        .firstOrNull;
    final host = OnboardingFrameScope.hostOf(context);
    // The step's keys stand on one node that keeps focus (see KeyFocusKeeper):
    // a step that slides in cannot take focus when it is built, and a mouse
    // click never gives focus to a plain control.
    final column = KeyFocusKeeper(
      skipTraversal: true,
      preferred: focusTarget,
      child: _column(context),
    );
    final shortcuts = <ShortcutActivator, VoidCallback>{
      if (primary?.onPressed != null && !primary!.busy)
        const SingleActivator(
          LogicalKeyboardKey.enter,
          includeRepeats: false,
        ): primary.onPressed!,
    };
    if (host != null) {
      // The top bar and steps list stay on screen in the onboarding frame.
      return OnboardingFrameClaim(
        host: host,
        spec: OnboardingFrameSpec(progress: progress),
        onBack: onBack,
        child: OnboardingShortcuts(bindings: shortcuts, child: column),
      );
    }
    return OnboardingShortcuts(
      bindings: shortcuts,
      child: Material(
        color: t.colors.background,
        child: Column(
          children: [
            const OnboardingTopBar(logoInset: false),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s40,
                  PantasSpace.s40,
                  PantasSpace.s40,
                  onboardingActionsMargin,
                ),
                child: Center(
                  child: SizedBox(
                    width: onboardingFrameWidth,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: onboardingRailWidth,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: PantasSpace.s56),
                            child: OnboardingRail(progress: progress),
                          ),
                        ),
                        const SizedBox(width: onboardingRailGap),
                        Expanded(child: column),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Back, title, detail, body and actions: the part that changes per step.
  Widget _column(BuildContext context) {
    final t = context.webTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: WebBackLink(
            label: 'Back',
            onPressed: onBack ?? () {},
            nudge: false,
          ),
        ),
        const SizedBox(height: titleTopGap),
        Text(
          title,
          style: t.h1,
        ),
        if (detail != null) ...[
          const SizedBox(height: PantasSpace.s8),
          Text(
            detail!,
            style: PantasType.webLead.copyWith(color: t.colors.textSecondary),
          ),
        ],
        SizedBox(height: gap),
        ...children,
        if (bottom != null) ...[
          SizedBox(height: bottomGap),
          StickyActions(
            background: t.colors.background,
            separator: t.colors.separator,
            clearance: bottomGap,
            child: Align(alignment: Alignment.centerRight, child: bottom),
          ),
        ],
      ],
    );
  }
}

/// Keeps the phone button unchanged and uses the shared web button on desktop.
class OnboardingButton extends StatelessWidget {
  const OnboardingButton({
    required this.label,
    this.onPressed,
    this.busy = false,
    this.variant = PantasButtonVariant.primary,
    super.key,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final PantasButtonVariant variant;
  @override
  Widget build(BuildContext context) {
    if (!context.wideWeb) {
      return PantasButton(
        label: label,
        onPressed: onPressed,
        busy: busy,
        variant: variant,
      );
    }
    final primary = variant == PantasButtonVariant.primary;
    return OnboardingShortcuts(
      bindings: {
        if (primary && onPressed != null && !busy)
          const SingleActivator(
            LogicalKeyboardKey.enter,
            includeRepeats: false,
          ): onPressed!,
      },
      child: WebButton(
        label: label,
        onPressed: onPressed,
        busy: busy,
        tall: true,
        keyHint: primary ? 'Enter' : null,
        variant: primary
            ? WebButtonVariant.primary
            : variant == PantasButtonVariant.neutral
                ? WebButtonVariant.white
                : WebButtonVariant.tertiary,
      ),
    );
  }
}

class OnboardingActions extends StatelessWidget {
  const OnboardingActions({required this.children, this.leading, super.key});
  final Widget? leading;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    if (!context.wideWeb) {
      return Column(mainAxisSize: MainAxisSize.min, children: children);
    }
    final buttons = children.whereType<OnboardingButton>().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...children.where((w) => w is! OnboardingButton && w is! SizedBox),
        Row(
          children: [
            if (leading != null) Expanded(child: leading!),
            for (final button in buttons
                .where((b) => b.variant != PantasButtonVariant.primary))
              if (leading == null &&
                  button.variant != PantasButtonVariant.neutral)
                Transform.translate(
                  offset: const Offset(-PantasSpace.s16, 0),
                  child: button,
                )
              else
                button,
            if (leading == null) const Spacer(),
            if (leading != null && buttons.length > 1)
              const SizedBox(width: PantasSpace.s8),
            for (final button in buttons
                .where((b) => b.variant == PantasButtonVariant.primary))
              button,
          ],
        ),
      ],
    );
  }
}

/// Registers onboarding keys as shortcuts for web text inputs.
class OnboardingShortcuts extends StatelessWidget {
  const OnboardingShortcuts({
    required this.bindings,
    required this.child,
    super.key,
  });
  final Map<ShortcutActivator, VoidCallback> bindings;
  final Widget child;

  @override
  Widget build(BuildContext context) => Shortcuts(
        shortcuts: {
          for (final entry in bindings.entries)
            entry.key: VoidCallbackIntent(entry.value),
        },
        child: Actions(
          actions: {VoidCallbackIntent: VoidCallbackAction()},
          child: child,
        ),
      );
}
