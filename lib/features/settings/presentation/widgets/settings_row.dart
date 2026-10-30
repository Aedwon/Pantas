import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/web/web_components.dart';
import 'package:pantas/core/ui/web/web_layout.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

export 'package:pantas/core/ui/components/list_row.dart' show ListRowVariant;

/// Adapts the existing setting actions to the shared web row.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
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
    this.leading,
    this.titleColor,
    this.verticalPadding = 11,
    this.valueStyle,
    this.titleWidget,
    this.trailingWidget,
    this.mutuallyExclusive = false,
    this.footer,
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
  final Widget? leading;
  final Color? titleColor;
  final double verticalPadding;
  final TextStyle? valueStyle;
  final Widget? titleWidget;
  final Widget? trailingWidget;
  final bool mutuallyExclusive;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    if (!context.wideWeb) {
      return ListRow(
        title: title,
        variant: variant,
        value: value,
        subtitle: subtitle,
        icon: icon,
        iconColor: iconColor,
        selected: selected,
        expanded: expanded,
        editor: editor,
        onTap: onTap,
        divider: divider,
        leading: leading,
        titleColor: titleColor,
        verticalPadding: verticalPadding,
        valueStyle: valueStyle,
        titleWidget: titleWidget,
        trailingWidget: trailingWidget,
        mutuallyExclusive: mutuallyExclusive,
        footer: footer,
      );
    }
    final t = context.webTokens;
    final c = t.colors;
    final check =
        variant == ListRowVariant.check || variant == ListRowVariant.radio;
    final control = variant == ListRowVariant.switchControl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          checked: check ? selected : null,
          toggled: control ? selected : null,
          inMutuallyExclusiveGroup: mutuallyExclusive,
          child: WebRow(
            title: title,
            subtitle: subtitle,
            titleStyle: t.style(
              16,
              color: variant == ListRowVariant.destructive
                  ? c.wrongText
                  : titleColor,
            ),
            titleSuffix: footer,
            horizontalPadding: 16,
            compact: true,
            value: value,
            leading: leading ??
                (icon == null
                    ? null
                    : Icon(icon, size: 22, color: iconColor ?? c.accent)),
            trailing: trailingWidget ??
                (control
                    ? ExcludeSemantics(
                        child: ExcludeFocus(
                          child: PantasSwitch(
                            value: selected,
                            label: title,
                            onChanged: (_) => onTap?.call(),
                          ),
                        ),
                      )
                    : check
                        ? selected
                            ? Icon(PantasIcons.check, size: 18, color: c.accent)
                            : const SizedBox(width: 18)
                        : variant == ListRowVariant.navigation ||
                                variant == ListRowVariant.inlineEditor
                            ? Icon(
                                expanded ? PantasIcons.close : PantasIcons.next,
                                size: 16,
                                color: c.chevron,
                              )
                            : null),
            divider: divider,
            onPressed: onTap,
          ),
        ),
        if (variant == ListRowVariant.inlineEditor && expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: editor,
          ),
      ],
    );
  }
}
