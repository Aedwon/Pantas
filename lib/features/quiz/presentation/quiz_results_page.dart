import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/review_list.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/quiz/presentation/question_flag_providers.dart';
import 'package:pantas/features/quiz/presentation/review_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizResultsPage extends ConsumerWidget {
  const QuizResultsPage({
    required this.attemptId,
    this.proIsActive = false,
    super.key,
  });

  final String attemptId;
  final bool proIsActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEntries = ref.watch(practiceReviewProvider(attemptId));

    return Scaffold(
      appBar: AppBar(title: const Text('All questions')),
      body: asyncEntries.when(
        loading: () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: const [FaintBars()],
        ),
        error: (e, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Text(
              'Something went wrong',
              style: context.textStyles.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              e.toString(),
              style: context.textStyles.bodySmall
                  .copyWith(color: context.colors.inkMuted),
            ),
          ],
        ),
        data: (entries) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: ReviewList(
              entries: entries,
              proIsActive: proIsActive,
              grouped: false,
              onToggleFlag: (questionId) async {
                await ref
                    .read(questionFlagControllerProvider.notifier)
                    .toggle(questionId);
              },
            ),
          );
        },
      ),
    );
  }
}
