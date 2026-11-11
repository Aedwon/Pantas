import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_curves.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_radius.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

/// Which icon color a notice takes. Red is never a notice tone: data loss
/// uses a neutral notice with an icon.
enum NoticeTone { info, success, warning }

/// One message that needs a decision or attention, with a dismiss control
/// (design system: Notice). Surface `surface-card`, radius `radius-lg`, a 1px
/// `divider` ring. The head toggles the detail; the actions sit at the right
/// end on wide screens and side by side on the phone.
class NoticeStrip extends StatelessWidget {
  const NoticeStrip({
    required this.title,
    required this.onClose,
    this.detail,
    this.expanded = false,
    this.visible = true,
    this.onToggle,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.icon,
    this.iconColor,
    this.tone = NoticeTone.info,
    this.editor,
    super.key,
  });
  final String title;
  final String? detail;
  final bool expanded;
  final bool visible;
  final VoidCallback? onToggle;
  final VoidCallback onClose;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData? icon;
  final Color? iconColor;
  final NoticeTone tone;
  final Widget? editor;

  /// The head is at least this high; the title wraps and grows it.
  static const double _headMin = PantasSpace.s44 + PantasSpace.s8;

  /// The dismiss control keeps a 44 point target around its 40 point button.
  static const double _closeTarget = PantasSize.targetTouch;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final wide = context.wideWeb;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : PantasDurations.switchDuration;
    final toneIcon = switch (tone) {
      NoticeTone.info => icon ?? PantasIcons.addDate,
      NoticeTone.success => icon ?? PantasIcons.check,
      NoticeTone.warning => icon ?? PantasIcons.addDate,
    };
    final toneColor = iconColor ??
        switch (tone) {
          NoticeTone.info || NoticeTone.success => colors.accent,
          NoticeTone.warning => colors.warningText,
        };
    final bodyStyle = (wide ? PantasType.webSub : PantasType.phoneFootnote)
        .copyWith(color: colors.textSecondary);
    final radius = BorderRadius.circular(PantasRadius.lg);
    // The 1px ring is a foreground layer that takes no space.
    final content = Container(
      decoration:
          BoxDecoration(color: colors.surfaceCard, borderRadius: radius),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: colors.divider),
        borderRadius: radius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            key: const ValueKey('notice-row'),
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onToggle,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(_closeTarget, _headMin),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(
                      left: PantasSpace.s18,
                      top: PantasSpace.s8,
                      bottom: PantasSpace.s8,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: radius),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        toneIcon,
                        size: PantasSize.icon,
                        color: toneColor,
                      ),
                      const SizedBox(width: PantasSpace.s12),
                      Expanded(
                        child: Text(
                          title,
                          style: PantasType.webTitleSm
                              .copyWith(color: colors.textPrimary),
                        ),
                      ),
                      if (detail != null) ...[
                        const SizedBox(width: PantasSpace.s8),
                        AnimatedRotation(
                          turns: expanded ? .25 : 0,
                          duration: duration,
                          curve: PantasCurves.house,
                          child: Icon(
                            PantasIcons.next,
                            size: PantasSize.icon,
                            color: colors.iconChevron,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                key: const ValueKey('notice-close'),
                width: _closeTarget,
                height: _closeTarget,
                child: IconButton(
                  onPressed: onClose,
                  tooltip: 'Dismiss',
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    PantasIcons.close,
                    size: PantasSize.icon,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: PantasSpace.s4),
            ],
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: expanded ? 1 : 0, end: expanded ? 1 : 0),
            duration: duration,
            curve: PantasCurves.house,
            builder: (context, value, child) => ClipRect(
              child: Align(
                heightFactor: value,
                child: Opacity(
                  opacity: value,
                  child: ExcludeFocus(
                    excluding: !expanded,
                    child: ExcludeSemantics(
                      excluding: !expanded,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                PantasSpace.s18,
                PantasSpace.s0,
                PantasSpace.s18,
                PantasSpace.s16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (detail != null) Text(detail!, style: bodyStyle),
                  if (editor != null) ...[
                    const SizedBox(height: PantasSpace.s12),
                    editor!,
                  ],
                  if (primaryLabel != null && secondaryLabel != null) ...[
                    const SizedBox(height: PantasSpace.s12),
                    if (wide)
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: PantasSpace.s8,
                        runSpacing: PantasSpace.s8,
                        children: [
                          WebButton(
                            label: secondaryLabel!,
                            variant: WebButtonVariant.tertiary,
                            onPressed: onSecondary,
                          ),
                          WebButton(
                            label: primaryLabel!,
                            variant: WebButtonVariant.secondary,
                            onPressed: onPrimary,
                          ),
                        ],
                      )
                    else
                      ButtonPair(
                        gap: PantasSpace.s8,
                        primary: PantasButton(
                          label: primaryLabel!,
                          variant: PantasButtonVariant.secondary,
                          onPressed: onPrimary,
                          height: PantasSize.btn,
                          fontSize: PantasType.webLink.fontSize,
                        ),
                        secondary: PantasButton(
                          label: secondaryLabel!,
                          variant: PantasButtonVariant.tertiary,
                          onPressed: onSecondary,
                          height: PantasSize.btn,
                          fontSize: PantasType.webLink.fontSize,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: visible ? 1 : 0, end: visible ? 1 : 0),
      duration: duration,
      curve: PantasCurves.house,
      builder: (context, value, child) => ClipRect(
        child: Align(
          heightFactor: value,
          child: Opacity(
            opacity: value,
            child: ExcludeFocus(
              excluding: !visible,
              child: ExcludeSemantics(
                excluding: !visible,
                child: IgnorePointer(
                  ignoring: !visible,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
      child: content,
    );
  }
}
