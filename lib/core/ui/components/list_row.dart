import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/pantas_switch.dart';
import 'package:pantas/core/ui/icons/pantas_icons.dart';
import 'package:pantas/core/ui/motion/pantas_effects.dart';
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
  })  : _checkbox = true,
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
  })  : _exam = true,
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
    if (_exam) {
      final large = MediaQuery.textScalerOf(context).scale(17) > 25.5;
      final enabled = !comingSoon && onTap != null;
      final row = Semantics(
        selected: selected,
        enabled: enabled,
        child: Material(
          color: c.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: settingsMode ? 10 : 11,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Opacity(
                          opacity: comingSoon ? .45 : 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.type.body,
                              ),
                              if (subtitle != null)
                                Text(
                                  subtitle!,
                                  style: context.type.footnote,
                                ),
                            ],
                          ),
                        ),
                        if (comingSoon && large)
                          Text(
                            'Coming soon',
                            style: context.type.footnote.copyWith(
                              color: c.tertiaryLabel,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (comingSoon && !large) ...[
                    const SizedBox(width: 10),
                    Text(
                      'Coming soon',
                      style: context.type.footnote.copyWith(
                        color: c.tertiaryLabel,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (selected) ...[
                    const SizedBox(width: 10),
                    ExcludeSemantics(
                      child: SizedBox.square(
                        dimension: 18,
                        child: CustomPaint(
                          key: const ValueKey('exam-check'),
                          painter: _CheckboxCheckPainter(
                            c.accent,
                            strokeWidth: 2.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row,
          if (divider)
            Padding(
              padding: EdgeInsets.only(left: settingsMode ? 0 : 16),
              child: DecoratedBox(
                key: const ValueKey('exam-row-divider'),
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
    if (_checkbox) {
      return Semantics(
        container: true,
        explicitChildNodes: content != null,
        label: content == null ? null : title,
        checked: selected,
        onTap: onTap,
        child: Material(
          color: c.transparent,
          child: InkWell(
            onTap: onTap,
            excludeFromSemantics: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      key: const ValueKey('checkbox-mark'),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: selected ? c.accentFill : null,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: selected ? c.accentFill : c.controlOutline,
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? PantasEffects.pop(
                              duration: const Duration(milliseconds: 500),
                              builder: (_, __, child) => child!,
                              child: Center(
                                child: SizedBox.square(
                                  dimension: 15,
                                  child: CustomPaint(
                                    key: const ValueKey('checkbox-check'),
                                    painter: _CheckboxCheckPainter(
                                      c.onAccent,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: content ??
                        Text(
                          title,
                          style: context.type.body.copyWith(
                            fontSize: 16,
                            letterSpacing: 0,
                            height: 1.4,
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

// O_Consent's 15 px SVG uses a 24-unit viewBox and a 3-unit check stroke.
class _CheckboxCheckPainter extends CustomPainter {
  const _CheckboxCheckPainter(this.color, {this.strokeWidth = 3});
  final Color color;
  final double strokeWidth;
  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(size.width / 24, size.height / 24)
      ..drawPath(
        Path()
          ..moveTo(5, 12.5)
          ..lineTo(9.5, 17)
          ..lineTo(19, 7),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(_CheckboxCheckPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
