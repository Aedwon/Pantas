import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
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

class LearnTabHome extends ConsumerWidget {
  const LearnTabHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const StudyTabHome();
  }
}

class StudyTabHome extends ConsumerWidget {
  const StudyTabHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFocus = ref.watch(activeExamFocusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Study')),
      body: asyncFocus.when(
        loading: () => const _LoadingSkeleton(),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
          ),
        ),
        data: (focus) {
          if (focus.needsSelection || focus.exam == null) {
            return const _ChooseExamFallback();
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [_ExamAccordion(exam: focus.exam!)],
          );
        },
      ),
    );
  }
}

class _ChooseExamFallback extends StatelessWidget {
  const _ChooseExamFallback();

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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

class _ExamAccordion extends ConsumerWidget {
  const _ExamAccordion({required this.exam});
  final Exam exam;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        initiallyExpanded: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        title: Text(exam.name, style: textStyles.headlineSmall),
        subtitle: exam.shortName != exam.name
            ? Text(
                exam.shortName,
                style:
                    textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
              )
            : null,
        children: [
          for (final subject in exam.subjects)
            _SubjectExpansion(subject: subject, examId: exam.id),
        ],
      ),
    );
  }
}

class _SubjectExpansion extends ConsumerWidget {
  const _SubjectExpansion({required this.subject, required this.examId});
  final Subject subject;
  final ExamId examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTopics = ref.watch(topicsBySubjectProvider(subject.id));
    final textStyles = context.textStyles;

    return ExpansionTile(
      title: Text(subject.name, style: textStyles.bodyLarge),
      children: [
        asyncTopics.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircularProgressIndicator(),
          ),
          error: (e, _) => ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
          ),
          data: (topics) => Column(
            children: [
              for (final topic in topics)
                ListTile(
                  title: Text(topic.name, style: textStyles.bodyMedium),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(
                    '/study/topic/${topic.id}?examId=$examId',
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SkeletonCard(),
        SizedBox(height: 8),
        SkeletonCard(),
      ],
    );
  }
}
