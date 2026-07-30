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
import 'package:pantas/features/quiz/domain/use_cases/start_today_session.dart';

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
        child: const FaintBars(),
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
        final now = ref.read(nowProvider)();
        final preferences =
            await ref.read(quizPreferencesRepositoryProvider).read();
        final result = await ref.read(startTodaySessionProvider)(
          userId: 'local_user',
          examId: examId,
          topicId: topic.topicId,
          preferences: preferences,
          now: now,
        );

        if (!context.mounted) return;

        switch (result) {
          case StartTodaySessionStarted():
            unawaited(
              context.push('/quiz/today/$examId?topicId=${topic.topicId}'),
            );
          case StartTodaySessionNoQuestions(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
        }
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
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
