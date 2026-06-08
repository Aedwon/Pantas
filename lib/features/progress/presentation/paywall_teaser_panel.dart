import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          action: 'Unlock with Pro',
          onAction: onUnlock,
        ),
        const SizedBox(height: 4),
        const FaintBars(widthFactors: [0.92, 0.7, 0.83]),
      ],
    );
  }
}
