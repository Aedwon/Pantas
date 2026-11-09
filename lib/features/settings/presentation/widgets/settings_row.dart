import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/list_row.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
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
    this.verticalPadding = PantasSpace.s10,
    this.valueStyle,
    this.titleWidget,
    this.trailingWidget,
    this.mutuallyExclusive = false,
    this.footer,
    this.hideChevron = false,
    this.subtitleStyle,
    this.valueWidget,
    this.dividerInset = 0,
    this.richTitle,
    super.key,
  });

  final String title;

  /// A title with a mark after it (check and radio rows).
  final InlineSpan? richTitle;
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

  /// Wide web: the board draws no arrow on this row.
  final bool hideChevron;

  /// Phone only: left inset of the divider under the row.
  final double dividerInset;

  /// Phone only: replaces the value text (the exam date chip).
  final Widget? valueWidget;

  /// Wide web: the subtitle style (the boards use 13 px under a title).
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    if (variant == ListRowVariant.check || variant == ListRowVariant.radio) {
      return ListRow(
        title: title,
        richTitle: richTitle,
        variant: variant,
        selected: selected,
        onTap: onTap,
        subtitle: subtitle,
        footer: footer,
        divider: divider,
        mutuallyExclusive: mutuallyExclusive,
        titleWidget: titleWidget,
        trailingWidget: trailingWidget,
      );
    }
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
        valueWidget: valueWidget,
        hideTrailing: hideChevron,
        dividerInset: dividerInset,
        titleWidget: titleWidget,
        trailingWidget: trailingWidget,
        mutuallyExclusive: mutuallyExclusive,
        footer: footer,
      );
    }
    final t = context.webTokens;
    final c = t.colors;
    final control = variant == ListRowVariant.switchControl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          toggled: control ? selected : null,
          inMutuallyExclusiveGroup: mutuallyExclusive,
          child: WebRow(
            title: title,
            subtitle: subtitle,
            subtitleStyle: subtitleStyle,
            titleStyle: PantasType.webRowTitleSettings.copyWith(
              color: variant == ListRowVariant.destructive
                  ? c.dangerText
                  : titleColor ?? c.textPrimary,
            ),
            titleSuffix: footer,
            horizontalPadding: PantasLayout.rowInsetSettings,
            value: value,
            valueStyle: valueStyle ??
                PantasType.webRowTitleSettings.copyWith(color: c.textSecondary),
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
                    : (variant == ListRowVariant.navigation ||
                                variant == ListRowVariant.inlineEditor) &&
                            !hideChevron
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
        // The phone's row opens its editor over 300 ms (`ListRow`). With
        // reduced motion it opens at once, without an AnimatedSize, which
        // cannot size in zero time.
        if (variant == ListRowVariant.inlineEditor)
          if (MediaQuery.disableAnimationsOf(context))
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PantasSpace.s16,
                  PantasSpace.s6,
                  PantasSpace.s16,
                  PantasSpace.s16,
                ),
                child: editor,
              )
            else
              const SizedBox.shrink()
          else
            AnimatedSize(
              duration: PantasDurations.flip,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(
                        PantasSpace.s16,
                        PantasSpace.s6,
                        PantasSpace.s16,
                        PantasSpace.s16,
                      ),
                      child: editor,
                    )
                  : const SizedBox.shrink(),
            ),
      ],
    );
  }
}
