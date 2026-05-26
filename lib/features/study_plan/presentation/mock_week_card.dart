import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/study_plan/domain/compute_plan_view.dart';
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(preview.title, style: textStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(
            preview.description,
            style: textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
