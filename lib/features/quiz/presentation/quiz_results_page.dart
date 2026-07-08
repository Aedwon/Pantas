import 'package:cse_cet_reviewer/core/storage/domain/attempt.dart';
import 'package:cse_cet_reviewer/core/storage/domain/question.dart';
import 'package:cse_cet_reviewer/core/storage/storage.dart';
import 'package:cse_cet_reviewer/core/ui/components/board_button.dart';
import 'package:cse_cet_reviewer/core/ui/components/empty_state.dart';
import 'package:cse_cet_reviewer/core/ui/components/faint_bars.dart';
import 'package:cse_cet_reviewer/core/ui/components/ink_table_row.dart';
import 'package:cse_cet_reviewer/core/ui/components/passage_card.dart';
import 'package:cse_cet_reviewer/core/ui/components/ruled_section.dart';
import 'package:cse_cet_reviewer/core/ui/components/section_header.dart';
import 'package:cse_cet_reviewer/core/ui/components/stats_band.dart';
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

final attemptReviewItemsProvider = FutureProvider.family<
    List<({AttemptItem item, Question? question, Passage? passage})>,
    Attempt>((ref, attempt) async {
  final content = ref.watch(contentRepositoryProvider);
  final result = <({AttemptItem item, Question? question, Passage? passage})>[];
  for (final item in attempt.items) {
    final question = await content.questionById(item.questionId);
    Passage? passage;
    if (question?.passageId != null) {
      passage = await content.passageById(question!.passageId!);
    }
    result.add((item: item, question: question, passage: passage));
  }
  return result;
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
            const SizedBox(height: 20),
            BoardButton(
              label: 'Try again',
              secondary: true,
              onPressed: () => ref.invalidate(attemptByIdProvider(attemptId)),
            ),
          ],
        ),
        data: (attempt) {
          if (attempt == null) {
            return EmptyState(
              headline: 'Attempt not found',
              body: 'We could not locate the quiz attempt.',
              ctaLabel: 'Go back',
              onCta: () => Navigator.of(context).maybePop(),
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
        'Get your personalized study plan: see exactly where to focus for '
        '$examName.',
      );
    } else if (count == 3) {
      await _showNudgeSheet(
        "You've done 3 quizzes. Find out which topics to prioritize.",
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
              BoardButton(
                label: 'Start assessment',
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  if (context.mounted) context.push('/assessment/$examId');
                },
              ),
              const SizedBox(height: 8),
              BoardButton(
                label: 'Maybe later',
                secondary: true,
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
    final attempt = widget.attempt;
    final examId = attempt.examId;
    final (correct, total) = attempt.score;
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();

    final isDone =
        ref.watch(assessmentCompletedProvider(examId)).valueOrNull ?? true;
    final count = ref.watch(countForExamProvider(examId)).valueOrNull ?? 0;
    final showBanner = !isDone && count >= 5;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        if (showBanner)
          RuledSection(
            child: SectionHeader(
              title: 'Your study plan is waiting',
              action: 'Take the assessment',
              onAction: () => context.push('/assessment/$examId'),
            ),
          ),
        StatsBand(
          figures: [
            StatFigure(
              value: '$correct',
              suffix: '/$total',
              label: 'correct',
            ),
            StatFigure(value: '$percent%', label: 'score'),
          ],
        ),
        const SizedBox(height: 12),
        const SectionHeader(title: 'Questions'),
        Consumer(
          builder: (context, ref, _) {
            final asyncItems = ref.watch(attemptReviewItemsProvider(attempt));
            return asyncItems.when(
              loading: () => Column(
                children: [
                  for (final item in attempt.items)
                    InkTableRow(
                      title: item.questionId,
                      state:
                          item.isCorrect ? InkRowState.done : InkRowState.plain,
                      meta: '${(item.responseMs / 1000).toStringAsFixed(1)}s',
                    ),
                ],
              ),
              error: (_, __) => Column(
                children: [
                  for (final item in attempt.items)
                    InkTableRow(
                      title: item.questionId,
                      state:
                          item.isCorrect ? InkRowState.done : InkRowState.plain,
                      meta: '${(item.responseMs / 1000).toStringAsFixed(1)}s',
                    ),
                ],
              ),
              data: (reviewItems) {
                final groups = <({
                  Passage? passage,
                  List<({AttemptItem item, Question? question})> items
                })>[];
                for (final ri in reviewItems) {
                  final passage = ri.passage;
                  if (groups.isNotEmpty &&
                      passage != null &&
                      groups.last.passage?.id == passage.id) {
                    groups.last.items
                        .add((item: ri.item, question: ri.question));
                  } else {
                    groups.add((
                      passage: passage,
                      items: [(item: ri.item, question: ri.question)]
                    ));
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final group in groups) ...[
                      if (group.passage != null)
                        PassageCard(passage: group.passage!),
                      for (final entry in group.items)
                        InkTableRow(
                          title: entry.question?.shortLabel ??
                              entry.question?.stem ??
                              entry.item.questionId,
                          state: entry.item.isCorrect
                              ? InkRowState.done
                              : InkRowState.plain,
                          meta:
                              '${(entry.item.responseMs / 1000).toStringAsFixed(1)}s',
                        ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
