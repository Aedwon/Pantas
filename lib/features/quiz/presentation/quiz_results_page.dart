import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final attemptByIdProvider =
    FutureProvider.family<Attempt?, String>((ref, id) async {
  return ref.watch(attemptsRepositoryProvider).byId(id);
});

final _examNameProvider =
    FutureProvider.family<String, String>((ref, examId) async {
  final exams = await ref.watch(contentRepositoryProvider).listExams();
  return exams.firstWhere((exam) => exam.id == examId).name;
});

class QuizResultsPage extends ConsumerWidget {
  const QuizResultsPage({required this.attemptId, super.key});

  final String attemptId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAttempt = ref.watch(attemptByIdProvider(attemptId));

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: asyncAttempt.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (attempt) {
          if (attempt == null) {
            return Center(
              child: EmptyState(
                illustration: '📭',
                headline: 'Attempt not found',
                body: 'We could not locate the quiz attempt.',
                ctaLabel: 'Go back',
                onCta: () => Navigator.of(context).maybePop(),
              ),
            );
          }
          return _ResultsBody(attempt: attempt);
        },
      ),
    );
  }
}

class _ResultsBody extends ConsumerStatefulWidget {
  const _ResultsBody({required this.attempt});

  final Attempt attempt;

  @override
  ConsumerState<_ResultsBody> createState() => _ResultsBodyState();
}

class _ResultsBodyState extends ConsumerState<_ResultsBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowNudge());
  }

  Future<void> _maybeShowNudge() async {
    if (!mounted) return;
    final examId = widget.attempt.examId;
    final isDone = await ref.read(assessmentCompletedProvider(examId).future);
    if (isDone || !mounted) return;
    final count = await ref.read(countForExamProvider(examId).future);
    if (!mounted) return;
    final examName = await ref
        .read(_examNameProvider(examId).future)
        .catchError((Object _) => 'this exam');
    if (!mounted) return;

    if (count == 1) {
      await _showNudgeSheet(
        'Get your personalized study plan — see exactly where to focus for '
        '$examName.',
      );
    } else if (count == 3) {
      await _showNudgeSheet(
        "You've done 3 quizzes — find out which topics to prioritize.",
      );
    }
  }

  Future<void> _showNudgeSheet(String message) async {
    if (!mounted) return;
    final examId = widget.attempt.examId;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: context.textStyles.bodyMedium),
              const SizedBox(height: 24),
              AppButton(
                label: 'Start assessment',
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  if (context.mounted) context.go('/assessment/$examId');
                },
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Maybe later',
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final attempt = widget.attempt;
    final examId = attempt.examId;
    final (correct, total) = attempt.score;
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();

    final isDone =
        ref.watch(assessmentCompletedProvider(examId)).valueOrNull ?? true;
    final count = ref.watch(countForExamProvider(examId)).valueOrNull ?? 0;
    final showBanner = !isDone && count >= 5;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showBanner) ...[
          GestureDetector(
            onTap: () => context.go('/assessment/$examId'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Your study plan is waiting. Take the assessment →',
                style: textStyles.bodyMedium.copyWith(color: colors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        AppCard(
          variant: AppCardVariant.accent,
          child: Column(
            children: [
              Text(
                '$correct / $total ($percent%)',
                style:
                    textStyles.displaySmall.copyWith(color: colors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'Score',
                style: textStyles.bodyMedium
                    .copyWith(color: colors.onSurfaceMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...attempt.items.map((item) => _ItemRow(item: item)),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final AttemptItem item;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final isCorrect = item.isCorrect;
    final seconds = (item.responseMs / 1000).toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.questionId,
                style: textStyles.bodyMedium.copyWith(color: colors.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${seconds}s',
              style:
                  textStyles.bodySmall.copyWith(color: colors.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}
