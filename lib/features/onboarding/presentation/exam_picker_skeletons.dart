import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/theme/tokens/pantas_space.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The wide exam picker before the catalog loads: the search field, the group
/// chips, the "my exam isn't listed" card, then two groups of exam rows.
class ExamPickerWebSkeleton extends StatelessWidget {
  const ExamPickerWebSkeleton({this.customCard = true, super.key});

  /// Whether the picker offers a student's own exam, so the card has a place.
  final bool customCard;

  @override
  Widget build(BuildContext context) {
    final eyebrow = skeletonLineHeight(context.webTokens.eb);
    Widget group(int cards) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: eyebrow,
              child: const Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBlock(width: 110, height: 12),
              ),
            ),
            const SizedBox(height: PantasSpace.s8),
            for (var i = 0; i < cards; i++) ...[
              if (i > 0) const SizedBox(height: PantasSpace.s10),
              const SkeletonBlock(height: 64, radius: 14, section: true),
            ],
          ],
        );
    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SkeletonBlock(height: 44, radius: 12),
          const SizedBox(height: PantasSpace.s16),
          const Wrap(
            spacing: PantasSpace.s6,
            runSpacing: PantasSpace.s6,
            children: [
              SkeletonBlock(width: 52, height: 34, radius: 17),
              SkeletonBlock(width: 84, height: 34, radius: 17),
              SkeletonBlock(width: 96, height: 34, radius: 17),
              SkeletonBlock(width: 72, height: 34, radius: 17),
            ],
          ),
          const SizedBox(height: PantasSpace.s24),
          if (customCard) ...[
            const SkeletonCard(height: 70),
            const SizedBox(height: PantasSpace.s24),
          ],
          group(3),
          const SizedBox(height: PantasSpace.s24),
          group(6),
        ],
      ),
    );
  }
}
