import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/section_header.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/study_plan/application/study_plan_providers.dart';
import 'package:pantas/features/study_plan/presentation/collapsed_plan_section.dart';
import 'package:pantas/features/study_plan/presentation/mock_week_card.dart';
import 'package:pantas/features/study_plan/presentation/today_inset.dart';
import 'package:pantas/features/study_plan/presentation/upcoming_day_chip.dart';
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
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (error, _) => Center(
          child: Text(
            'Plan unavailable: $error',
            style: context.textStyles.bodyMedium
                .copyWith(color: context.colors.inkMuted),
          ),
        ),
        data: (state) {
          return switch (state) {
            StudyPlanNeedsExamSelection() => Center(
                child: Text(
                  'Choose an exam to build your plan.',
                  style: context.textStyles.bodyMedium
                      .copyWith(color: context.colors.inkMuted),
                ),
              ),
            StudyPlanReady(:final view) => ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                children: [
                  Text(
                    'Week ${view.weeksToExam} to exam · '
                    '${_paceLabel(view.paceStatus.name)}',
                    style: context.textStyles.bodySmall
                        .copyWith(color: context.colors.inkMuted),
                  ),
                  const SizedBox(height: 12),
                  TodayInset(
                    plan: view.today,
                    onStart: () => context.go(view.today.ctaPath),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'This week'),
                  for (final day in view.upcoming) UpcomingDayChip(day: day),
                  if (view.nearestMock != null)
                    MockWeekCard(preview: view.nearestMock!),
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
