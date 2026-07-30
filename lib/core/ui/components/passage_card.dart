import 'package:flutter/material.dart';
import 'package:pantas/core/storage/domain/passage.dart';
import 'package:pantas/core/ui/theme/app_dimensions.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';

/// Renders a reading comprehension passage in the reader's typography.
///
/// Section 5 of passage spec:
/// - Reader's typography: serif (`SourceSans3`), line height 1.6, `ink` color.
/// - Hairline rule separates passage from question.
/// - Scrolls with content (no sticky or pinned header).
class PassageCard extends StatelessWidget {
  const PassageCard({
    required this.passage,
    super.key,
  });

  final Passage passage;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (passage.title.isNotEmpty) ...[
          Text(passage.title, style: textStyles.headlineSmall),
          const SizedBox(height: 8),
        ],
        Text(
          passage.body,
          style: textStyles.bodyLarge.copyWith(
            fontFamily: 'SourceSans3',
            height: 1.6,
            color: colors.ink,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: AppDimensions.hairline,
          color: colors.rule,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
