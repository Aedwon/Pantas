import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/portable_text_renderer.dart';
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
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
            actionLabel: 'Retry',
            onAction: () => ref.refresh(lessonByIdProvider(lessonId)),
          ),
        ),
        data: (lesson) {
          if (lesson == null) {
            return Center(
              child: Text(
                'Lesson not found.',
                style: context.textStyles.bodyMedium
                    .copyWith(color: context.colors.inkMuted),
              ),
            );
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
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson.title, style: textStyles.displaySmall),
          const SizedBox(height: 8),
          PortableTextRenderer(blocks: lesson.bodyJson),
          const SizedBox(height: 24),
          Text(
            '${lesson.estimatedMinutes} min read',
            style: textStyles.bodySmall.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: 16),
          if (isRead)
            Text(
              '✓ Lesson complete',
              style: textStyles.bodyMedium.copyWith(color: colors.board),
            )
          else
            BoardButton(
              label: 'Mark as read',
              onPressed: () async {
                await ref
                    .read(lessonProgressRepositoryProvider)
                    .markRead(lesson.id);
                ref
                  ..invalidate(isLessonReadProvider(lesson.id))
                  ..invalidate(anyLessonReadProvider);
              },
            ),
          if (examId != null) ...[
            const SizedBox(height: 16),
            BoardButton(
              label: 'Quiz yourself',
              secondary: true,
              onPressed: () =>
                  context.push('/quiz/inline/$examId/${lesson.id}'),
            ),
          ],
        ],
      ),
    );
  }
}
