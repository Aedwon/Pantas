import 'package:cse_cet_reviewer/core/ui/components/ink_chevron.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum InkRowState { plain, active, done }

/// A chevron marks a row that does something when tapped. One that rotates is
/// a disclosure; one that does not is a link.
enum InkRowChevron { none, link, disclosure }

/// Tabular list row: optional state glyph, title/subtitle, category and
/// right-aligned meta columns, faint bottom rule.
class InkTableRow extends StatelessWidget {
  const InkTableRow({
    required this.title,
    this.subtitle,
    this.category,
    this.meta,
    this.state = InkRowState.plain,
    this.chevron = InkRowChevron.none,
    this.expanded = false,
    this.reserveGlyph = false,
    this.bottomRule = true,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? category;
  final String? meta;
  final InkRowState state;
  final InkRowChevron chevron;

  /// Only read when [chevron] is a disclosure.
  final bool expanded;

  /// Reserve the leading glyph column even on rows with no glyph, so titles
  /// align down a list where some rows carry one. A per-list decision: it is
  /// off by default so lists that can never show a glyph keep their gutter.
  final bool reserveGlyph;
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
        if (state == InkRowState.done) ...[
          SizedBox(
            width: styles.bodySmall.fontSize ?? 12,
            child: Text(
              '✓',
              style: styles.bodySmall.copyWith(color: colors.board),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (reserveGlyph) ...[
          // A started row draws no glyph: the meta already says it, and a
          // bullet is the same fact told louder. The column is still held so
          // every title in the list sits on one vertical line.
          SizedBox(width: styles.bodySmall.fontSize ?? 12),
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
        if (chevron != InkRowChevron.none) ...[
          const SizedBox(width: 10),
          Center(
            child: InkChevron(
              pointsDown: chevron == InkRowChevron.disclosure && expanded,
            ),
          ),
        ],
      ],
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.centerLeft,
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
