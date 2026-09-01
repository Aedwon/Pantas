import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

class PlanRow extends StatelessWidget {
  const PlanRow({
    required this.title,
    required this.termLine,
    required this.rightFigure,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.badge,
    this.footnote,
    super.key,
  });

  final String title;
  final String termLine;
  final String rightFigure;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final String? badge;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.8;

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: styles.headlineSmall.copyWith(fontSize: 14)),
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
    );

    final figures = Column(
      crossAxisAlignment:
          largeText ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(rightFigure, style: styles.headlineSmall.copyWith(fontSize: 14)),
        if (footnote != null) ...[
          const SizedBox(height: 2),
          Text(
            footnote!,
            textAlign: largeText ? TextAlign.start : TextAlign.end,
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ],
    );

    return Semantics(
      label: '$title plan',
      selected: selected,
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onTap : null,
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
                child: largeText
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          details,
                          const SizedBox(height: 8),
                          figures,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: details),
                          const SizedBox(width: 12),
                          Flexible(child: figures),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
