import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Rows of faint paper-toned bars — the identity's loading skeleton and
/// "unprinted" teaser fill. No gray blocks, no shimmer.
class FaintBars extends StatelessWidget {
  const FaintBars({this.widthFactors = const [0.9, 0.65, 0.8], super.key});

  final List<double> widthFactors;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final factor in widthFactors)
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: factor,
            child: Container(
              height: 7,
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: colors.ruleFaint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}
