import 'package:pantas/core/ui/components/ink_table_row.dart';
import 'package:pantas/features/study_plan/domain/compute_plan_view.dart';
import 'package:flutter/material.dart';

class UpcomingDayChip extends StatelessWidget {
  const UpcomingDayChip({
    required this.day,
    super.key,
  });

  final UpcomingPlanDay day;

  @override
  Widget build(BuildContext context) {
    return InkTableRow(
      title: day.focusLabel,
      meta: day.isRestDay ? 'Rest' : '${day.estimatedQuestionCount} questions',
    );
  }
}
