import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_dimensions.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LessonListPage extends ConsumerWidget {
  const LessonListPage({required this.topicId, this.examId, super.key});

  final TopicId topicId;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTopic = ref.watch(topicByIdProvider(topicId));
    final asyncLessons = ref.watch(topicLessonsProvider(topicId));

    final title = asyncTopic.maybeWhen(
      data: (t) => t?.name ?? 'Lessons',
      orElse: () => 'Lessons',
    );

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: asyncLessons.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
          ),
        ),
        data: (lessons) {
          if (lessons.isEmpty) {
            return _EmptyState(examId: examId);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) =>
                _LessonCard(lesson: lessons[i], examId: examId),
          );
        },
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({required this.lesson, this.examId});

  final Lesson lesson;
  final String? examId;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final examParam = examId != null ? '?examId=$examId' : '';

    return InkWell(
      onTap: () => context.push('/lesson/${lesson.id}$examParam'),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.title, style: textStyles.headlineSmall),
            const SizedBox(height: 4),
            Text(
              lesson.summary,
              style:
                  textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '${lesson.estimatedMinutes} min read',
              style:
                  textStyles.labelSmall.copyWith(color: colors.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.examId});
  final String? examId;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No lessons yet for this topic',
            style: textStyles.bodyLarge.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
          if (examId != null) ...[
            const SizedBox(height: 16),
            AppButton(
              label: 'Try a quick quiz instead',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/quiz/quick/$examId'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonCard(),
          SizedBox(height: 12),
          SkeletonCard(),
        ],
      ),
    );
  }
}
