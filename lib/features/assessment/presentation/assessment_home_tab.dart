import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/assessment_result.dart';
import 'package:cse_cet_reviewer/features/assessment/domain/models/topic_mastery.dart';
import 'package:cse_cet_reviewer/features/assessment/presentation/assessment_result_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef AssessmentHomeSlotBuilder = Widget Function(
  BuildContext context,
  WidgetRef ref,
  ExamId examId,
);

class AssessmentHomeTab extends ConsumerWidget {
  const AssessmentHomeTab({super.key, this.afterHeaderBuilder});

  final AssessmentHomeSlotBuilder? afterHeaderBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFocus = ref.watch(activeExamFocusProvider);

    return Scaffold(
      body: SafeArea(
        child: asyncFocus.when(
          loading: () => const _HomeLoading(),
          error: (e, _) => _HomeError(message: e.toString()),
          data: (focus) {
            if (focus.needsSelection || focus.exam == null) {
              return const _ChooseExamHome();
            }
            return _SelectedExamHome(
              examId: focus.exam!.id,
              examName: focus.exam!.name,
              afterHeaderBuilder: afterHeaderBuilder,
            );
          },
        ),
      ),
    );
  }
}

class _SelectedExamHome extends ConsumerWidget {
  const _SelectedExamHome({
    required this.examId,
    required this.examName,
    this.afterHeaderBuilder,
  });

  final ExamId examId;
  final String examName;
  final AssessmentHomeSlotBuilder? afterHeaderBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(assessmentResultProvider(examId));
    final afterHeader = afterHeaderBuilder?.call(context, ref, examId);

    return asyncResult.when(
      loading: () => const _HomeLoading(),
      error: (e, _) => _HomeError(message: e.toString()),
      data: (result) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          _DashboardHeader(title: 'Home', subtitle: examName),
          const SizedBox(height: 18),
          if (afterHeader != null) ...[afterHeader, const SizedBox(height: 14)],
          if (result == null)
            _NoAssessmentCard(examId: examId)
          else
            _StudyPlanCard(result: result, examId: examId),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textStyles.displaySmall),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textStyles.bodyMedium.copyWith(color: colors.onSurfaceMuted),
        ),
      ],
    );
  }
}

class _ChooseExamHome extends StatelessWidget {
  const _ChooseExamHome();

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        const _DashboardHeader(title: 'Home', subtitle: 'Choose exam'),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose your exam', style: textStyles.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Pick the exam you are reviewing for.',
                style: textStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Choose exam',
                onPressed: () => context.go('/onboarding'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoAssessmentCard extends StatelessWidget {
  const _NoAssessmentCard({required this.examId});

  final ExamId examId;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DiagnosticPlaceholder(),
          const SizedBox(height: 18),
          Text('Build your study plan', style: textStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Take the assessment to find what to study first.',
            style: textStyles.bodyMedium.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Start assessment',
            onPressed: () => context.go('/assessment/$examId'),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Quiz for now',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/quiz/quick/$examId'),
          ),
        ],
      ),
    );
  }
}

class _StudyPlanCard extends StatelessWidget {
  const _StudyPlanCard({required this.result, required this.examId});

  final AssessmentResult result;
  final ExamId examId;

  List<TopicMastery> get _homeTopics {
    return result.topicMasteries.take(3).toList();
  }

  bool get _allStrong {
    final topics = _homeTopics;
    return topics.isNotEmpty &&
        topics.every((m) => m.level == MasteryLevel.strong);
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final topics = _homeTopics;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assessment last taken on ${_formatDate(result.completedAt)}',
            style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: 10),
          Text(
            _allStrong ? 'Keep sharp' : 'Your study plan',
            style: textStyles.headlineSmall,
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < topics.length; i++) ...[
            _StudyPlanRow(
              mastery: topics[i],
              examId: examId,
              isFirst: i == 0,
            ),
            if (i != topics.length - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => context.go('/assessment/$examId/results'),
            child: Text(
              'View full results',
              style: textStyles.bodyMedium.copyWith(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyPlanRow extends StatelessWidget {
  const _StudyPlanRow({
    required this.mastery,
    required this.examId,
    required this.isFirst,
  });

  final TopicMastery mastery;
  final ExamId examId;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final isStrong = mastery.level == MasteryLevel.strong;
    final action = isStrong ? 'Quiz' : 'Study';
    final path = isStrong
        ? Uri(
            path: '/quiz/quick/$examId',
            queryParameters: {'topicId': mastery.topic.id},
          ).toString()
        : '/study/topic/${mastery.topic.id}?examId=$examId';

    return Row(
      children: [
        Expanded(
          child: Text(
            mastery.topic.name,
            style: textStyles.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(mastery.accuracy * 100).round()}%',
          style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 82,
          child: AppButton(
            label: action,
            variant:
                isFirst ? AppButtonVariant.primary : AppButtonVariant.secondary,
            onPressed: () => context.go(path),
          ),
        ),
      ],
    );
  }
}

class _DiagnosticPlaceholder extends StatelessWidget {
  const _DiagnosticPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 184,
            height: 112,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          Positioned(
            left: 42,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PlaceholderBar(width: 70, color: colors.primary),
                const SizedBox(height: 10),
                _PlaceholderBar(width: 96, color: colors.error),
                const SizedBox(height: 10),
                _PlaceholderBar(width: 58, color: colors.primary),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary, width: 8),
            ),
            child: Icon(Icons.search, color: colors.primary, size: 30),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderBar extends StatelessWidget {
  const _PlaceholderBar({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: const [
        SkeletonBox(height: 22, width: 120),
        SizedBox(height: 8),
        SkeletonBox(height: 14, width: 180),
        SizedBox(height: 18),
        SkeletonCard(),
      ],
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ErrorBanner(
        variant: ErrorBannerVariant.error,
        message: message,
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
