import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/app_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attemptByIdProvider =
    FutureProvider.family<Attempt?, String>((ref, id) async {
  return ref.watch(attemptsRepositoryProvider).byId(id);
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

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.attempt});

  final Attempt attempt;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    final colors = context.colors;
    final (correct, total) = attempt.score;
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
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
