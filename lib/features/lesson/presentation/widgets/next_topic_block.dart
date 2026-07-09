import 'package:cse_cet_reviewer/core/ui/components/ink_chevron.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/lesson/domain/models/study_map.dart';
import 'package:flutter/material.dart';

/// A block presenting the next topic after finishing one.
class NextTopicBlock extends StatelessWidget {
  const NextTopicBlock({
    required this.topic,
    required this.meta,
    required this.onTap,
    super.key,
  });

  final StudyTopic topic;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colors.ruleFaint,
              // ignore: avoid_redundant_argument_values
              width: AppDimensions.hairline,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next',
                    style: textStyles.captionSmall.copyWith(
                      color: colors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    topic.name,
                    style: textStyles.displayMedium.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meta,
                    style: textStyles.bodySmall.copyWith(
                      fontSize: 12.5,
                      color: colors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const InkChevron(),
          ],
        ),
      ),
    );
  }
}
