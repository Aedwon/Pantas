import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

enum ListRowVariant {
  navigation,
  value,
  switchControl,
  check,
  radio,
  destructive,
  inlineEditor
}

class ListRow extends StatelessWidget {
  const ListRow({
    required this.title,
    this.variant = ListRowVariant.navigation,
    this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.selected = false,
    this.expanded = false,
    this.editor,
    this.onTap,
    this.divider = false,
    this.richTitle,
    this.footer,
    this.leading,
    this.titleColor,
    this.verticalPadding = 11,
    this.richSubtitle,
    this.valueStyle,
    super.key,
  });
  final String title;
  final ListRowVariant variant;
  final String? value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool selected;
  final bool expanded;
  final Widget? editor;
  final VoidCallback? onTap;
  final bool divider;
  final InlineSpan? richTitle;
  final Widget? footer;
  final Widget? leading;
  final Color? titleColor;
  final double verticalPadding;
  final InlineSpan? richSubtitle;
  final TextStyle? valueStyle;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final stack = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final labelStyle = context.type.body.copyWith(
      color: variant == ListRowVariant.destructive
          ? c.wrongText
          : titleColor ?? c.label,
    );
    final label = Text.rich(
      richTitle ?? TextSpan(text: title),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: labelStyle,
    );
    final detail = value == null
        ? null
        : Text(
            value!,
            style: valueStyle ?? context.type.rowValue,
            textAlign: stack ? TextAlign.start : TextAlign.end,
          );
    final trailing = switch (variant) {
      ListRowVariant.navigation =>
        Icon(PantasIcons.next, size: 16, color: c.chevron),
      ListRowVariant.switchControl => ExcludeSemantics(
          child: ExcludeFocus(
            child: PantasSwitch(
              value: selected,
              label: title,
              onChanged: (_) => onTap?.call(),
            ),
          ),
        ),
      ListRowVariant.check => selected
          ? Icon(PantasIcons.check, size: 20, color: c.accent)
          : const SizedBox(width: 20),
      ListRowVariant.radio => Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? c.accentFill : null,
            border: Border.all(
              color: selected ? c.accent : c.controlOutline,
              width: 1.5,
            ),
          ),
          child: selected
              ? Icon(Icons.circle, size: 8, color: context.colors.onAccent)
              : null,
        ),
      ListRowVariant.inlineEditor => Icon(
          expanded ? PantasIcons.close : PantasIcons.next,
          size: 16,
          color: expanded ? c.accent : c.chevron,
        ),
      _ => const SizedBox.shrink(),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MergeSemantics(
          child: Semantics(
            checked: variant == ListRowVariant.check ||
                    variant == ListRowVariant.radio
                ? selected
                : null,
            toggled: variant == ListRowVariant.switchControl ? selected : null,
            inMutuallyExclusiveGroup: variant == ListRowVariant.radio,
            child: Material(
              color: context.colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: verticalPadding,
                  ),
                  decoration: BoxDecoration(
                    border: divider
                        ? Border(
                            bottom: BorderSide(color: c.separator, width: .5),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 12),
                      ] else if (icon != null) ...[
                        Icon(icon, size: 22, color: iconColor ?? c.accent),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            label,
                            if (subtitle != null || richSubtitle != null)
                              Text.rich(
                                  richSubtitle ?? TextSpan(text: subtitle),
                                  style: context.type.footnote),
                            if (footer != null) footer!,
                            if (stack && detail != null) detail,
                          ],
                        ),
                      ),
                      if (!stack && detail != null) ...[
                        const SizedBox(width: 8),
                        Flexible(child: detail),
                      ],
                      if (variant != ListRowVariant.value &&
                          variant != ListRowVariant.destructive) ...[
                        const SizedBox(width: 8),
                        trailing,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (variant == ListRowVariant.inlineEditor)
          AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 300),
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: editor,
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
