import 'package:flutter/material.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Rows of faint paper-toned bars: the identity's loading skeleton and
/// "unprinted" teaser fill. No gray blocks, no shimmer.
class FaintBars extends StatelessWidget {
  const FaintBars({
    this.widthFactors = const [0.9, 0.65, 0.8],
    this.semanticsLabel,
    this.liveRegion = false,
    super.key,
  });

  final List<double> widthFactors;
  final String? semanticsLabel;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bars = Column(
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
    if (semanticsLabel == null) {
      return ExcludeSemantics(child: bars);
    }
    return Semantics(
      label: semanticsLabel,
      liveRegion: liveRegion,
      child: ExcludeSemantics(child: bars),
    );
  }
}
