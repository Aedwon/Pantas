import 'dart:async';
import 'package:cse_cet_reviewer/core/storage/domain/ids.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/review_list.dart';
import 'package:cse_cet_reviewer/core/ui/theme/app_theme.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/question_flag_providers.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/quiz_controller.dart';
import 'package:cse_cet_reviewer/features/quiz/presentation/review_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FlaggedListPage extends ConsumerWidget {
  const FlaggedListPage({
    required this.examId,
    this.proIsActive = false,
    super.key,
  });

  final ExamId examId;
  final bool proIsActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEntries = ref.watch(flaggedReviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Questions you flagged')),
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
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  headline: 'Flag anything you want to come back to',
                  body: 'Questions you flag during quizzes will appear here.',
                  ctaLabel: 'Go back',
                  onCta: () => Navigator.of(context).maybePop(),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: ReviewList(
              entries: entries,
              proIsActive: proIsActive,
              grouped: true,
              showFilters: false,
              onToggleFlag: (questionId) async {
                await ref
                    .read(questionFlagControllerProvider.notifier)
                    .toggle(questionId);
              },
              footer: BoardButton(
                label: 'Practice these ${entries.length}',
                onPressed: () async {
                  final ids = entries.map((e) => e.question.id).toList();
                  await ref
                      .read(quizControllerProvider.notifier)
                      .startPracticeFromQuestionIds(
                        examId: examId,
                        questionIds: ids,
                      );
                  if (context.mounted) {
                    unawaited(context.push('/quiz/session/$examId'));
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
