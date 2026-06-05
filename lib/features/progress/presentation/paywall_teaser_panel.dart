import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// "Unprinted" teaser for Pro-gated analytical panels: the heading prints,
/// the content renders as faint paper-toned bars, and the header's trailing
/// slot carries the unlock affordance.
class PaywallTeaserPanel extends StatelessWidget {
  const PaywallTeaserPanel({
    required this.title,
    required this.onUnlock,
    super.key,
  });

  final String title;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget bar(double widthFactor) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: widthFactor,
          child: Container(
            height: 7,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: colors.ruleFaint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          action: 'Unlock with Pro',
          onAction: onUnlock,
        ),
        const SizedBox(height: 4),
        bar(0.92),
        bar(0.7),
        bar(0.83),
      ],
    );
  }
}
