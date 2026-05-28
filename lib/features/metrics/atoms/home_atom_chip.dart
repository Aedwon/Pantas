import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/metrics/atoms/atom.dart';
import 'package:flutter/material.dart';

class HomeAtomChip extends StatelessWidget {
  const HomeAtomChip({required this.chip, super.key});

  final AtomChip chip;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.auto_graph, color: colors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              chip.text,
              style: textStyles.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (chip.metric != null) ...[
            const SizedBox(width: 10),
            Text(
              chip.metric!,
              style: textStyles.labelLarge.copyWith(color: colors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
