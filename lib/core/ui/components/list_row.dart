import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/components/selection_row.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_border.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_durations.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_layout.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_size.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_type.dart';
import 'package:pantas/core/ui/web/web_keyboard_focus.dart';
import 'package:pantas/core/ui/web/web_layout.dart';

enum _ValueFit { beside, split, stacked }

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
    this.verticalPadding,
    this.richSubtitle,
    this.valueStyle,
    this.wrapTitle = false,
    this.minimumHeight = PantasSize.rowMinPhone,
    this.contentPadding,
    this.leadingGap = PantasSpace.s12,
    this.valueWidget,
    this.trailingWidget,
    this.mutuallyExclusive = false,
    this.naturalValue = false,
    this.dividerInset = 0,
    this.hideTrailing = false,
    this.subtitleGap = 0,
    this.subtitleMaxLines,
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
        naturalValue = false,
        dividerInset = 0,
        hideTrailing = false,
        subtitleGap = 0,
        subtitleMaxLines = null,
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
        verticalPadding = null,
        richSubtitle = null,
        valueStyle = null,
        wrapTitle = false,
        valueWidget = null,
        trailingWidget = null,
        titleWidget = null,
        minimumHeight = PantasSize.rowMinPhone,
        contentPadding = null,
        leadingGap = PantasSpace.s12;
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
        naturalValue = false,
        dividerInset = 0,
        hideTrailing = false,
        subtitleGap = 0,
        subtitleMaxLines = null,
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
        verticalPadding = null,
        richSubtitle = null,
        valueStyle = null,
        wrapTitle = false,
        valueWidget = null,
        trailingWidget = null,
        titleWidget = null,
        minimumHeight = PantasSize.rowMinPhone,
        contentPadding = null,
        leadingGap = PantasSpace.s12;
  final bool _exam;
  final bool comingSoon;
  final bool settingsMode;
  final bool _checkbox;
  final bool mutuallyExclusive;

  /// Phone Today rows (HE_*, HP_*): the value keeps its own width and the
  /// title takes the rest. Without it the title and value split the space.
  final bool naturalValue;

  /// Left inset of the divider, drawn under the row. Zero keeps the divider
  /// inside the row at full width.
  final double dividerInset;

  /// Draws no trailing control or space after the value (ST_Exam date chip).
  final bool hideTrailing;

  /// Space between the title and the subtitle (phone Plan day rows).
  final double subtitleGap;

  /// Cuts a long subtitle with an ellipsis instead of wrapping it.
  final int? subtitleMaxLines;
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

  /// Space above and below the content. Null takes the system's 13 on wide
  /// screens (`layout-row-pad-y`) and the phone board's 11.
  final double? verticalPadding;
  final InlineSpan? richSubtitle;
  final TextStyle? valueStyle;
  final bool wrapTitle;
  final double minimumHeight;
  final EdgeInsetsGeometry? contentPadding;
  final double leadingGap;
  final Widget? valueWidget;
  final Widget? trailingWidget;

  /// How the title and the value share [width] (the row's space between the
  /// leading glyph and the chevron): side by side at their own widths, split
  /// in half when the title still fits in its half, or stacked.
  _ValueFit _valueFit(
    BuildContext context,
    double width,
    TextStyle titleStyle,
    TextStyle valueStyle,
  ) {
    double natural(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      final result = painter.width;
      painter.dispose();
      return result;
    }

    final start = natural(title, titleStyle);
    final end = natural(value!, valueStyle);
    const gap = PantasSpace.s8;
    if (start + gap + end <= width) return _ValueFit.beside;
    // Ruling 12: the title keeps at least 6em of its own text before the
    // value stacks under it.
    final sixEm =
        MediaQuery.textScalerOf(context).scale(titleStyle.fontSize!) * 6;
    if (width - gap - end < (start < sixEm ? start : sixEm)) {
      return _ValueFit.stacked;
    }
    return start <= (width - gap) / 2 ? _ValueFit.split : _ValueFit.stacked;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final wide = context.wideWeb;
    final titleBase =
        (wide ? PantasType.webRowTitle : PantasType.phoneBody).copyWith(
      color: c.textPrimary,
    );
    final subBase =
        (wide ? PantasType.webRowSub : PantasType.phoneFootnote).copyWith(
      color: c.textSecondary,
    );
    final valueBase =
        (wide ? PantasType.webRowValue : PantasType.phoneBody).copyWith(
      color: c.textSecondary,
    );
    final padY = verticalPadding ??
        (wide ? PantasLayout.rowPadY : PantasLayout.rowPadY - PantasSpace.s2);
    final padX = wide ? PantasLayout.rowInset : PantasSpace.s16;
    if (_exam && settingsMode && !context.wideWeb) {
      final stackComingSoon =
          comingSoon && MediaQuery.textScalerOf(context).scale(17) > 25.5;
      // ST_ExamPick: a plain 62 px row, the check at the right, and a gray
      // "Coming soon" for an exam that is not out yet.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            checked: selected,
            inMutuallyExclusiveGroup: true,
            enabled: !comingSoon,
            label: '$title, $subtitle${comingSoon ? ', coming soon' : ''}',
            excludeSemantics: true,
            child: ColoredBox(
              color: Colors.transparent,
              child: TextButton(
                onPressed: comingSoon ? null : onTap,
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PantasSpace.s16,
                    vertical: PantasSpace.s10,
                  ),
                  shape: const RoundedRectangleBorder(),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.standard,
                  foregroundColor: c.textPrimary,
                  disabledForegroundColor: c.textDisabled,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: titleBase.copyWith(
                              color:
                                  comingSoon ? c.textDisabled : c.textPrimary,
                            ),
                          ),
                          // Board "f A": beside "Coming soon" the organization
                          // stays on one line and ends in an ellipsis. At
                          // large text the label moves under it (ruling 12)
                          // and the line has the full width.
                          Text(
                            subtitle ?? '',
                            style: subBase.copyWith(
                              color:
                                  comingSoon ? c.textDisabled : c.textSecondary,
                            ),
                            maxLines: comingSoon && !stackComingSoon ? 1 : null,
                            overflow: comingSoon && !stackComingSoon
                                ? TextOverflow.ellipsis
                                : null,
                          ),
                          if (stackComingSoon)
                            Text(
                              'Coming soon',
                              style: subBase.copyWith(
                                fontWeight: FontWeight.w500,
                                color: c.textDisabled,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (comingSoon && !stackComingSoon)
                      Text(
                        'Coming soon',
                        style: subBase.copyWith(
                          fontWeight: FontWeight.w500,
                          color: c.textDisabled,
                        ),
                      )
                    else if (selected)
                      Icon(
                        PantasIcons.check,
                        size: PantasSize.icon,
                        color: c.accent,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (divider)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: c.divider,
                    width: PantasBorder.hairline,
                  ),
                ),
              ),
              child: const SizedBox(height: PantasBorder.hairline),
            ),
        ],
      );
    }
    if (_exam ||
        _checkbox ||
        variant == ListRowVariant.check ||
        variant == ListRowVariant.radio) {
      final radio =
          _exam || mutuallyExclusive || variant == ListRowVariant.radio;
      // At large text sizes "Coming soon" no longer fits beside the title, so
      // it moves under the subtitle (same 1.5x threshold as the rows below).
      final stackComingSoon =
          comingSoon && MediaQuery.textScalerOf(context).scale(17) > 25.5;
      final body = content ??
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget ??
                  Text.rich(
                    richTitle ?? TextSpan(text: title),
                    style: _checkbox
                        ? PantasType.webRowTitleSettings
                            .copyWith(color: c.textPrimary)
                        : titleBase,
                  ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: subBase,
                  // Board "f A": beside "Coming soon" the organization stays on
                  // one line and ends in an ellipsis. When the label moves
                  // under it (large text), the line has the full width.
                  maxLines: comingSoon && !stackComingSoon ? 1 : null,
                  overflow: comingSoon && !stackComingSoon
                      ? TextOverflow.ellipsis
                      : null,
                ),
              if (footer != null) footer!,
              if (stackComingSoon)
                Text(
                  'Coming soon',
                  style: subBase.copyWith(
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
            ],
          );
      final padding = contentPadding ??
          EdgeInsets.symmetric(
            horizontal: PantasSpace.s16,
            vertical: _checkbox ? PantasSpace.s14 : padY,
          );
      final action = comingSoon ? null : onTap;
      final row = radio
          ? RadioRow(
              title: title,
              selected: selected,
              onTap: action,
              content: body,
              padding: padding,
              // O_Picker: the label sits inside the row's 16 px right inset,
              // 8 px after the text, in medium-weight tertiary gray.
              trailing: comingSoon && !stackComingSoon
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: PantasSpace.s8,
                        right: PantasSpace.s16,
                      ),
                      child: Text(
                        'Coming soon',
                        style: subBase.copyWith(
                          fontWeight: FontWeight.w500,
                          color: c.textDisabled,
                        ),
                      ),
                    )
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
              padding: EdgeInsets.only(
                left: _exam && !settingsMode ? PantasSpace.s16 : PantasSpace.s0,
              ),
              child: DecoratedBox(
                key: _exam ? const ValueKey('exam-row-divider') : null,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: c.divider,
                      width: PantasBorder.hairline,
                    ),
                  ),
                ),
                child: const SizedBox(height: PantasBorder.hairline),
              ),
            ),
        ],
      );
    }
    final stack = MediaQuery.textScalerOf(context).scale(17) > 25.5;
    final tinted = selected &&
        (variant == ListRowVariant.navigation ||
            variant == ListRowVariant.value);
    final labelStyle = titleBase.copyWith(
      color: variant == ListRowVariant.destructive
          ? c.dangerText
          : titleColor ?? c.textPrimary,
    );
    final subStyle =
        tinted ? subBase.copyWith(color: c.textOnTintSecondary) : subBase;
    final label = Text.rich(
      richTitle ?? TextSpan(text: title),
      style: labelStyle,
    );
    // A plain text value shares the row with the title. The value takes the
    // room it needs when the title and value fit on one line ("Practice" and
    // "10 questions" at 320 px). When the title would be cut, the value goes
    // under the title, as it does at large text sizes.
    final measureValue = value != null &&
        valueWidget == null &&
        !naturalValue &&
        !wrapTitle &&
        titleWidget == null &&
        richTitle == null;
    Widget? detailAligned(TextAlign align) =>
        valueWidget ??
        (value == null
            ? null
            : Text(
                value!,
                style: valueStyle ??
                    (tinted
                        ? valueBase.copyWith(color: c.textOnTintSecondary)
                        : valueBase),
                textAlign: align,
              ));
    final detail = detailAligned(stack ? TextAlign.start : TextAlign.end);
    final trailing = trailingWidget ??
        switch (variant) {
          ListRowVariant.navigation => Icon(
              PantasIcons.bold(PantasIcons.next),
              size: PantasSpace.s16,
              color: tinted ? c.accentTintText : c.iconChevron,
            ),
          ListRowVariant.switchControl => ExcludeSemantics(
              child: ExcludeFocus(
                child: context.wideWeb
                    ? PantasSwitch(
                        value: selected,
                        label: title,
                        onChanged: (_) => onTap?.call(),
                      )
                    // Phone boards: the row is 53 px, the switch 31. The whole
                    // row is the tap target, so the switch need not be 44.
                    : SizedBox(
                        width: PantasSize.switchW,
                        height: PantasSize.switchH,
                        child: OverflowBox(
                          maxHeight: PantasSize.targetTouch,
                          child: PantasSwitch(
                            value: selected,
                            label: title,
                            onChanged: (_) => onTap?.call(),
                          ),
                        ),
                      ),
              ),
            ),
          ListRowVariant.inlineEditor => Icon(
              expanded ? PantasIcons.close : PantasIcons.bold(PantasIcons.next),
              size: PantasSpace.s16,
              color: expanded ? c.accent : c.iconChevron,
            ),
          _ => const SizedBox.shrink(),
        };
    Widget titleColumn({Widget? stackedDetail}) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget ?? label,
            if (subtitle != null || richSubtitle != null) ...[
              if (subtitleGap > 0) SizedBox(height: subtitleGap),
              Text.rich(
                richSubtitle ?? TextSpan(text: subtitle),
                style: subStyle,
                maxLines: subtitleMaxLines,
                overflow:
                    subtitleMaxLines == null ? null : TextOverflow.ellipsis,
              ),
            ],
            if (footer != null) footer!,
            if (stackedDetail != null) stackedDetail,
          ],
        );
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
            // Hover and press show the `surface-hover` well, a selected row the
            // `accent-tint` fill (both fade over 150ms), and the keyboard ring
            // sits inside the row.
            child: Material(
              color: tinted ? c.accentTint : Colors.transparent,
              animationDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : PantasDurations.short2,
              child: WebKeyboardRing(
                child: InkWell(
                  onTap: onTap,
                  hoverColor: tinted ? Colors.transparent : c.surfaceHover,
                  highlightColor: tinted ? Colors.transparent : c.surfaceHover,
                  splashColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  focusColor: Colors.transparent,
                  child: Container(
                    constraints: BoxConstraints(minHeight: minimumHeight),
                    padding: contentPadding ??
                        EdgeInsets.symmetric(
                          horizontal: padX,
                          vertical: padY,
                        ),
                    decoration: BoxDecoration(
                      border: divider && dividerInset == 0
                          ? Border(
                              bottom: BorderSide(
                                color: c.divider,
                                width: PantasBorder.hairline,
                              ),
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
                          SizedBox(
                            width: wide ? PantasSpace.s16 : PantasSpace.s14,
                          ),
                        ],
                        if (measureValue)
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, box) {
                                final fit = _valueFit(
                                  context,
                                  box.maxWidth,
                                  labelStyle,
                                  valueStyle ?? valueBase,
                                );
                                if (fit == _ValueFit.stacked) {
                                  return titleColumn(
                                    stackedDetail:
                                        detailAligned(TextAlign.start),
                                  );
                                }
                                final titleBlock = titleColumn();
                                return Row(
                                  children: [
                                    Expanded(child: titleBlock),
                                    const SizedBox(width: PantasSpace.s8),
                                    if (fit == _ValueFit.beside)
                                      detail!
                                    else
                                      Flexible(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          heightFactor: 1,
                                          child: detail,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          )
                        else ...[
                          Expanded(
                            child: titleColumn(
                              stackedDetail: stack ? detail : null,
                            ),
                          ),
                          if (!stack && detail != null) ...[
                            SizedBox(
                              width: naturalValue
                                  ? PantasSpace.s10
                                  : PantasSpace.s8,
                            ),
                            if (naturalValue)
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 140),
                                child: detail,
                              )
                            else
                              // Without the Align a short value shrinks to
                              // its own width and sits mid-row.
                              Flexible(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  heightFactor: 1,
                                  child: detail,
                                ),
                              ),
                          ],
                        ],
                        if (!hideTrailing &&
                            (trailingWidget != null ||
                                (variant != ListRowVariant.value &&
                                    variant !=
                                        ListRowVariant.destructive))) ...[
                          const SizedBox(width: PantasSpace.s8),
                          trailing,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (divider && dividerInset > 0)
          Padding(
            padding: EdgeInsets.only(left: dividerInset),
            child: Divider(
              height: PantasBorder.hairline,
              thickness: PantasBorder.hairline,
              color: c.divider,
            ),
          ),
        if (variant == ListRowVariant.inlineEditor)
          AnimatedSize(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : PantasDurations.flip,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PantasSpace.s16,
                      PantasSpace.s4,
                      PantasSpace.s16,
                      PantasSpace.s12,
                    ),
                    child: editor,
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
