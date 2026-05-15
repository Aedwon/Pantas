import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
import 'package:cse_cet_reviewer/core/ui/components/skeleton_loader.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LessonPage extends ConsumerWidget {
  const LessonPage({required this.lessonId, this.examId, super.key});

  final LessonId lessonId;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLesson = ref.watch(lessonByIdProvider(lessonId));

    return Scaffold(
      appBar: AppBar(),
      body: asyncLesson.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.refresh(lessonByIdProvider(lessonId)),
          ),
        ),
        data: (lesson) {
          if (lesson == null) {
            return const Center(child: Text('Lesson not found.'));
          }
          return _LessonBody(lesson: lesson, examId: examId);
        },
      ),
    );
  }
}

class _LessonBody extends ConsumerWidget {
  const _LessonBody({required this.lesson, this.examId});

  final Lesson lesson;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final asyncIsRead = ref.watch(isLessonReadProvider(lesson.id));
    final isRead = asyncIsRead.valueOrNull ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson.title, style: textStyles.displaySmall),
          const SizedBox(height: 8),
          PortableTextRenderer(blocks: lesson.bodyJson),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: colors.onSurfaceMuted),
              const SizedBox(width: 4),
              Text(
                '${lesson.estimatedMinutes} min read',
                style:
                    textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isRead)
            AppButton(
              label: 'Lesson complete ✓',
              variant: AppButtonVariant.secondary,
              onPressed: null,
            )
          else
            AppButton(
              label: 'Mark as read',
              onPressed: () async {
                await ref
                    .read(lessonProgressRepositoryProvider)
                    .markRead(lesson.id);
                ref.invalidate(isLessonReadProvider(lesson.id));
                ref.invalidate(anyLessonReadProvider);
              },
            ),
          if (examId != null) ...[
            const SizedBox(height: 16),
            AppButton(
              label: 'Quiz this topic',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(height: 28, width: 240),
          SizedBox(height: 16),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: 8),
          SkeletonBox(height: 14, width: double.infinity),
          SizedBox(height: 8),
          SkeletonBox(height: 14, width: 180),
        ],
      ),
    );
  }
}
