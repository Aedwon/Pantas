import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metric_signal.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/metrics_window.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_key.dart';
import 'package:cse_cet_reviewer/features/metrics/domain/signal_outputs.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/current_archetype_provider.dart';
import 'package:cse_cet_reviewer/features/metrics/providers/metrics_signal_providers.dart';
import 'package:cse_cet_reviewer/features/progress/application/progress_providers.dart';
import 'package:cse_cet_reviewer/features/progress/domain/progress_panel.dart';
import 'package:cse_cet_reviewer/features/progress/presentation/paywall_teaser_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProgressPage extends ConsumerWidget {
  const ProgressPage({required this.proIsActive, super.key});

  final bool proIsActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final focus = ref.watch(activeExamFocusProvider).valueOrNull;
    final examId = focus?.exam?.id;
    final panels = progressPanelsForEntitlement(proIsActive: proIsActive);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Text('Progress', style: styles.displaySmall),
          if (examId == null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Pick your exam to start tracking progress.',
                style: styles.bodyMedium.copyWith(color: colors.inkMuted),
              ),
            )
          else
            for (final panel in panels)
              _ProgressPanelSection(panel: panel, examId: examId),
        ],
      ),
    );
  }
}

class _ProgressPanelSection extends ConsumerWidget {
  const _ProgressPanelSection({required this.panel, required this.examId});

  final ProgressPanel panel;
  final String examId;

  /// Day-quantized clock so the provider-family request key stays stable
  /// across rebuilds within the same day.
  static DateTime _endOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (panel.id) {
      'archetype' => _ArchetypePanel(examId: examId, now: _endOfToday()),
      'signal_stats' => _SignalStatsPanel(examId: examId, now: _endOfToday()),
      'trend_lines' => _analytical(context, 'Accuracy trend'),
      'weakness_narrative' => _analytical(context, "Where you're slipping"),
      'best_mock' => _analytical(context, 'Mock exams'),
      'wrapped_history_stub' => _milestonesPanel(context),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _analytical(BuildContext context, String title) {
    if (panel.access == ProgressPanelAccess.teaser) {
      return PaywallTeaserPanel(
        title: title,
        onUnlock: () => context.push('/paywall'),
      );
    }
    final styles = context.textStyles;
    final colors = context.colors;
    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 4),
          Text(
            'Charts land here in an upcoming update.',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }

  Widget _milestonesPanel(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;
    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Milestones'),
          const SizedBox(height: 4),
          Text(
            'No milestone cards yet. They appear at streaks and '
            'mock records.',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _ArchetypePanel extends ConsumerWidget {
  const _ArchetypePanel({required this.examId, required this.now});

  final String examId;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final styles = context.textStyles;
    final colors = context.colors;
    final archetype = ref
        .watch(
          currentArchetypeProvider(
            CurrentArchetypeRequest(
              userId: 'local',
              examId: examId,
              window: MetricsWindow.rolling30d,
              now: now,
            ),
          ),
        )
        .valueOrNull;
    if (archetype == null) return const SizedBox.shrink();
    return RuledSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your profile',
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 2),
          Text(archetype.label, style: styles.headlineMedium),
          const SizedBox(height: 2),
          Text(
            archetype.synthesizedCopy,
            style: styles.bodySmall.copyWith(color: colors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _SignalStatsPanel extends ConsumerWidget {
  const _SignalStatsPanel({required this.examId, required this.now});

  final String examId;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SignalResult<Object?>? signal(SignalKey key) {
      return ref
          .watch(
            metricsSignalProvider(
              MetricsSignalRequest(
                signal: key,
                window: MetricsWindow.allTime,
                examId: examId,
                now: now,
              ),
            ),
          )
          .valueOrNull;
    }

    final streak = signal(SignalKey.consistency)?.value as StreakPattern?;
    final coverage = signal(SignalKey.coverageBreadth)?.value as CoveragePct?;

    final figures = [
      if (streak != null)
        StatFigure(
          value: '${streak.currentStreakDays}',
          label: 'day streak',
        ),
      if (coverage != null)
        StatFigure(
          value: '${(coverage.percent * 100).round()}%',
          label: 'syllabus touched',
        ),
    ];
    if (figures.isEmpty) return const SizedBox.shrink();
    return RuledSection(
      topRule: false,
      padding: EdgeInsets.zero,
      child: StatsBand(figures: figures),
    );
  }
}
