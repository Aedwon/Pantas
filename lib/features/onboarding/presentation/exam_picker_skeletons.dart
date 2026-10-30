import 'package:flutter/material.dart';
import 'package:pantas/core/ui/components/skeleton.dart';
import 'package:pantas/core/ui/web/web_tokens.dart';

/// The wide exam picker before the catalog loads: the search field, the group
/// chips, the "my exam isn't listed" card, then two groups of exam cards three
/// to a row.
class ExamPickerWebSkeleton extends StatelessWidget {
  const ExamPickerWebSkeleton({super.key});

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
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < cards; i++)
                    SkeletonBlock(
                      width: (constraints.maxWidth - 20) / 3,
                      height: 64,
                      radius: 14,
                      section: true,
                    ),
                ],
              ),
            ),
          ],
        );
    return SkeletonPulse(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SkeletonBlock(height: 44, radius: 12),
          const SizedBox(height: 16),
          const Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              SkeletonBlock(width: 52, height: 34, radius: 17),
              SkeletonBlock(width: 84, height: 34, radius: 17),
              SkeletonBlock(width: 96, height: 34, radius: 17),
              SkeletonBlock(width: 72, height: 34, radius: 17),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonCard(height: 70),
          const SizedBox(height: 24),
          group(3),
          const SizedBox(height: 24),
          group(6),
        ],
      ),
    );
  }
}
