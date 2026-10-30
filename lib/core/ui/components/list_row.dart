import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
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
    this.titleWidget,
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
    this.wrapTitle = false,
    this.minimumHeight = 44,
    this.contentPadding,
    this.leadingGap = 12,
    this.valueWidget,
    this.trailingWidget,
    this.mutuallyExclusive = false,
    super.key,
  })  : content = null,
        _checkbox = false,
        _exam = false,
        comingSoon = false,
        settingsMode = false;
  const ListRow.checkbox({
    required this.title,
    required this.selected,
    required this.onTap,
    this.content,
    super.key,
  })  : mutuallyExclusive = false,
        _checkbox = true,
        variant = ListRowVariant.check,
        value = null,
        subtitle = null,
        icon = null,
        iconColor = null,
        expanded = false,
        editor = null,
        divider = false,
        _exam = false,
        comingSoon = false,
        settingsMode = false,
        titleColor = null,
        richTitle = null,
        footer = null,
        leading = null,
        verticalPadding = 11,
        richSubtitle = null,
        valueStyle = null,
        wrapTitle = false,
        valueWidget = null,
        trailingWidget = null,
        titleWidget = null,
        minimumHeight = 44,
        contentPadding = null,
        leadingGap = 12;
  const ListRow.exam({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.comingSoon = false,
    this.settingsMode = false,
    this.divider = false,
    super.key,
  })  : mutuallyExclusive = false,
        _exam = true,
        _checkbox = false,
        variant = ListRowVariant.check,
        value = null,
        icon = null,
        iconColor = null,
        expanded = false,
        editor = null,
        content = null,
        titleColor = null,
        richTitle = null,
        footer = null,
        leading = null,
        verticalPadding = 11,
        richSubtitle = null,
        valueStyle = null,
        wrapTitle = false,
        valueWidget = null,
        trailingWidget = null,
        titleWidget = null,
        minimumHeight = 44,
        contentPadding = null,
        leadingGap = 12;
  final bool _exam;
  final bool comingSoon;
  final bool settingsMode;
  final bool _checkbox;
  final bool mutuallyExclusive;
  final Widget? content;
  final String title;
  final Widget? titleWidget;
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
  final bool wrapTitle;
  final double minimumHeight;
  final EdgeInsetsGeometry? contentPadding;
  final double leadingGap;
  final Widget? valueWidget;
  final Widget? trailingWidget;
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_exam ||
        _checkbox ||
        variant == ListRowVariant.check ||
        variant == ListRowVariant.radio) {
      final radio =
          _exam || mutuallyExclusive || variant == ListRowVariant.radio;
      final body = content ??
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget ??
                  Text.rich(
                    richTitle ?? TextSpan(text: title),
                    style: _checkbox
                        ? context.type.body.copyWith(
                            fontSize: 16,
                            height: 1.4,
                            letterSpacing: 0,
                          )
                        : context.type.body,
                    maxLines: _checkbox || wrapTitle ? null : 1,
                    overflow:
                        _checkbox || wrapTitle ? null : TextOverflow.ellipsis,
                  ),
              if (subtitle != null)
                Text(subtitle!, style: context.type.footnote),
              if (footer != null) footer!,
            ],
          );
      final padding = contentPadding ??
          EdgeInsets.symmetric(
            horizontal: 16,
            vertical: _checkbox ? 14 : verticalPadding,
          );
      final action = comingSoon ? null : onTap;
      final row = radio
          ? RadioRow(
              title: title,
              selected: selected,
              onTap: action,
              content: body,
              padding: padding,
              trailing: comingSoon
                  ? Text('Coming soon', style: context.type.footnote)
                  : trailingWidget,
            )
          : CheckboxRow(
              interactiveContent: _checkbox && content != null,
              title: title,
              selected: selected,
              onTap: action,
              content: body,
              padding: padding,
              trailing: trailingWidget,
            );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row,
          if (divider)
            Padding(
              padding: EdgeInsets.only(left: _exam && !settingsMode ? 16 : 0),
              child: DecoratedBox(
                key: _exam ? const ValueKey('exam-row-divider') : null,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: c.separator, width: .5),
                  ),
                ),
                child: const SizedBox(height: .5),
              ),
            ),
        ],
      );
    }
    final stack = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final labelStyle = context.type.body.copyWith(
      color: variant == ListRowVariant.destructive
          ? c.wrongText
          : titleColor ?? c.label,
    );
    final label = Text.rich(
      richTitle ?? TextSpan(text: title),
      maxLines: wrapTitle ? null : 1,
      overflow: wrapTitle ? null : TextOverflow.ellipsis,
      style: labelStyle,
    );
    final detail = valueWidget ??
        (value == null
            ? null
            : Text(
                value!,
                style: valueStyle ?? context.type.rowValue,
                textAlign: stack ? TextAlign.start : TextAlign.end,
              ));
    final trailing = trailingWidget ??
        switch (variant) {
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
            inMutuallyExclusiveGroup:
                mutuallyExclusive || variant == ListRowVariant.radio,
            child: Material(
              color: context.colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  constraints: BoxConstraints(minHeight: minimumHeight),
                  padding: contentPadding ??
                      EdgeInsets.symmetric(
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
                        SizedBox(width: leadingGap),
                      ] else if (icon != null) ...[
                        Icon(icon, size: 22, color: iconColor ?? c.accent),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleWidget ?? label,
                            if (subtitle != null || richSubtitle != null)
                              Text.rich(
                                richSubtitle ?? TextSpan(text: subtitle),
                                style: context.type.footnote,
                              ),
                            if (footer != null) footer!,
                            if (stack && detail != null) detail,
                          ],
                        ),
                      ),
                      if (!stack && detail != null) ...[
                        const SizedBox(width: 8),
                        Flexible(child: detail),
                      ],
                      if (trailingWidget != null ||
                          (variant != ListRowVariant.value &&
                              variant != ListRowVariant.destructive)) ...[
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
