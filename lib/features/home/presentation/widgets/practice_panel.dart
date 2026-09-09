import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pantas/core/storage/selected_exam_focus.dart';
import 'package:pantas/core/ui/components/faint_bars.dart';
import 'package:pantas/core/ui/components/ink_chevron.dart';
import 'package:pantas/core/ui/components/inline_meter.dart';
import 'package:pantas/core/ui/components/ruled_panel.dart';
import 'package:pantas/core/ui/severity.dart';
import 'package:pantas/core/ui/theme/app_theme.dart';
import 'package:pantas/features/home/application/topic_accuracy_provider.dart';
import 'package:pantas/features/quiz/application/quiz_providers.dart';
import 'package:pantas/features/quiz/application/today_quiz_preparer.dart';

class PracticePanel extends ConsumerWidget {
  const PracticePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focus = ref.watch(activeExamFocusProvider).valueOrNull;
    if (focus?.exam == null) {
      return const SizedBox.shrink();
    }
    final examId = focus!.exam!.id;

    final asyncAccuracy = ref.watch(topicAccuracyProvider);

    return asyncAccuracy.when(
      loading: () => RuledPanel(
        heading: 'Practice',
        action: 'See all',
        onAction: () => context.go('/progress'),
        child: Semantics(
          label: 'Loading practice topics',
          child: const ExcludeSemantics(child: FaintBars()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (topics) {
        if (topics.isEmpty) {
          return const SizedBox.shrink();
        }

        final topTopics = topics.take(3).toList();

        return RuledPanel(
          heading: 'Practice',
          action: 'See all',
          onAction: () => context.go('/progress'),
          child: Column(
            children: [
              for (var i = 0; i < topTopics.length; i++)
                _PracticeRow(
                  examId: examId,
                  topic: topTopics[i],
                  bottomRule: i < topTopics.length - 1,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PracticeRow extends ConsumerWidget {
  const _PracticeRow({
    required this.examId,
    required this.topic,
    required this.bottomRule,
  });

  final String examId;
  final TopicAccuracy topic;
  final bool bottomRule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final styles = context.textStyles;

    final accuracy = topic.accuracy;
    final isMeasured = topic.isMeasured && accuracy != null;
    final color = isMeasured ? severityFor(accuracy, colors) : colors.ink;
    final pctString = isMeasured ? '${(accuracy * 100).round()}%' : null;

    return InkWell(
      onTap: () async {
        try {
          final prepared = await ref.read(todayQuizPreparerProvider).prepare(
                QuizPreparationRequest(
                  userId: quizLocalUserId,
                  examId: examId,
                  topicId: topic.topicId,
                ),
              );
          if (!context.mounted) return;
          if (prepared.plan.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No questions are ready right now.'),
              ),
            );
            return;
          }
          unawaited(
            context.push(
              '/quiz/today/$examId?topicId=${topic.topicId}',
              extra: prepared,
            ),
          );
        } catch (_) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not prepare this quiz.')),
          );
        }
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: bottomRule
              ? Border(
                  bottom: BorderSide(
                    color: colors.ruleFaint,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                topic.topicName,
                style: styles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isMeasured) ...[
              const SizedBox(width: 8),
              InlineMeter(
                value: accuracy,
                color: color,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                child: Text(
                  pctString!,
                  textAlign: TextAlign.right,
                  style: styles.bodySmall.copyWith(color: color),
                ),
              ),
            ],
            const SizedBox(width: 10),
            const InkChevron(),
          ],
        ),
      ),
    );
  }
}
