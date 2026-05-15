import 'package:cse_cet_reviewer/core/storage/domain/exam.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class QuizTabHome extends ConsumerWidget {
  const QuizTabHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExams = ref.watch(examListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: asyncExams.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exams) {
          if (exams.isEmpty) {
            return const Center(child: Text('No exams available.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final exam = exams[index];
              return _ExamCard(exam: exam);
            },
          );
        },
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam});

  final Exam exam;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam.name,
            style: textStyles.headlineSmall.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            exam.shortName,
            style: textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Start Quick Quiz',
            onPressed: () => context.go('/quiz/quick/${exam.id}'),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Browse Lessons',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/learn'),
          ),
        ],
      ),
    );
  }
}
