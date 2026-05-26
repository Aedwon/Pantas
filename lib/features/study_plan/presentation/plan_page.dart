import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/study_plan/application/study_plan_providers.dart';
import 'package:cse_cet_reviewer/features/study_plan/presentation/collapsed_plan_section.dart';
import 'package:cse_cet_reviewer/features/study_plan/presentation/mock_week_card.dart';
import 'package:cse_cet_reviewer/features/study_plan/presentation/today_inset.dart';
import 'package:cse_cet_reviewer/features/study_plan/presentation/upcoming_day_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PlanPage extends ConsumerWidget {
  const PlanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(studyPlanViewProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Your study plan')),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Plan unavailable: $error')),
        data: (state) {
          return switch (state) {
            StudyPlanNeedsExamSelection() => const Center(
                child: Text('Choose an exam to build your plan.'),
              ),
            StudyPlanReady(:final view) => ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Week ${view.weeksToExam} to exam · ${_paceLabel(view.paceStatus.name)}',
                    style: context.textStyles.bodySmall
                        .copyWith(color: context.colors.onSurfaceMuted),
                  ),
                  const SizedBox(height: 12),
                  TodayInset(
                    plan: view.today,
                    onStart: () => context.go(view.today.ctaPath),
                  ),
                  const SizedBox(height: 16),
                  Text('This week', style: context.textStyles.headlineSmall),
                  const SizedBox(height: 8),
                  for (final day in view.upcoming) ...[
                    UpcomingDayChip(day: day),
                    const SizedBox(height: 8),
                  ],
                  if (view.nearestMock != null) ...[
                    const SizedBox(height: 8),
                    MockWeekCard(preview: view.nearestMock!),
                  ],
                  const SizedBox(height: 8),
                  const CollapsedPlanSection(label: 'Past 2 weeks'),
                  const CollapsedPlanSection(label: 'Show full plan'),
                ],
              ),
          };
        },
      ),
    );
  }

  static String _paceLabel(String value) {
    return switch (value) {
      'onPace' => 'On pace',
      'behind' => 'Behind',
      'ahead' => 'Ahead',
      _ => value,
    };
  }
}
