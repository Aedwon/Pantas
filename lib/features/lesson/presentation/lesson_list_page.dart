import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/lesson.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
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
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
          ),
        ),
        data: (lessons) {
          if (lessons.isEmpty) {
            return _EmptyLessons(examId: examId);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              for (final lesson in lessons)
                _LessonRow(lesson: lesson, examId: examId),
            ],
          );
        },
      ),
    );
  }
}

class _LessonRow extends ConsumerWidget {
  const _LessonRow({required this.lesson, this.examId});

  final Lesson lesson;
  final String? examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examParam = examId != null ? '?examId=$examId' : '';
    final isRead =
        ref.watch(isLessonReadProvider(lesson.id)).valueOrNull ?? false;
    return InkTableRow(
      title: lesson.title,
      subtitle: lesson.summary,
      state: isRead ? InkRowState.done : InkRowState.plain,
      meta: '${lesson.estimatedMinutes} min',
      onTap: () => context.push('/lesson/${lesson.id}$examParam'),
    );
  }
}

class _EmptyLessons extends StatelessWidget {
  const _EmptyLessons({this.examId});

  final String? examId;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text('No lessons yet', style: styles.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'This topic has no lessons yet.',
          style: styles.bodyMedium.copyWith(color: colors.inkMuted),
        ),
        if (examId != null) ...[
          const SizedBox(height: 20),
          BoardButton(
            label: 'Try a quick quiz instead',
            secondary: true,
            onPressed: () => context.push('/quiz/quick/$examId'),
          ),
        ],
      ],
    );
  }
}
