import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/button_pair.dart';
import 'package:pantas/core/ui/components/pantas_button.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_curves.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

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
  final Widget? editor;
  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 350);
    final content = Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.separator),
        borderRadius: BorderRadius.circular(14),
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
                    minimumSize: const Size(44, 52),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icon ?? PantasIcons.addDate,
                        size: 18,
                        color: iconColor ?? context.colors.secondaryLabel,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: context.type.subhead.copyWith(
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (detail != null) ...[
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: expanded ? .25 : 0,
                          duration: duration,
                          curve: PantasCurves.houseOut,
                          child: Icon(
                            PantasIcons.next,
                            size: 15,
                            color: context.colors.chevron,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                key: const ValueKey('notice-close'),
                width: 44,
                height: 44,
                child: IconButton(
                  onPressed: onClose,
                  tooltip: 'Dismiss',
                  icon: Icon(
                    PantasIcons.close,
                    size: 14,
                    color: context.colors.secondaryLabel,
                  ),
                ),
              ),
            ],
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: expanded ? 1 : 0, end: expanded ? 1 : 0),
            duration: duration,
            curve: PantasCurves.houseOut,
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
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (detail != null)
                    Text(
                      detail!,
                      style: context.type.footnote.copyWith(height: 1.4),
                    ),
                  if (editor != null) ...[
                    const SizedBox(height: 12),
                    editor!,
                  ],
                  if (primaryLabel != null && secondaryLabel != null) ...[
                    const SizedBox(height: 12),
                    ButtonPair(
                      primary: PantasButton(
                        label: primaryLabel!,
                        variant: PantasButtonVariant.secondary,
                        onPressed: onPrimary,
                        height: 44,
                        fontSize: 15,
                        radius: 12,
                      ),
                      secondary: PantasButton(
                        label: secondaryLabel!,
                        variant: PantasButtonVariant.tertiary,
                        onPressed: onSecondary,
                        height: 44,
                        fontSize: 15,
                        radius: 12,
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
      curve: PantasCurves.houseOut,
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
