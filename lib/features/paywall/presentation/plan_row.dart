import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

class PlanRow extends StatelessWidget {
  const PlanRow({
    required this.title,
    required this.termLine,
    required this.rightFigure,
    required this.selected,
    required this.onTap,
    this.badge,
    this.footnote,
    super.key,
  });

  final String title;
  final String termLine;
  final String rightFigure;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? colors.ink : colors.rule,
              width: selected ? 1.6 : 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(top: 3, right: 11),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.ink, width: 1.4),
                color: selected ? colors.ink : Colors.transparent,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: styles.headlineSmall.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    termLine,
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      badge!,
                      style: styles.labelSmall.copyWith(color: colors.board),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rightFigure,
                  style: styles.headlineSmall.copyWith(fontSize: 14),
                ),
                if (footnote != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    footnote!,
                    style: styles.bodySmall.copyWith(color: colors.inkMuted),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
