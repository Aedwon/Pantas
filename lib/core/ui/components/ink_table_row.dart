import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum InkRowState { plain, active, done }

/// Tabular list row: optional state glyph, title/subtitle, category and
/// right-aligned meta columns, faint bottom rule.
class InkTableRow extends StatelessWidget {
  const InkTableRow({
    required this.title,
    this.subtitle,
    this.category,
    this.meta,
    this.state = InkRowState.plain,
    this.bottomRule = true,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? category;
  final String? meta;
  final InkRowState state;
  final bool bottomRule;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;

    final titleStyle = switch (state) {
      InkRowState.done => styles.bodyMedium.copyWith(color: colors.inkMuted),
      InkRowState.active =>
        styles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      InkRowState.plain => styles.bodyMedium,
    };

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (state != InkRowState.plain) ...[
          Text(
            state == InkRowState.done ? '✓' : '○',
            style: styles.bodySmall.copyWith(
              color: state == InkRowState.done ? colors.board : colors.ink,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: titleStyle),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: styles.bodySmall.copyWith(color: colors.inkMuted),
                ),
            ],
          ),
        ),
        if (category != null) ...[
          const SizedBox(width: 8),
          Text(
            category!,
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
        if (meta != null) ...[
          const SizedBox(width: 12),
          Text(
            meta!,
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: bottomRule
              ? Border(
                  bottom: BorderSide(
                    color: colors.ruleFaint,
                    // ignore: avoid_redundant_argument_values
                    width: AppDimensions.hairline,
                  ),
                )
              : null,
        ),
        child: row,
      ),
    );
  }
}
