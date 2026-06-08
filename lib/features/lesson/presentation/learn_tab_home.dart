import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/storage/domain/subject.dart';
import 'package:cse_cet_reviewer/core/storage/selected_exam_focus.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/error_banner.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
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
        data: (focus) {
          if (focus.needsSelection || focus.exam == null) {
            return const _ChooseExamFallback();
          }
          final exam = focus.exam!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Text(exam.name, style: context.textStyles.headlineMedium),
              const SizedBox(height: 12),
              for (final subject in exam.subjects)
                _SubjectSection(subject: subject, examId: exam.id),
            ],
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
    final styles = context.textStyles;
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        Text('Choose your exam', style: styles.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Pick the exam you are reviewing for.',
          style: styles.bodyMedium.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: 20),
        BoardButton(
          label: 'Choose exam',
          onPressed: () => context.go('/onboarding'),
        ),
      ],
    );
  }
}

class _SubjectSection extends ConsumerWidget {
  const _SubjectSection({required this.subject, required this.examId});

  final Subject subject;
  final ExamId examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTopics = ref.watch(topicsBySubjectProvider(subject.id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: subject.name),
        asyncTopics.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: FaintBars(widthFactors: [0.8, 0.6]),
          ),
          error: (e, _) => ErrorBanner(
            variant: ErrorBannerVariant.error,
            message: e.toString(),
          ),
          data: (topics) => Column(
            children: [
              for (final topic in topics)
                InkTableRow(
                  title: topic.name,
                  onTap: () => context.push(
                    '/study/topic/${topic.id}?examId=$examId',
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
