import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/components/pantas_logo.dart';
import 'package:pantas/core/ui/components/pantas_page.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The setup rail belongs to onboarding, outside the signed-in sidebar shell.
class OnboardingWebPage extends StatelessWidget {
  const OnboardingWebPage({
    required this.title,
    required this.children,
    required this.onBack,
    this.detail,
    this.progress,
    this.bottom,
    this.bodyGap = 28,
    this.centerBody = false,
    this.surfaceBackground = false,
    this.detailLineHeight = 1.4,
    this.width = 580,
    super.key,
  });
  final String title;
  final String? detail;
  final int? progress;
  final VoidCallback? onBack;
  final List<Widget> children;
  final Widget? bottom;
  final double bodyGap;
  final bool centerBody;
  final bool surfaceBackground;
  final double detailLineHeight;
  final double width;

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
    return CallbackShortcuts(
      bindings: {
        if (primary?.onPressed != null && !primary!.busy)
          const SingleActivator(LogicalKeyboardKey.enter): primary.onPressed!,
      },
      child: Material(
        color: t.colors.background,
        child: Column(
          children: [
            const WebTopBar(
              leading: PantasLogo(size: 28),
              title: Text(
                'Pantas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(40, 40, 40, 60),
                child: Center(
                  child: SizedBox(
                    width: width + (width > 580 ? 264 : 280),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 56),
                            child: Semantics(
                              label: 'Setup steps',
                              container: true,
                              explicitChildNodes: true,
                              child: Column(
                                children: [
                                  for (final (i, label) in const [
                                    'Birth year',
                                    'Terms',
                                    'Your exam',
                                    'Exam date',
                                    'Study days',
                                    'Your name',
                                  ].indexed)
                                    SizedBox(
                                      height: 40,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: i + 1 < (progress ?? 1)
                                                  ? t.colors.accentFill
                                                  : null,
                                              border: Border.all(
                                                color: i + 1 <= (progress ?? 1)
                                                    ? t.colors.accent
                                                    : t.strongDivider,
                                                width:
                                                    i + 1 == progress ? 2 : 1.5,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: i + 1 < (progress ?? 1)
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 12,
                                                    color: Colors.white,
                                                  )
                                                : i + 1 == progress
                                                    ? Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              t.colors.accent,
                                                        ),
                                                      )
                                                    : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            label,
                                            style: t.style(
                                              15,
                                              weight: i + 1 == progress
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: i + 1 == progress
                                                  ? t.colors.label
                                                  : i + 1 < (progress ?? 1)
                                                      ? t.colors.secondaryLabel
                                                      : t.colors.tertiaryLabel,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: width > 580 ? 64 : 80),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: onBack,
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    size: 20,
                                  ),
                                  label: const Text('Back'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: t.colors.accent,
                                    minimumSize: const Size(0, 36),
                                    padding: EdgeInsets.zero,
                                    textStyle: t.style(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                title,
                                style: t
                                    .style(
                                      36,
                                      weight: FontWeight.w700,
                                      height: 1.12,
                                    )
                                    .copyWith(letterSpacing: -.864),
                              ),
                              if (detail != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  detail!,
                                  style: t.style(
                                    17,
                                    height: 1.45,
                                    color: t.colors.secondaryLabel,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 28),
                              ...children,
                              if (bottom != null) ...[
                                const SizedBox(height: 40),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: bottom,
                                ),
                              ],
                            ],
                          ),
                        ),
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
    return CallbackShortcuts(
      bindings: {
        if (primary && onPressed != null && !busy)
          const SingleActivator(LogicalKeyboardKey.enter): onPressed!,
      },
      child: Focus(
        autofocus: primary,
        child: WebButton(
          label: label,
          onPressed: onPressed,
          busy: busy,
          keyHint: primary ? 'Enter' : null,
          variant: primary
              ? WebButtonVariant.primary
              : variant == PantasButtonVariant.neutral
                  ? WebButtonVariant.white
                  : WebButtonVariant.tertiary,
        ),
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
              button,
            if (leading == null) const Spacer(),
            for (final button in buttons
                .where((b) => b.variant == PantasButtonVariant.primary))
              button,
          ],
        ),
      ],
    );
  }
}
