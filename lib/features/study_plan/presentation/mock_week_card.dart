import 'package:pantas/core/ui/components/ruled_section.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/study_plan/domain/compute_plan_view.dart';
import 'package:flutter/material.dart';

class MockWeekCard extends StatelessWidget {
  const MockWeekCard({
    required this.preview,
    super.key,
  });

  final MockWeekPreview preview;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(preview.title, style: textStyles.headlineSmall),
          const SizedBox(height: 4),
          Text(
            preview.description,
            style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
